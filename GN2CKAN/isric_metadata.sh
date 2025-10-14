#!/bin/sh


# variables
clear
PROJECT_DIR="/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN"
input_dir=/home/carva014/Downloads/FAO/Metadata/isric
output_dir=/home/carva014/Downloads/FAO/Metadata/input

# conda env
eval "$(conda shell.bash hook)"
conda activate db

mkdir -p "$output_dir"

find "$input_dir" -type f -path "*/metadata/metadata.xml" | while read -r f; do
  uuid=$(basename "$(dirname "$(dirname "$f")")")
  cp "$f" "$output_dir/${uuid}.xml"
done

# create db schema
psql -h localhost -p 5432 -d iso19139 -U sis -f $PROJECT_DIR/1_schema.sql

# drop constraints
psql -h localhost -p 5432 -d iso19139 -U sis -c " ALTER TABLE xml2db.url DROP CONSTRAINT url_protocol_check;
                                                  ALTER TABLE xml2db.mapset DROP CONSTRAINT mapset_status_check;
                                                  ALTER TABLE xml2db.layer DROP CONSTRAINT layer_distance_uom_check;
                                                  ALTER TABLE xml2db.mapset DROP CONSTRAINT mapset_access_constraints_check;
                                                  ALTER TABLE xml2db.mapset_x_org_x_ind DROP CONSTRAINT mapset_x_org_x_ind_role_check;"

# xml to db
python $PROJECT_DIR/2_xml2db.py

# delete isric HWSD metadata
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset WHERE mapset_id = 'bda461b1-2f35-4d0c-bb16-44297068e10d'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset WHERE mapset_id = '54aebf11-ec73-4ff8-bf6c-ecff4b0725ea'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.organisation WHERE organisation_id NOT IN (SELECT organisation_id FROM xml2db.mapset_x_org_x_ind)"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.individual WHERE individual_id NOT IN (SELECT individual_id FROM xml2db.mapset_x_org_x_ind)"

