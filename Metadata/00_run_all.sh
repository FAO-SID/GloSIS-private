#!/bin/bash

clear
date=`date +%Y-%m-%d-%H-%M`
rm /home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/tmp/*
rm /home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/output/*
/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/scripts/data_cube_1_rename.sh
/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/scripts/data_cube_3_nodata.sh
/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/scripts/data_cube_4_epsg.sh
/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/scripts/data_cube_5_cog.sh
pg_dump -h localhost -p 5432 -d iso19139 -U glosis -F custom -f /home/carva014/Downloads/${date}_database_iso19139.backup
eval "$(conda shell.bash hook)"
conda activate db
psql -h localhost -p 5432 -d iso19139 -U glosis -c "DELETE FROM metadata.mapset WHERE country_id = 'BT'"
python /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/02_scan.py
rm /home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/tmp/*
rm /home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/BT/output/*.tif.aux.xml
psql -h localhost -p 5432 -d iso19139 -U glosis -F custom -f /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/03_add_metadata_BT.sql
python /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/04_table2xml.py
python /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/05_export.py
/home/carva014/Work/Code/FAO/GloSIS-private/Metadata/06_GISMGR_style.sh
# /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/07_GISMGR_map.sh
# /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/08_GISMGR_mapset.sh
# /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/09_GISMGR_upload.sh
# /home/carva014/Work/Code/FAO/GloSIS-private/Metadata/10_GISMGR_metadata.sh
