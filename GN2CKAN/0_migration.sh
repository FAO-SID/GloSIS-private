#!/bin/bash



cd //home/carva014/Downloads
./google-cloud-sdk/bin/gcloud init
gsutil -m cp gs://fao-maps-catalog-data/geonetwork_metadata/paper_maps/*.xml /home/carva014/Downloads/FAO/Metadata/