# clean up contacts
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET organisation_id = 'ISRIC - World Soil Information' WHERE organisation_id = 'ISRIC - World Soil Information (WDC - Soils)'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Data infodesk' WHERE individual_id = 'Custodian'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Data infodesk' WHERE individual_id = 'Ulan Turdukulov'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Data infodesk' WHERE individual_id = 'None'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Data infodesk' WHERE individual_id = 'Data info desk'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis de Sousa' WHERE individual_id = 'Luis de |Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis de Sousa' WHERE individual_id = 'Luís Moreira de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis de Sousa' WHERE individual_id = 'Luid de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis de Sousa' WHERE individual_id = 'luis de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis de Sousa' WHERE individual_id = 'Luis M. de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Luis Calisto' WHERE individual_id = 'Luis Callisto'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET individual_id = 'Maria Gonzalez Ruiperez' WHERE individual_id = 'Maria Ruiperez Gonzalez'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Communication' WHERE individual_id = 'Data infodesk'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Communication' WHERE individual_id = 'ISCN support'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Remote sensing' WHERE individual_id = 'Harm Bartholomeus'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Soil mapping specialist' WHERE individual_id = 'Laura Poggio'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Database expert' WHERE individual_id = 'Luis Calisto'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Senior soil scientist' WHERE individual_id = 'Niels Batjes'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'GIS technician' WHERE individual_id = 'Betony Colman'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Guest researcher' WHERE individual_id = 'Luis de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Soil laboratory expert' WHERE individual_id = 'Ad van Oostrum'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Soil mapping specialist' WHERE individual_id = 'Bas Kempen'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Geoinformatic' WHERE individual_id = 'Eloi Ribeiro'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Senior Scientist' WHERE individual_id = 'Gerard Heuvelink'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Remote Sensing' WHERE individual_id = 'Maria Gonzalez Ruiperez'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Sustainable land management' WHERE individual_id = 'Stephan Mantel'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Soil mapping specialist' WHERE individual_id = 'Tom Hengl'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Soil mapping specialist' WHERE individual_id = 'Maria Eliza Turek'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET position = 'Database expert' WHERE individual_id = 'Piet Tempel'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'author' WHERE role = 'Author'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'author' WHERE role = 'author_1'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'author' WHERE role = 'author_2'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'author' WHERE role = 'author_3'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'owner' WHERE role = 'Owner'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET role = 'principalInvestigator' WHERE role = 'Principal investigator'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.organisation WHERE organisation_id NOT IN (SELECT organisation_id FROM xml2db.mapset_x_org_x_ind)"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.individual WHERE individual_id NOT IN (SELECT individual_id FROM xml2db.mapset_x_org_x_ind)"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET url = 'https://isric.org' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET email = 'data@isric.org' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET country = 'Netherlands' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET city = 'Wageningen' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET postal_code = '6708 PB' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET delivery_point = 'Droevendaalsesteeg 3, Building 101' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET phone = '+31 317 483 735' WHERE organisation_id = 'ISRIC - World Soil Information'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET facsimile = NULL WHERE organisation_id = 'ISRIC - World Soil Information'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET url = 'https://iscn.fluxdata.org' WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET email = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET country = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET city = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET postal_code = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET delivery_point = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET phone = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET facsimile = NULL WHERE organisation_id = 'ISCN - International Soil Carbon Network'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET url = 'https://www.wur.nl' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET email = NULL WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET country = 'Netherlands' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET city = 'Wageningen' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET postal_code = '6708 PB' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET delivery_point = 'Droevendaalsesteeg 4' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET phone = '+31 317 480 100' WHERE organisation_id = 'Wageningen University'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET facsimile = NULL WHERE organisation_id = 'Wageningen University'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET url = NULL WHERE url IN ('None','UNKNOWN')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET postal_code = NULL WHERE postal_code IN ('None','UNKNOWN')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET delivery_point = NULL WHERE delivery_point IN ('None','UNKNOWN')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET phone = NULL WHERE phone IN ('None','UNKNOWN')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.organisation SET facsimile = NULL WHERE facsimile IN ('None','UNKNOWN')"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'betony.colman@isric.org' WHERE individual_id = 'Betony Colman'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'harm.bartholomeus@wur.nl' WHERE individual_id = 'Harm Bartholomeus'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'laura.poggio@isric.org' WHERE individual_id = 'Laura Poggio'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'luis.callisto@isric.org' WHERE individual_id = 'Luis Calisto'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'niels.batjes@isric.org' WHERE individual_id = 'Niels Batjes'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'eloi.ribeiro@fao.org' WHERE individual_id = 'Eloi Ribeiro'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'tom.hengl@opengeohub.org' WHERE individual_id = 'Tom Hengl'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'casparit@landcareresearch.co.nz' WHERE individual_id = 'Thomas Caspari'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'maria.ruiperezgonzalez@wur.nl' WHERE individual_id = 'Maria Gonzalez Ruiperez'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'stephan.mantel@isric.org' WHERE individual_id = 'Stephan Mantel'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'gerard.heuvelink@isric.org' WHERE individual_id = 'Gerard Heuvelink'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'luis.moreira.de.sousa@tecnico.ulisboa.pt' WHERE individual_id = 'Luis de Sousa'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'erik.vandenbergh@wur.nl' WHERE individual_id = 'Erik van den Berg'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'konstantin.ivushkin@wur.nl' WHERE individual_id = 'Konstantin Ivushkin'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'mariaelizaturek@gmail.com' WHERE individual_id = 'Maria Eliza Turek'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'tiagobramos@tecnico.ulisboa.pt' WHERE individual_id = 'Tiago Ramos'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'ad.vanoostrum@wur.nl' WHERE individual_id = 'Ad van Oostrum'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'iscnchair@gmail.com' WHERE individual_id = 'Jennifer Harden'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'r.nijbroek@cgiar.org' WHERE individual_id = 'Ravic Nijbroek'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.individual SET email = 'data@isric.org' WHERE individual_id IN ('Jan R.M. Huting','Peter N Macharia','J.A. Dijkshoorn','W .G. Sombroek','R.T.A. Hakkeling','Godert van Lynden','L.R. Oldeman','Piet Tempel','Koos Dijkshoorn')"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET tag = 'pointOfContact' WHERE mapset_id = 'b3d7c844-cbee-4b0f-8431-3a9373f5a59a'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset_x_org_x_ind SET tag = 'pointOfContact' WHERE mapset_id = '3cc719a6-cbf5-4bc8-94c3-cd7d2b3db3c3'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset_x_org_x_ind 
                                                  WHERE tag = 'contact' 
                                                    AND mapset_id IN ('c59d0162-a258-4210-af80-777d7929c512',
                                                                      'c59d0162-a258-4210-af80-777d7929c512',
                                                                      '5017fe43-061e-44de-bd8b-70d8d75b8f41',
                                                                      '1027fe43-061e-4cde-bd8b-7bd8d7338f4a')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset_x_org_x_ind 
                                                  WHERE role = 'pointOfContact' 
                                                    AND mapset_id IN ('1027fe43-061e-4cde-bd8b-7bd8d7338f4a')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset_x_org_x_ind 
                                                  WHERE position = 'Communication' 
                                                    AND mapset_id IN ('40aa2d28-19ae-11e9-b588-a0481ca9e724')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.mapset_x_org_x_ind WHERE individual_id = 'Data infodesk'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "INSERT INTO xml2db.mapset_x_org_x_ind
                                                  SELECT mapset_id, 'ISRIC - World Soil Information', 'Data infodesk', 'Communication', 'contact', 'pointOfContact' FROM xml2db.mapset"

