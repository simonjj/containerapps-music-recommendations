# Music Recommendation Backend

## Overview
This backend is part of a larger application, please see [Music Recommendtion Service](../README.md) 
for full details. The backend was built using Python and FastAPI, it is designed to act as a 
minimal shim between the vector database and the frontend. In order to keep setup and complexity down 
to a minimum song data is included (`./data`) alongside application code. The backend assumes you have
a Qdrant vector database pre-loaded with embeddings for the various songs. 

## Run
To run the application locally please ensure you have Python 3.x and pip installed then follow 
these steps:

```
# install the needed dependencies
pip install -r requirments.txt

# set this variable to point to your populated Qdrant database
export QDRANT_HOST=localhost

# start the API
uvicorn songs_api:app --port 8000
```
You should now be able to visit [`http://localhost:8000/songs`](http://localhost:8000/songs) or 
[`http://localhost:8000/songs?genre=electronic`](http://localhost:8000/songs?genre=electronic).

## TODO
- remove the song data and simply retrieve from Qdrant datbase
- add troubleshooting section