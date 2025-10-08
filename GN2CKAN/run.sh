#!/bin/bash


# variables
clear
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN"

# conda env
eval "$(conda shell.bash hook)"
conda activate db

# copy xml's from bucket
cd /home/carva014/Downloads
./google-cloud-sdk/bin/gcloud init
gsutil -m cp gs://fao-maps-catalog-data/geonetwork_metadata/paper_maps/*.xml /home/carva014/Downloads/FAO/Metadata/input/

# add country geom table
ogr2ogr -progress \
        -overwrite \
        -skipfailures \
        -makevalid \
        -nlt POLYGON \
        -nln public.country_geom \
        -lco FID=gid \
        -lco GEOMETRY_NAME=geom \
        -lco PRECISION=NO \
        --config PG_USE_COPY YES \
        -f PostgreSQL 'PG:host=localhost port=5432 dbname=iso19139 user=sis' \
        /home/carva014/Downloads/FAO/Metadata/country_geom.gpkg \
        country_geom

# create db schema
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/1_schema.sql

# xml to db
python $PROJECT_DIR/2_xml2db.py

# fix encoding
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/fix_encoding.sql

# reset contact
psql -h localhost -p 5432 -d iso19139 -U sis -c "TRUNCATE xml2db.organisation CASCADE"
psql -h localhost -p 5432 -d iso19139 -U sis -c "TRUNCATE xml2db.individual CASCADE"
psql -h localhost -p 5432 -d iso19139 -U sis -c "INSERT INTO xml2db.organisation VALUES ('FAO-UN','https://www.fao.org/soils-portal/data-hub/soil-maps-and-databases/en/','gsp-secretariat@fao.org','Italy','Rome','00153','Viale delle Terme di Caracalla',NULL,NULL)"
psql -h localhost -p 5432 -d iso19139 -U sis -c "INSERT INTO xml2db.individual VALUES ('FAO Land and Water Division','gsp-secretariat@fao.org')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "INSERT INTO xml2db.mapset_x_org_x_ind 
                                                        SELECT m.mapset_id, o.organisation_id, i.individual_id, 'Communication', 'pointOfContact', 'pointOfContact'
                                                        FROM xml2db.mapset m, xml2db.organisation o, xml2db.individual i
                                                        ORDER BY m.mapset_id"

# clean up keyword_place (1 record)
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_place = '{Colombia}' WHERE mapset_id = 'ef9df1a0-88fd-11da-a88f-000d939bc5d8'"

# clean up publication_date (373 records)
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET publication_date = NULL WHERE publication_date = '-01-01'"

# clean up url (47 records)
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.url WHERE url NOT ILIKE 'https://storage.googleapis.com/fao-maps-catalog-data%'"

# set md_browse_graphic (914 records)
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset m SET md_browse_graphic = u.url FROM xml2db.url u WHERE m.mapset_id = u.mapset_id AND m.md_browse_graphic IS NULL AND u.protocol = 'WWW:LINK-1.0-http--link' AND u.url_name ILIKE '%thumbnail%' AND u.url_name ILIKE '%large%'"

# set distribution_format
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'jpg' WHERE mapset_id IN (SELECT mapset_id FROM xml2db.url WHERE protocol = 'WWW:DOWNLOAD-1.0-http--download');"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'paper' WHERE distribution_format IS NULL"

# set licence
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'This work is made available under the [Creative Commons Attribution 4.0 International licence (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/)'"

# clean up keyword_theme
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/fix_keyword_theme.sql

# group existing meaningful metadata
psql -h localhost -p 5432 -d iso19139 -U sis -c "TRUNCATE xml2db.soil_paper_maps"
psql -h localhost -p 5432 -d iso19139 -U sis -c "INSERT INTO xml2db.soil_paper_maps (uuid, title, year, keywords, country_name, abstract, download_url, metadata_url)
        SELECT  m.mapset_id,
                m.title,
                EXTRACT(YEAR FROM m.publication_date::date),
                REPLACE(REPLACE(REPLACE(m.keyword_theme::text,'\"',''),'{',''),'}',''),
                REPLACE(REPLACE(REPLACE(m.keyword_place::text,'\"',''),'{',''),'}',''),
                m.abstract,
                u.url,
                'https://data.apps.fao.org/catalog/iso/'||m.mapset_id
        FROM xml2db.mapset m
        LEFT JOIN xml2db.layer l ON l.mapset_id = m.mapset_id
        LEFT JOIN xml2db.url u ON u.mapset_id = m.mapset_id
        WHERE u.protocol = 'WWW:DOWNLOAD-1.0-http--download'"

# fix country names
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'China' WHERE country_name = 'China Main'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Taiwan' WHERE country_name = 'China Taiwan'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Democratic Republic of the Congo' WHERE country_name = 'Congo Dem R'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Congo' WHERE country_name = 'Congo Rep'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Dominican Republic' WHERE country_name = 'Dominican Rp'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'French Guiana' WHERE country_name = 'Fr Guiana'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Iran (Islamic Republic of)' WHERE country_name = 'Iran'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Iran (Islamic Republic of)' WHERE country_name = 'Iran Islamic Rep of'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Côte d''Ivoire' WHERE country_name = 'Ivory Coast'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Republic of Korea' WHERE country_name = 'Korea Rep'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Algeria' WHERE country_name = 'Near East and North Africa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Papua New Guinea' WHERE country_name = 'Papua N Guin'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Syrian Arab Republic' WHERE country_name = 'Syria'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'United Republic of Tanzania' WHERE country_name = 'Tanzania'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Venezuela (Bolivarian Republic of)' WHERE country_name = 'Venezuela'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Vietnam' WHERE country_name = 'VietNam'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Central African Republic' WHERE country_name = 'Cent Afr Rep'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Bolivia (Plurinational State of)' WHERE country_name = 'Bolivia'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'India' WHERE country_name = 'Asia'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps SET country_name = 'Laos' WHERE uuid = 'd7309640-88fd-11da-a88f-000d939bc5d8'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps m SET country_code = c.country_id FROM spatial_metadata.country c WHERE m.country_name = c.en"

# create random points (per map) inside countries
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.soil_paper_maps m SET geom = (SELECT ST_GeometryN(ST_GeneratePoints(c.geom, 1), 1) FROM country_geom c WHERE c.country_id = m.country_code ORDER BY ST_Area(c.geom) DESC LIMIT 1)"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DROP TABLE IF EXISTS country_geom"

# export to geopackage
# ogr2ogr -progress \
#         -overwrite \
#         -skipfailures \
#         -makevalid \
#         -nlt POINT \
#         -nln soil_paper_maps \
#         -lco FID=gid \
#         -lco GEOMETRY_NAME=geom \
#         -lco PRECISION=NO \
#         --config PG_USE_COPY YES \
#         -f GPKG /home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN/soil_paper_maps.gpkg \
#         'PG:host=localhost port=5432 dbname=iso19139 user=sis' \
#         xml2db.soil_paper_maps

# export to csv
psql -h localhost -p 5432 -U sis -d iso19139 -c "\copy (
        SELECT  uuid,
                year,
                country_code,
                country_name,
                keywords,
                title,
                abstract,
                download_url,
                metadata_url,
                ST_Y(geom) AS latitude,
                ST_X(geom) AS longitude
        FROM xml2db.soil_paper_maps
        ORDER BY country_code, title
        ) 
TO '/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN/soil_paper_maps.csv' WITH CSV HEADER"

# db to xml
python $PROJECT_DIR/3_db2xml.py
