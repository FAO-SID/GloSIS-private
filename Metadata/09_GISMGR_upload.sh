#!/bin/bash


# vars
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="iso19139"
DB_USER="sis"
COUNTRY="${1}"
DATA_DIR="/home/carva014/Downloads/FAO/AFACI/$COUNTRY/output"


## Install gsutil
cd /home/carva014/Downloads/
# curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
# tar -xf google-cloud-cli-linux-x86_64.tar.gz
# ./google-cloud-sdk/install.sh
# # Manually close and restart shell, init and login
./google-cloud-sdk/bin/gcloud init
# OR
# sudo snap install google-cloud-sdk
# sudo snap install google-cloud-cli


# Copy MAPs
psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c \
    "SELECT m.mapset_id, l.layer_id||'.tif'
    FROM spatial_metadata.mapset m
    LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
    WHERE m.country_id = '$COUNTRY'
      AND l.dimension_depth IS NULL 
      AND l.dimension_stats IS NULL
    ORDER BY l.layer_id" | \
while IFS="|" read -r MAPSET FILE_NAME; do
    echo $FILE_NAME
    gsutil -mq cp ${DATA_DIR}/${FILE_NAME} gs://fao-gismgr-glosis-upload/MAP/${MAPSET}/
done


# Copy MAPSETs
echo ""
psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c \
    "SELECT m.mapset_id, l.layer_id||'.tif'
    FROM spatial_metadata.mapset m
    LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
    WHERE m.country_id = '$COUNTRY'
      AND (l.dimension_depth IS NOT NULL OR l.dimension_stats IS NOT NULL)
    ORDER BY l.layer_id" | \
while IFS="|" read -r MAPSET FILE_NAME; do
    echo $FILE_NAME
    gsutil -mq cp ${DATA_DIR}/${FILE_NAME} gs://fao-gismgr-glosis-upload/MAPSET/${MAPSET}/
done
