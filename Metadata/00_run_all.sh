#!/bin/bash

# variables
PROJECT_DIR="/home/carva014/Work/Code/FAO"
DATE=`date +%Y-%m-%d`

clear

rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/tmp/*
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/output/*
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_1_rename.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_3_nodata.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_4_epsg.sh
$PROJECT_DIR/GloSIS/glosis-datacube/BT/scripts/data_cube_5_cog.sh
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/tmp/*
eval "$(conda shell.bash hook)"
conda activate db
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM spatial_metadata.project WHERE country_id = 'BT'"
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/GloSIS-private/Metadata/01_add_property.sql
python $PROJECT_DIR/GloSIS-private/Metadata/02_scan.py
rm $PROJECT_DIR/GloSIS/glosis-datacube/BT/output/*.tif.aux.xml
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/GloSIS-private/Metadata/03_add_metadata_BT.sql
python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py
python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py
$PROJECT_DIR/GloSIS-private/Metadata/06_GISMGR_style.sh
# $PROJECT_DIR/GloSIS-private/Metadata/07_GISMGR_map.sh
# $PROJECT_DIR/GloSIS-private/Metadata/08_GISMGR_mapset.sh
# $PROJECT_DIR/GloSIS-private/Metadata/09_GISMGR_upload.sh
# $PROJECT_DIR/GloSIS-private/Metadata/10_GISMGR_metadata.sh

pg_dump -h localhost -p 5432 -d iso19139 -U sis -F custom -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/iso19139_backup_${DATE}.backup
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F custom -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/iso19139_backup_latest.backup
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.country --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_country_${DATE}.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.country --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_country_latest.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.property --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_property_${DATE}.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.property --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_property_latest.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.organisation --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_organisation_${DATE}.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.organisation --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_organisation_latest.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.individual --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_individual_${DATE}.sql
pg_dump -h localhost -p 5432 -d iso19139 -U sis -F plain -t spatial_metadata.individual --data-only --column-inserts -v -f $PROJECT_DIR/GloSIS-private/Metadata/backups/data_individual_latest.sql
