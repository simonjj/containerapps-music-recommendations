
#!/bin/bash
export APPNAME=temp-music-reco-srv-54
export APPNAME=temp-music-reco-srv-55
export RESOURCE_GROUP=simonj



export LOCATION=northcentralus


export ENVIRONMENT=temp-music-recommendations-play-55

echo "The following variables have been set:"
echo "APPNAME: $APPNAME"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "====================================="

# for documentation on workload profiles see 
# https://docs.microsoft.com/en-us/azure/container-apps/container-apps-workload-profiles
# currently untested
export USE_WLPROFILE=false
export WLPROFILE=D32
export CPU_SIZE=8.0
export MEMORY_SIZE=16.0Gi
export IMAGE=jupyter/datascience-notebook:latest

export QDBNAME=qdrantdb


# NOTES & TODOs
# Note: This scrupt is currently not entirely functional due to a bug with the add-on
# - setup CORS
# - workload profile path not tested fully



if [ "$1" = "delete" ]; then
    echo "Deleting environment..."
    # delete environment
    
    az containerapp service qdrant delete --resource-group $RESOURCE_GROUP \
      --name qdrantdb
    az containerapp delete --name $APPNAME -g $RESOURCE_GROUP ; 
    echo "$APPNAME has been deleted"
    az containerapp env delete --name $ENVIRONMENT --resource-group $RESOURCE_GROUP
    exit 1
fi


if az group exists --name <resource-group-name> > /dev/null; then
    echo "Resource group $RESOURCE_GROUP exists"
else
    echo "Creating resource group $RESOURCE_GROUP"
    az group create --name <resource-group-name> --location <location>
fi


if [ "$USE_WLPROFILE" = true ]; then
   echo "USING WORKLOAD PROFILE $WLPROFILE"

   echo "========================= checking for env ..."
   if ! az containerapp env show --name $ENVIRONMENT --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
      echo "Creating environment $ENVIRONMENT "

      # create environment and set workload profile
      echo "==================================="
      echo "creating workload profile environment"

      az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION
      az containerapp env workload-profile set --name $ENVIRONMENT \
        --resource-group $RESOURCE_GROUP --workload-profile-type $WLPROFILE \
        --workload-profile-name bigProfile --min-nodes 0 --max-nodes 1
   fi
   echo "..done"

   echo "========================= checking for addon ..."
   if ! az containerapp service list --environment $ENVIRONMENT --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then    
      
      echo "creating qdrantdb" 
      ### create a Qdrant Add-on
      #OFF az containerapp service qdrant create --environment $ENVIRONMENT --resource-group $RESOURCE_GROUP \
      #OFF   --name qdrantdb
        #--cpu 2.0 --memory 4.0Gi \
   fi
   echo "..done"

   echo "========================= checking for app ..."
   if ! az containerapp show --name $APPNAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
      echo "CREATING CONTAINER APP" 
      echo "CPU size: $CPU_SIZE"
      echo "Memory size: $MEMORY_SIZE"
      # create container app
      az containerapp create --name $APPNAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --workload-profile-name bigProfile --cpu $CPU_SIZE --memory $MEMORY_SIZE --image $IMAGE \
        --min-replicas 1 --max-replicas 2 \
        --env-vars RESTARTABLE=yes


      echo "bind app to qdrantdb" 
      # bind app to qdrantdb
      #OFF az containerapp update -n $APPNAME -g $RESOURCE_GROUP --bind qdrantdb
   fi
   echo "..done"

   echo "==================================="
   echo "enabling ingress" 
   # enable ingress
   az containerapp ingress enable -n $APPNAME -g $RESOURCE_GROUP \
     --type external --target-port 8888 --transport auto

    sleep 30
    # print login token
    az containerapp logs show -g $RESOURCE_GROUP -n $APPNAME --tail 300 \
      | grep token |  cut -d= -f 2 | cut -d\" -f 1 | uniq

else
    echo "USING CONSUMPTION PLAN"
    echo "==================================="

    if ! az containerapp env show --name $ENVIRONMENT --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
      echo "Creating environment $ENVIRONMENT "

      # create consumption environment 
      echo "==================================="
      echo "creating consumption profile environment"

      az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION
   else
      echo "environment already exists"
   fi
   
   echo "..done"

   #echo "========================= checking for addon ..."
   #if ! az containerapp service list --environment $ENVIRONMENT --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then    
      
      echo "creating qdrantdb" 
      ### create a Qdrant Add-on
      az containerapp service qdrant create --environment $ENVIRONMENT --resource-group $RESOURCE_GROUP \
        --name $QDBNAME
   #else
   #   echo "qdrantdb already exists"
   #fi
   echo "..done"

   echo "========================= checking for app ..."
   if ! az containerapp show --name $APPNAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
      echo "CREATING CONTAINER APP" 
      echo "CPU size: 2.0"
      echo "Memory size: 4.0Gi"
      # create container app qdrant
      az containerapp create --name ${QDBNAME}db --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --cpu 2.0 --memory 4.0Gi --image mcr.microsoft.com/k8se/services/qdrant:v1.4 \
        --min-replicas 1 --max-replicas 2

      # create container app
      az containerapp create --name $APPNAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --cpu 2.0 --memory 4.0Gi --image $IMAGE \
        --min-replicas 1 --max-replicas 2 \
        --env-vars RESTARTABLE=yes --env-vars QDRANTDB_QDRANT_HOST=${QDBNAME}db


      echo "bind app to qdrantdb" 
      # disable scale-to-zero
      az containerapp update --name $QDBNAME --resource-group $RESOURCE_GROUP \
        --min-replicas 1 --max-replicas 1
      # bind app to qdrantdb
      az containerapp update --name $APPNAME --resource-group $RESOURCE_GROUP \
        --bind $QDBNAME
   fi
   echo "..done"

   echo "==================================="
   echo "enabling ingress" 
   # enable ingress
   az containerapp ingress enable -n $APPNAME -g $RESOURCE_GROUP \
     --type external --target-port 8888 --transport auto

    echo "waiting for deployment to complete.... printing token in 60s"
    sleep 60s
    # print login token
    az containerapp logs show -g $RESOURCE_GROUP -n $APPNAME --tail 300 \
      | grep token |  cut -d= -f 2 | cut -d\" -f 1 | uniq
fi

