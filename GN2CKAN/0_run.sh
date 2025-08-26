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

(paper_maps, e1c1b68a-3c61-464b-9748-6ef9821ce0d0, depth, null, e1c1b68a-3c61-464b-9748-6ef9821ce0d0, eng, ISO 19115:2003/19139, 1.0, EPSG, SOLAW Vector Data, null, null, null, null, null, null, doi, 
The ISO19115 metadata standard solaw is the preferred metadata s..., onGoing, asNeeded, null, {solaw}, {World}, {"Soil science"}, copyright, , null, grid, mapDigital, {geoscientificInformation,environment}, null, null, 
dataset, null, null, null, null)