# fix url protocol
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE protocol = 'DOI'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'OGC:WMS' WHERE protocol = 'OGC:WMS-1.3.0-http-get-capabilities'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE protocol = 'image/tiff; application=geotiff'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE protocol = 'WWW:DOWNLOAD-1.0-ftp--download'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE protocol = 'WWW:DOWNLOAD-1.0-http--download'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE url ILIKE 'https://storage.googleapis.com/isric-share-soilgrids%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET protocol = 'WWW:LINK-1.0-http--link' WHERE url ILIKE 'https://files.isric.org/soilgrids/%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "DELETE FROM xml2db.url WHERE protocol = 'None'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = '#thumbnail#' WHERE url_name ILIKE '#thumbnail# - ERROR: no %'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download data'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download zip'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download zipped dataset'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download GeoTIFF at depth'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download (WebDAV)'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Download' WHERE url_name = 'Download v1.2'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'FAQ' WHERE url_name = 'FAQ project webpage'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'FAQ' WHERE url_name = 'Project webpage (FAQ)'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'FAQ' WHERE url_name = 'Project webpage (FAQ)'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'FAQ' WHERE url_name = 'WoSIS FAQ webpage'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'FAQ' WHERE url_name = 'Project webpage (FAQ WoSIS)'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Scientific paper' WHERE url_name = 'Scientific Paper'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Scientific paper' WHERE url_name = 'Scientific publication (Turek et al. 2021)'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = 'Scientific paper' WHERE url_name = 'Article'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url_name = ':'||url_name WHERE protocol IN ('OGC:WCS','OGC:WFS','OGC:WMS') AND url_name NOT ILIKE ':%'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url = 'https://files.isric.org/public/other/WD-ICRAF-Spectral_MIR.zip' WHERE mapset_id = '1b65024a-cd9f-11e9-a8f9-a0481ca9e724' AND url = 'https://files.isric.org/public/other/'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url = 'https://files.isric.org/public/other/ICRAF-ISRICVNIRSoilDatabase.zip' WHERE mapset_id = '1081ac75-78f7-4db3-b8cc-23b78a3aa769' AND url = 'https://files.isric.org/public/other/'"

# fix status
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET status = 'completed' WHERE status = 'Completed'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET status = 'onGoing' WHERE status = 'ongoing'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET status = 'onGoing' WHERE status = 'On going'"

# fix access_constraints
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET access_constraints = 'license' WHERE access_constraints = 'License'"

