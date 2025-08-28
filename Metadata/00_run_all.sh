#!/bin/bash

# variables
COUNTRY="BT"
PROJECT_DIR="/home/carva014/Work/Code/FAO"
INPUT_DIR="$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output"
DATE=`date +%Y-%m-%d`

clear

# reset
rm -Rf $PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/tmp
rm -Rf $PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output

# process GeoTIFF's
$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_1_rename.sh
$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_2_check.sh
$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_3_nodata.sh
# $PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_2_check.sh
$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_4_epsg.sh
$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/scripts/data_cube_5_cog.sh
rm -Rf $PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/tmp

# add files to the database
eval "$(conda shell.bash hook)"
conda activate db
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM spatial_metadata.project WHERE country_id = '$COUNTRY'"
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/GloSIS-private/Metadata/01_add_property.sql
python $PROJECT_DIR/GloSIS-private/Metadata/02_scan.py $INPUT_DIR
rm $PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output/*.tif.aux.xml
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/GloSIS-private/Metadata/03_add_metadata_$COUNTRY.sql

# produce the metadata
# python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py "$COUNTRY" "GSAS"
python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py "$COUNTRY" "GSOC"
python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py "$COUNTRY" "GSNM"
python $PROJECT_DIR/GloSIS-private/Metadata/04_table2xml.py "$COUNTRY" "OTHER"

# export metadata (xml) mapfiles (map) and symbology (sld)
# python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py "$COUNTRY" "GSAS" "$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output"
python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py "$COUNTRY" "GSOC" "$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output"
python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py "$COUNTRY" "GSNM" "$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output"
python $PROJECT_DIR/GloSIS-private/Metadata/05_export.py "$COUNTRY" "OTHER" "$PROJECT_DIR/GloSIS/glosis-datacube/$COUNTRY/output"

# create or update (if existis) symbology in GISMGR
$PROJECT_DIR/GloSIS-private/Metadata/06_GISMGR_style.sh

# create or update (if existis) map in GISMGR
$PROJECT_DIR/GloSIS-private/Metadata/07_GISMGR_map.sh

# create or update (if existis) mapset in GISMGR
$PROJECT_DIR/GloSIS-private/Metadata/08_GISMGR_mapset.sh

# upload GeoTIFF's to bucket
$PROJECT_DIR/GloSIS-private/Metadata/09_GISMGR_upload.sh

# upload metadata to CKAN
$PROJECT_DIR/GloSIS-private/Metadata/10_GISMGR_metadata.sh

# backup database
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
