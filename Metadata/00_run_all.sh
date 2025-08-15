#!/bin/bash

clear

PROJECT_DIR="/home/carva014/Work/Code/FAO"
date=`date +%Y-%m-%d-%H-%M`

rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/tmp/*
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/output/*
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_1_rename.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_3_nodata.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_4_epsg.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_5_cog.sh
pg_dump -h localhost -p 5432 -d iso19139 -U glosis -n spatial_metadata -F custom -f $PROJECT_DIR/GloSIS-private/Metadata/backups/sis_database_schema_spatial_metadata_${date}.backup
eval "$(conda shell.bash hook)"
conda activate db
psql -h localhost -p 5432 -d iso19139 -U glosis -c "DELETE FROM spatial_metadata.project WHERE country_id = 'BT'"
psql -h localhost -p 5432 -d iso19139 -U glosis -c "DELETE FROM spatial_metadata.mapset WHERE country_id = 'BT'"
python $PROJECT_DIR/GloSIS-private/Metadata/02_scan.py
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/tmp/*
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/output/*.tif.aux.xml
psql -h localhost -p 5432 -d iso19139 -U glosis -F custom -f $PROJECT_DIR/GloSIS-private/Metadata/03_add_metadata_BT.sql
python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py
python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py
$PROJECT_DIR/GloSIS-private/Metadata/06_GISMGR_style.sh
# $PROJECT_DIR/GloSIS-private/Metadata/07_GISMGR_map.sh
# $PROJECT_DIR/GloSIS-private/Metadata/08_GISMGR_mapset.sh
# $PROJECT_DIR/GloSIS-private/Metadata/09_GISMGR_upload.sh
# $PROJECT_DIR/GloSIS-private/Metadata/10_GISMGR_metadata.sh