# other_constraints
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-4.0' WHERE other_constraints = 'Attribution 4.0 International (CC BY 4.0), https://creativecommons.org/licenses/by/4.0/'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-3.0' WHERE other_constraints = 'Attribution-NonCommercial 3.0 International (CC BY-NC 3.0), https://creativecommons.org/licenses/by-nc/3.0/'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-SA-4.0' WHERE other_constraints = 'Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0), https://creativecommons.org/licenses/by-nc-sa/4.0/'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC0-1.0' WHERE other_constraints = 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication, https://creativecommons.org/publicdomain/zero/1.0/deed.en'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-SA-4.0' WHERE other_constraints = 'http://coral.ufsm.br/febr/politica-de-dados/'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-4.0' WHERE other_constraints = 'Licenced per profile, as specified by data provider and indicated in the data'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-4.0' WHERE other_constraints = 'Licenced per profile, as specified by data provider and indicated in the data (CC-BY or CC-BY-NC)'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-NC-4.0' WHERE other_constraints = 'Licenced per profile, as specified by data provider and indicated in the data set'"
# psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET other_constraints = 'CC-BY-4.0' WHERE other_constraints = 'U.S. Public Domain http://www.usa.gov/publicdomain/label/1.0/'"

# fix distance_uom
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distance_uom = 'arc-minutes' WHERE distance_uom = 'minutes'"

# fix language_code
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET language_code = 'eng'"

# fix metadata_standard_name
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET metadata_standard_name = 'ISO 19115:2003/19139'"

# fix md_browse_graphic
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset m SET md_browse_graphic = u.url FROM xml2db.url u WHERE u.mapset_id = m.mapset_id AND u.url_name = '#thumbnail#'"

# fix dates
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset m SET creation_date = publication_date WHERE creation_date IS NULL"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset m SET revision_date = publication_date WHERE revision_date IS NULL"

# fix keyword_theme
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'electrical conductivy', 'electrical conductivity')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'salinisation', 'salinity')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'soil carbon', 'carbon')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'spectroscopy data', 'spectral')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'total nitrogen', 'nitrogen')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'Volumetric Water Content', 'volumetric water content')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'calcium carbonate', 'calcium')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_replace(keyword_theme, 'physical deterioration', 'land degradation')"

# add keyword
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = array_append(keyword_theme, 'isric')"

# removed repeated
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(DISTINCT unnested_value) FROM unnest(keyword_theme) AS unnested_value)"
# remove keywords
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'chemical deterioration')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'physical deterioration')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'degradation status')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'wosis')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'soilgrids')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'site locations')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'thermal')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'landsat')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'global map')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'colour')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'organic')"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET keyword_theme = (SELECT array_agg(x) FROM unnest(keyword_theme) AS x WHERE x != 'root zone')"

# fix reference_system_identifier_code
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET reference_system_identifier_code = '3035' WHERE reference_system_identifier_code = 'urn:ogc:def:crs:EPSG:3035'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET reference_system_identifier_code = '4326' WHERE reference_system_identifier_code = 'urn:ogc:def:crs:EPSG:4326'"

# fix distribution_format
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE distribution_format = 'image/tiff; application=geotiff+cog'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE distribution_format = 'TIF'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE distribution_format = 'GTiff'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'zip' WHERE distribution_format = 'Niels Batjes'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'zip' WHERE distribution_format = 'Niels H. Batjes'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'zip' WHERE distribution_format = 'TSV and Geopackage'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE mapset_id = '5017fe43-061e-44de-bd8b-70d8d75b8f41'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE mapset_id = 'b3d7c844-cbee-4b0f-8431-3a9373f5a59a'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'GeoTiff' WHERE mapset_id = '3cc719a6-cbf5-4bc8-94c3-cd7d2b3db3c3'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'zip' WHERE mapset_id = '71203238-9817-4a4e-a626-6e89a47d501a'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.layer SET distribution_format = 'zip' WHERE mapset_id = '1027fe43-061e-4cde-bd8b-7bd8d7338f4a'"

