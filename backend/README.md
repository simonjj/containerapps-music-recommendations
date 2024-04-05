# Music Recommendation Backend

## Overview
This backend is part of a larger application, please see [Music Recommendation Service](../README.md) for full details. The backend was built using Python and FastAPI, it is designed to act as a minimal shim between the vector database and the frontend. In order to keep deployment complexity to a minimum song data is included (`./data`) alongside application code. The backend assumes you have a Qdrant vector database pre-loaded with embeddings for the various songs. The vector database host is injected via the `QDRANT_HOST` variable.

## Data Prep
Due to the size of the song dataset it hasn't been included as part of this repository. Please download the [Ludwig Music Dataset](https://www.kaggle.com/datasets/jorgeruizdev/ludwig-music-dataset-moods-and-subgenres) from Kaggle to provide the needed song data. Once downloaded place the data into the `./data` directory to match the structure below (yes, the mp3 directory is repeated).
```
├── metatdata_complete_music_data_set.json
└── mp3
    └── mp3
        ├── blues
        ├── classical
        ├── electronic
        ├── funk _ soul
        ├── hip hop
        ├── jazz
        ├── latin
        ├── pop
        ├── reggae
        └── rock
```
The following set of commands should do this:
```
cd $DOWNLOAD_LOCATION
unzip archive.zip
mv mp3/ $PARENT_DIR/music-recommendation-service/backend/data
```

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
- remove the song data and simply retrieve from Qdrant database
- add troubleshooting section