
#!/bin/bash

# custmoize these
export APPNAME=temp-music-reco-srv
export RESOURCE_GROUP=playground

# these are nice/optional to customize
export LOCATION=southcentralus
export ENVIRONMENT=temp-music-recommendations

echo "The following variables have been set:"
echo "APPNAME: $APPNAME"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "====================================="

# for documentation on workload profiles see 
# https://docs.microsoft.com/en-us/azure/container-apps/container-apps-workload-profiles
# currently untested, change below only if you know what you're doing
export USE_WLPROFILE=true
export WLPROFILE=D32
export CPU_SIZE=8.0
export MEMORY_SIZE=16.0Gi
export IMAGE=simonj.azurecr.io/aca-ephemeral-music-recommendation-image
export QDBNAME=qdrantdb



if [ "$1" = "delete" ]; then
    echo "Deleting environment..."
    # delete environment
    
    az containerapp service qdrant delete --yes --resource-group $RESOURCE_GROUP \
      --name qdrantdb
    # BUG: workaround for bug
    az containerapp delete --yes --name ${QDBNAME}db -g $RESOURCE_GROUP ; 
    echo "${QDBNAME}db has been deleted"
    az containerapp delete --yes --name $APPNAME -g $RESOURCE_GROUP ; 
    echo "$APPNAME has been deleted"
    az containerapp env delete --yes --name $ENVIRONMENT --resource-group $RESOURCE_GROUP
    az group delete --yes --name $RESOURCE_GROUP
    exit 0
fi

# resource group creation
if az group exists --name $RESOURCE_GROUP | grep True > /dev/null; then
    echo "Resource group $RESOURCE_GROUP exists"
else
    echo "Creating resource group $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi


# create workload profile environment
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
        --workload-profile-name bigProfile --min-nodes 0 --max-nodes 2
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

      # create container app qdrant
      # BUG: This is the workaround for the bug above
      az containerapp create --name ${QDBNAME}db --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --workload-profile-name bigProfile --cpu 2.0 --memory 4.0Gi \
        --image mcr.microsoft.com/k8se/services/qdrant:v1.4 \
        --min-replicas 1 --max-replicas 1

      # create container app
      az containerapp create --name $APPNAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --workload-profile-name bigProfile --cpu $CPU_SIZE --memory $MEMORY_SIZE --image $IMAGE \
        --min-replicas 1 --max-replicas 1 \
        --env-vars RESTARTABLE=yes --env-vars QDRANTDB_QDRANT_HOST=${QDBNAME}db

      #echo "bind app to qdrantdb" 
      # bind app to qdrantdb
      #OFF az containerapp update -n $APPNAME -g $RESOURCE_GROUP --bind qdrantdb
      # BUG: this is a workaround for the bug above
      echo "enabling ingress for qdrantdb replacement" 
      az containerapp ingress enable -n ${QDBNAME}db -g $RESOURCE_GROUP \
        --type internal --target-port 6333 --transport tcp
   fi
   echo "..done"

   echo "==================================="
   echo "enabling ingress" 
   # enable ingress
   az containerapp ingress enable -n $APPNAME -g $RESOURCE_GROUP \
     --type external --target-port 8888 --transport auto
   az containerapp ingress cors enable --name $APPNAME --resource-group $RESOURCE_GROUP
     --allowed-origins *

   sleep 120
   # print login token
   az containerapp logs show -g $RESOURCE_GROUP -n $APPNAME --tail 300 \
     | grep token |  cut -d= -f 2 | cut -d\" -f 1 | uniq

# use consumption plan
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
      ### BUG: This currently won't come up.
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
      # BUG: This is the workaround for the bug above
      az containerapp create --name ${QDBNAME}db --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --cpu 2.0 --memory 4.0Gi --image mcr.microsoft.com/k8se/services/qdrant:v1.4 \
        --min-replicas 1 --max-replicas 1

      # create container app
      az containerapp create --name $APPNAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT \
        --cpu 2.0 --memory 4.0Gi --image $IMAGE \
        --min-replicas 1 --max-replicas 1 \
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
   az containerapp ingress cors enable --name $APPNAME --resource-group $RESOURCE_GROUP
     --allowed-origins *

   # BUG: this is a workaround for the bug above
   az containerapp ingress enable -n ${QDBNAME}db -g $RESOURCE_GROUP \
     --type internal --target-port 6333 --transport tcp

    echo "waiting for deployment to complete.... printing token in 2 min"
    sleep 120
    # print login token
    echo your login token is: `az containerapp logs show -g $RESOURCE_GROUP -n $APPNAME --tail 300 | \
      grep token |  cut -d= -f 2 | cut -d\" -f 1 | uniq`
fi

