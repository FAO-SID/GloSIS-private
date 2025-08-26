#!/bin/bash


# variables
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN"


# copy xml's from bucket
cd /home/carva014/Downloads
./google-cloud-sdk/bin/gcloud init
gsutil -m cp gs://fao-maps-catalog-data/geonetwork_metadata/paper_maps/*.xml /home/carva014/Downloads/FAO/Metadata/


# create db schema
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/1_schema.sql


# xml to db
eval "$(conda shell.bash hook)"
conda activate db
python $PROJECT_DIR/2_xml2db.py

