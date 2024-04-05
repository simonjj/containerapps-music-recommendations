## About Dataset

Ludwig Music Dataset

Ludwig Music Dataset is a small MIR dataset created from Discogs and AcousticBrainZ

This dataset has been designed for the Ludwig Backend of SpotMyFM.

The .mp3 files have been downloaded from Spotify, and each filename is the associated Spotify Track ID.


## Source

This dataset was downloaded from: [https://www.kaggle.com/datasets/jorgeruizdev/ludwig-music-dataset-moods-and-subgenres/](https://www.kaggle.com/datasets/jorgeruizdev/ludwig-music-dataset-moods-and-subgenres/)


## Format

This instance of the dataset has been reshaped for friendlier loading. It is not stored as an [Apache Arrow](https://arrow.apache.org/) dataset an can be loaded via the Hugging Face [Dataset.load_from_disk method](https://huggingface.co/docs/datasets/v2.14.5/en/package_reference/main_classes#datasets.Dataset.load_from_disk). Please see the included data-prep Notebook for the process that was used.


## License

This dataset is made available under the [CC BY-NC-SA 4.0 Deed](https://creativecommons.org/licenses/by-nc-sa/4.0/)