# enable constrainsts
psql -h localhost -p 5432 -d iso19139 -U sis -c " ALTER TABLE xml2db.url ADD CONSTRAINT url_protocol_check CHECK ((protocol = ANY (ARRAY['OGC:WFS','OGC:WCS','OGC:WMS','OGC:WMTS','WWW:LINK-1.0-http--link', 'WWW:LINK-1.0-http--related', 'WWW:DOWNLOAD-1.0-http--download', 'OGC:WMS-1.1.1-http-get-map'])));
                                                  ALTER TABLE xml2db.mapset ADD CONSTRAINT mapset_status_check CHECK ((status = ANY (ARRAY['completed', 'historicalArchive', 'obsolete', 'onGoing', 'planned', 'required', 'underDevelopment'])));
                                                  ALTER TABLE xml2db.layer ADD CONSTRAINT layer_distance_uom_check CHECK ((distance_uom = ANY (ARRAY['m', 'km', 'deg','arc-minutes','arc-second'])));
                                                  ALTER TABLE xml2db.mapset ADD CONSTRAINT mapset_access_constraints_check CHECK ((access_constraints = ANY (ARRAY['copyright', 'patent', 'patentPending', 'trademark', 'license', 'intellectualPropertyRights', 'restricted','otherRestrictions'])));
                                                  ALTER TABLE xml2db.mapset_x_org_x_ind ADD CONSTRAINT mapset_x_org_x_ind_role_check CHECK ((role = ANY (ARRAY['author', 'custodian', 'distributor', 'originator', 'owner', 'pointOfContact', 'principalInvestigator', 'processor', 'publisher', 'resourceProvider', 'user'])));"

# fix & < >
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.url SET url = REPLACE(url, '&', '&amp;') WHERE url ILIKE '%&%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET md_browse_graphic = REPLACE(md_browse_graphic, '&', '&amp;') WHERE md_browse_graphic ILIKE '%&%'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET title = REPLACE(title, '&', '&amp;') WHERE title ILIKE '%&%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET title = REPLACE(title, '<', '&lt;') WHERE title ILIKE '%<%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET title = REPLACE(title, '>', '&gt;') WHERE title ILIKE '%>%'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET abstract = REPLACE(abstract, '&', '&amp;') WHERE abstract ILIKE '%&%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET abstract = REPLACE(abstract, '<', '&lt;') WHERE abstract ILIKE '%<%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET abstract = REPLACE(abstract, '>', '&gt;') WHERE abstract ILIKE '%>%'"

psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET lineage_statement = REPLACE(lineage_statement, '&', '&amp;') WHERE lineage_statement ILIKE '%&%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET lineage_statement = REPLACE(lineage_statement, '<', '&lt;') WHERE lineage_statement ILIKE '%<%'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET lineage_statement = REPLACE(lineage_statement, '>', '&gt;') WHERE lineage_statement ILIKE '%>%'"

# lineage
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET lineage_statement = '- 2021 March (v1.2): Minor changes were applied for SAN class, i.e. &gt;70% and &lt;8% clay in top 0-30 cm; rules were applied to 184 map units flagged as DIFF in column [FLAGsan], see also column [SANDYclass] in the MS Acess file. This change applied to 184 out of a total of 16108 map units; further details are provided in Report 2009/02.
- Batjes NH 2009. IPCC default soil classes derived from the Harmonized World Soil Data Base, ver. 1.0. Report 2009/02, Carbon Benefits Project and ISRIC - World Soil Information, Wageningen, with dataset. https://www.isric.org/sites/default/files/isric_report_2009_02.pdf'
WHERE mapset_id = '41cb0ae9-1604-4807-96e6-0dc8c94c5d22'"
psql -h localhost -p 5432 -d iso19139 -U sis -c "UPDATE xml2db.mapset SET lineage_statement = 'Data quality information not available' WHERE lineage_statement IS NULL"

# db to xml
python $PROJECT_DIR/3_db2xml.py

# xml to CKAN
$PROJECT_DIR/4_xml2ckan.sh
