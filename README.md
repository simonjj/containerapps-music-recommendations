# Build a Music Recommendation Service using Azure Container Apps


## Introduction
In this tutorial, we will walk through the process of setting up an Azure Container App 
to stand up a Jupyter Lab instance to learn and execute and learn about building an 
ephemeral web interface.

> The original version of this tutorial can be found here: 
> [https://github.com/qdrant/examples/blob/master/qdrant_101_audio_data/03_qdrant_101_audio.ipynb](https://github.com/qdrant/examples/blob/master/qdrant_101_audio_data/03_qdrant_101_audio.ipynb).


## Prerequisites
Before we begin, you will need the following:

* An Azure account and the Azure CLI tool installed
* Docker installed on your local machine
* A terminal capable of running Bash


## Steps
1. Clone this repository and edit the `aca_environment.sh` to set the desired variables for:
    * RESOURCE_GROUP
    * APPNAME (optional)
2. Run the `aca_environment.sh` script file to start the Azure Container App and deploy the 
   needed add-ons.
3. Visit the url for `APP_NAME` and aquire the token by taking a look at the console log of 
   the application. Note: The token might take 1-2 minutes after the deployment to show in 
   the logs.
4. Once you've logged into Jupyter navigate to the `music_recommendations.ipynb` notebook and
   follow along using the documentation provided there.


## Important
Please keep the following informtation in mind as you use this code/sample/tutorial:
* All of the Jupyter notebook data is emphemeral and hence **the changes you make to the 
  notebook will not be preserved**. If you'd like to customize the notebook and reuse it
  you can use the File > Download menu to do so.
* The provided dataset is ~11k songs. A regular workstation CPU generates around 1k embeddings
  in 5 minutes.
* The Jupyter container includes the data needed for our tutorial, due to its size startup
  will take longer than usual.


## Todo
The following items would improve this tutorial/sample:
* Convert the `aca_environment.sh` script into a AZD template.
* Some more documentation and clarity.
* Provide a GUI on top of the recommendation service.
* Test execution on GPU.
* Move the current Jupyter container to a more official location.