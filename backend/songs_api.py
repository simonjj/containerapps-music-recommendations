#!/usr/bin/env python
from fastapi import FastAPI
from fastapi.responses import FileResponse
from typing import Optional
from typing import List
from pydantic import BaseModel
import pandas as pd
from qdrant_client import QdrantClient
import os
import logging

logging.basicConfig(level=logging.INFO)


QDRANT_HOST = os.environ.get('QDRANT_HOST')
if not QDRANT_HOST:
    QDRANT_HOST = "qdrantdb-demo"
QCLIENT = QdrantClient(host=QDRANT_HOST, port=6333)
METADATA = None

app = FastAPI()

@app.on_event("startup")
async def load_data_and_config():
    global METADATA
    logging.info("Connecting to QdrantDB at %s:6333", QDRANT_HOST)
    METADATA = pd.read_json("./data/metatdata_complete_music_data_set.json")
    logging.info("loaded metadata")
    

class Song(BaseModel):
    ids: str
    name: str
    artist: str
    genre: str

class Recommendation(Song):
    score: str


@app.get('/songs', response_model=List[Song])
async def list_songs(artist: Optional[str] = None, genre: Optional[str] = None):
    """
    This function handles GET requests to the /songs endpoint. 
    It filters the global METADATA based on the provided artist and genre parameters and returns the matching songs.
    """
    # Stubbed song list
    global METADATA
    result = METADATA[["ids","name","artist","genre"]]
    if artist:
        result = result[result["artist"] == artist]
    if genre:
        result = result[result["genre"] == genre]
    if result.empty:
        return []
    else:
        return result.to_dict(orient='records')


@app.get('/songs/play/{song_id}', responses={200: {"content": {"audio/mpeg": {}}}})
async def get_song(song_id: str):
    # Stubbed song file path
    song_file_path = METADATA.loc[METADATA['ids'] == song_id]['urls'].values[0]
    return FileResponse(song_file_path, media_type='audio/mpeg')


@app.get('/songs/recommend/{song_id}', response_model=List[Recommendation])
async def recommend(song_id: str, recommendation_limit: int = 3):
    """
    This function handles GET requests to the /songs/recommend/{song_id} endpoint. 
    It uses the Qdrant client to fetch song recommendations based on the provided song_id.
    """
    global METADATA, QCLIENT
    qdrant_id = int(METADATA.loc[METADATA['ids'] == song_id]['index'].values[0])
    recommendations = None
    try:
        recommendations = QCLIENT.recommend(
                            collection_name="my_collection", 
                            positive=[qdrant_id], limit=recommendation_limit
                    )
    except Exception as e:
        logging.error("Error in recommendation: %s", e)
        return []
    result = []
    # prep the result to match the schema
    for rec in recommendations:
        score = rec.score
        payload = rec.payload
        del payload["index"]
        del payload["subgenres"]
        del payload["urls"]
        payload['score'] = str(score)
        result.append(payload)
    return result
    
   