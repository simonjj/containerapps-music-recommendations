
# Logging in



This is a Windows desktop environment. **Access your personalized credentials** by switching from the **Instructions** tab to the **Resources** tab (see screenshot).

![Skillable Start](https://github.com/simonjj/containerapps-music-recommendations/blob/main/lab/instructions262805/skillable_start_highlight.png?raw=true)

Use **your personalized** credentials in the **Resources** tab to:

- Log into the the Windows desktop system.
- Choose between Windows PowerShell, Ubuntu Bash and Cloud Shell.
- Log into Azure by using `az login` or following the instructions on the screen.
- After loging into Azure return to the **Instructions** tab.

> [!TIP]  Use the **[T]** icon to virtually type at the location of your cursor. This works everywhere except for Cloud Shell.

===


# Register Azure resource providers

Before we dive into an overview and introduction of the application let's kick off the Azure provider registration. 

## Register our Azure subscription with the needed providers

``` powershell
az provider register -n Microsoft.OperationalInsights --wait ; \
az provider register -n Microsoft.ServiceLinker --wait ; \
az provider register -n Microsoft.App --wait
```

``` bash
az provider register -n Microsoft.OperationalInsights --wait && \
az provider register -n Microsoft.ServiceLinker --wait && \
az provider register -n Microsoft.App --wait
```

After we kicked off the steps and **while we wait, let's continue to the next steps** and read about the application we're building.


===


# Introduction & Overview

We're building a music recommendation service where users will be able to search and select from a set of songs, and the system will recommend similar songs to them. Below is a depiction of the architecture:

![Overview](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/misc/overview.png)

The application is composed of **four different components**:

* A _Azure Container Apps (ACA)_ **Jupyter Environment** which teaches about and produces embeddings for our library of 11,000 songs.
* A Qdrant _ACA_ Add-On **Vector DB** which stores embeddings (think of them as fingerprints) and produces our recommendations based on them.
* A _ACA_ **API app** which brokers the data between the frontend UI and the vector database.
* A _ACA_ **Frontend app** which provides the user-facing UI to interact with the recommendation service.

The overall intention of this application is for the user to learn about vector databases. Hence the process of deploying this application is broken up into two parts. 

**In part one we play the role of a data scientist or ML engineer.** We will familiarize ourselves with the process of generating embeddings for our song data. This part completes when we've stored our embeddings in our vector database.

**In part two we play the role of an application engineer** and turn the stored embeddings data into a recommendation service by adding a API and frontend.



===



# Define common variables

Let's defining some shared variables and creating an Azure Resource Group.

> [!TIP]  We will utilize these variables throughout the lab. It can be useful to copy and paste these into Notepad to keep them handy.


## Define needed variables

``` powershell
$env:LOCATION="westus2"
$env:RG="music-rec-service"
$env:ACA_ENV="music-env"
$env:NOTEBOOK_IMAGE="simonj.azurecr.io/aca-music-recommendation-notebook"
$env:BACKEND_IMAGE="simonj.azurecr.io/aca-music-recommendation-backend"
$env:FRONTEND_IMAGE="simonj.azurecr.io/aca-music-recommendation-frontend"
```

``` bash
export LOCATION=westus2
export RG=music-rec-service
export ACA_ENV=music-env
export NOTEBOOK_IMAGE=simonj.azurecr.io/aca-music-recommendation-notebook
export BACKEND_IMAGE=simonj.azurecr.io/aca-music-recommendation-backend
export FRONTEND_IMAGE=simonj.azurecr.io/aca-music-recommendation-frontend
```

## Create our resource group


```powershell

az group create -l $env:LOCATION --name $env:RG
```


```bash
# create the resource group

az group create \
  -l $LOCATION --name $RG
```



===



# Setting up Azure Container Apps vector DB Add-on

The recommendation service's "magic" largely relies on the Azure Container Apps vector database (Qdrant) Add-on, so the primary step is to set up this database. This vector database will be a crucial component of the recommendation service.

## Create the container apps environment with a workload profile

```powershell

# create the environment first
az containerapp env create `
  --name $env:ACA_ENV `
  --resource-group $env:RG `
  --location $env:LOCATION `
  --enable-workload-profiles


# add a workload profile for the large Jupyter image

az containerapp env workload-profile add `
  --name $env:ACA_ENV `
  --resource-group $env:RG `
  --workload-profile-type D8 `
  --workload-profile-name bigProfile `
  --min-nodes 1 --max-nodes 1

```


```bash
# create the environment first

az containerapp env create \
  --name $ACA_ENV \
  --resource-group $RG \
  --location $LOCATION \
  --enable-workload-profiles


# add a workload profile for the large Jupyter image

az containerapp env workload-profile add \
  --name $ACA_ENV \
  --resource-group $RG \
  --workload-profile-type D8 \
  --workload-profile-name bigProfile \
  --min-nodes 1 --max-nodes 1
```

## Launch Azure Container Apps Qdrant vector DB Add-on


```powershell
# Create the vector db add-on

az containerapp add-on qdrant create `
  --environment $env:ACA_ENV `
  --resource-group $env:RG `
  --name qdrant
```



```bash
## Create the vector db add-on

az containerapp add-on qdrant create \
  --environment $ACA_ENV \
  --resource-group $RG \
  --name qdrant
```


===


# Setup and start Jupyter Notebook

As an initial step, we're generating song embeddings. These embeddings will facilitate song comparison for the part 2 service based on similarity. Being a Data Science/Machine Learning task, we'll employ Jupyter notebooks, which offer interactive execution environments for more direct interaction with data and embeddings.

## Create the Jupyter contaner app and login

The notebook container is quite large (10GB). Creation of the application will hence take a few minutes to complete (~5 min).

```powershell

az containerapp create `
  --name music-jupyter `
  --resource-group $env:RG `
  --environment $env:ACA_ENV `
  --image $env:NOTEBOOK_IMAGE `
  --cpu 4 --memory 16.0Gi `
  --workload-profile-name bigProfile `
  --min-replicas 1 `
  --max-replicas 1 `
  --target-port 8888 `
  --ingress external `
  --bind qdrant
```


```bash

az containerapp create \
  --name music-jupyter \
  --resource-group $RG \
  --environment $ACA_ENV \
  --image $NOTEBOOK_IMAGE \
  --cpu 4 --memory 16.0Gi \
  --workload-profile-name bigProfile \
  --min-replicas 1 \
  --max-replicas 1 \
  --target-port 8888 \
  --ingress external \
  --bind qdrant
```

Since we are interacting with sound **we will need to hear the music** playing. Open the browser on your physical hardware in front of you access the URL by copy and pasting it from the remote lab system. 

![portal_running_status.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/skillable_start_highlight.png)

Meanwhile, go to the [Azure portal](https://portal.azure.com/#home) and locate your resource group `music-rec-service`. Look for the `music-jupyter` app and verify its running status in the **Revisions and replicas panel** (Application sub-group). Once your notebook application is active and serving traffic, click on the **Application Url** in the top right corner of the **Overview panel**.

!IMAGE[portal_appurl.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/portal_appurl.png)



===



# Collect access credentials and login

!IMAGE[jupyter_token.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_token.png)

                          https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/portal_running_status.png

```powershell
az containerapp logs show `
  -g $env:RG `
  -n music-jupyter | Select-String "token"
```

```bash
az containerapp logs show \
  -g $RG \
  -n music-jupyter | grep token
```

The command above will display a token which represents **your login password.** Copy and paste it to login into the Jupyter notebook URL from the prior step. 

> [!TIP] Do not click or use the displayed URL as it points to an internal IP and hostname.

Paste your login token into the field to login.

!IMAGE[jupyter_login.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_login.png)

===



# Explore data and generate embeddings

Now that we have our vector database and Jupyter let's use them. Jupyter Lab/Notebooks represent a popular and interactive way to execute code. It is often used by AI/ML engineers when experimenting/developing. **In this step we will _simulate_ the AI/ML process. Double-click on the `start.ipynb` file to start. Follow the instructions until you reach the end of `start.ipynb`** then come back to these instructions and continue with the next step in the lab.

> [!TIP] Some notebook cells will produce red output and will download sizeable models. Collapse them by clicking the blow bar on the left hand side.

!IMAGE[jupyter_start_2.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_start_2.png)

Once we've run a few of the code cell we will see the system starting to generate our embeddings. Notice the rate of generation when using CPU.

!IMAGE[jupyter_embeddings.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_embeddings.png)

> [!NOTE] Creating embeddings is a heavily compute intensive process. For lab it is too time consuming as it takes several hours even on GPU. During this step we will simply explore and learn about the process and what they look like.



===


# Import embeddings into vector DB

The model we've used to generate our audio embeddings is very compute intensive. It would take hours of compute time on a GPU to generate embeddings for all of our 11,000 songs. That's why we will import a pre-computed set of embeddings into our vector database next. To do so double-click the **`import.ipynb`** and run the one cell therein by clicking the play button (see below).

!IMAGE[jupyter_import.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_import.png)


===


# API Backend (setup and testing)

The backend is designed to act as a minimal shim between the vector database and the frontend. **The backend binds to the a Qdrant vector database pre-loaded with embeddings for the songs.**

```powershell
# launch the backend application

az containerapp create `
  --name music-backend `
  --resource-group $env:RG `
  --environment $env:ACA_ENV `
  --image $env:BACKEND_IMAGE `
  --cpu 4 --memory 8.0Gi `
  --workload-profile-name bigProfile `
  --min-replicas 1 `
  --max-replicas 1 `
  --target-port 8000 `
  --ingress external `
  --bind qdrant
```

```bash
# launch the backend application

az containerapp create \
  --name music-backend \
  --resource-group $RG \
  --environment $ACA_ENV \
  --image $BACKEND_IMAGE \
  --cpu 4 --memory 8.0Gi \
  --workload-profile-name bigProfile \
  --min-replicas 1 \
  --max-replicas 1 \
  --target-port 8000 \
  --ingress external \
  --bind qdrant
```

Keep track of the Running status of the API via **Revisions and replicas** as it will take several minutes to launch. After the application is running you should be able to access `http://<YOUR_ACA_ASSIGNED_DOMAIN>/songs`. If you get a JSON list of songs your backend is working as expected. **Copy this URL (without /songs) as you will need it for the next step.**

!IMAGE[backend_songs.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/backend_songs.png)


===


# Frontend UI (setup and testing)

![UI screenshot](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/frontend/misc/screenshot.png)

The frontend provides a basic GUI for the music recommendation service. It depends on the backend, which is provided via the `UI_BACKEND` environment variable. **Make sure to replace the `UI_BACKEND` environment variable below with your own in the form of `https://music-backend.<YOUR_UNIQUE_ID>.westus2.azurecontainerapps.io`**.

```powershell
# launch the frontend application

az containerapp create `
  --name music-frontend `
  --resource-group $env:RG `
  --environment $env:ACA_ENV `
  --image $env:FRONTEND_IMAGE `
  --cpu 2 --memory 4.0Gi `
  --min-replicas 1 `
  --max-replicas 1 `
  --ingress external `
  --target-port 8080 `
  --env-vars UI_BACKEND=https://music-backend.<YOUR_UNIQUE_ID>.westus2.azurecontainerapps.io
```

```
# launch the frontend application

az containerapp create \
  --name music-frontend \
  --resource-group $RG \
  --environment $ACA_ENV \
  --image $FRONTEND_IMAGE \
  --cpu 2 --memory 4.0Gi \
  --min-replicas 1 \
  --max-replicas 1 \
  --ingress external \
  --target-port 8080 \
  --env-vars UI_BACKEND=https://music-backend.<YOUR_UNIQUE_ID>.westus2.azurecontainerapps.io
```

After the application is created and running **access the app from your physical hardware again to ensure you hear sound**. Retrieve the **Application Url** (top right) on the **Overview page** for the `music-frontend`.


===


# APPENDIX: Shortcut to recommendations

Recommendations can be exercised in many ways. The ACA vector db Add-on can also be directly accessed from Jupyter via the **`recommend.ipynb`** notebook. Here you can exercise the embeddings without the need to stand up the other application components. **Using recommendations requires you to import embeddings prior via the `import.ipynb` notebook.**

!IMAGE[jupyter_recommendations.png](https://raw.githubusercontent.com/simonjj/containerapps-music-recommendations/main/lab/instructions262805/jupyter_recommendations.png)