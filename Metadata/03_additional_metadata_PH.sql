-- project
INSERT INTO spatial_metadata.project (country_id, project_id, project_name) VALUES 
('PH', 'GSAS', 'Global Salt-Affected Soils'),
('PH', 'GSNM', 'Global Soil Nutrients Map'),
('PH', 'GSOCSEQ', 'Global Soil Organic Carbon Sequestration potential map')
ON CONFLICT (country_id, project_id) DO NOTHING;


-- dates
UPDATE spatial_metadata.mapset SET creation_date = '2020-08-01', publication_date = '2020-08-01', revision_date = '2020-08-01' WHERE country_id = 'PH' AND project_id = 'GSAS';
UPDATE spatial_metadata.mapset SET creation_date = '2023-12-01', publication_date = '2023-12-01', revision_date = '2023-12-01' WHERE country_id = 'PH' AND project_id = 'GSNM';
UPDATE spatial_metadata.mapset SET creation_date = '2021-05-01', publication_date = '2021-05-01', revision_date = '2021-05-01' WHERE country_id = 'PH' AND project_id = 'GSOCSEQ';


-- unit_of_measure_id
UPDATE spatial_metadata.mapset m
SET unit_of_measure_id = p.unit_of_measure_id 
FROM spatial_metadata.property p
WHERE m.country_id = 'PH'
  AND m.unit_of_measure_id IS NULL
  AND m.property_id = p.property_id;


-- title
UPDATE spatial_metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, p.name||' ('||coalesce(c.en,'')||' - '||coalesce(p.unit_of_measure_id,'')||' - '||coalesce(l.distance,'')||' '||coalesce(l.distance_uom,'')||' - '||coalesce(EXTRACT( YEAR FROM m.creation_date)::text,'')||')' AS title
            FROM spatial_metadata.mapset m
            LEFT JOIN spatial_metadata.property p ON p.property_id = m.property_id
            LEFT JOIN spatial_metadata.country c ON c.country_id = m.country_id
            LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'PH';


-- citation
UPDATE spatial_metadata.mapset
    SET citation_md_identifier_code = 'https://doi.org/10.4060/cb9002en', 
        citation_md_identifier_code_space = 'doi'
WHERE country_id = 'PH'
  AND project_id = 'GSOCSEQ';


-- abstract
UPDATE spatial_metadata.mapset m SET abstract = t.abstract
    FROM (SELECT DISTINCT property_id, replace(abstract,'Philippines','Bhutan') AS abstract FROM spatial_metadata.mapset WHERE abstract IS NOT NULL) t
    WHERE m.country_id = 'PH' AND m.property_id = t.property_id;


-- browse_graphic
UPDATE spatial_metadata.mapset m
SET md_browse_graphic = l.md_browse_graphic
FROM (
    SELECT mapset_id, 
        'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;VERSION=1.3.0&amp;REQUEST=GetMap&amp;BBOX='||east_bound_longitude||'%2C'||north_bound_latitude||'%2C'||west_bound_longitude||'%2C'||south_bound_latitude||'&amp;CRS=EPSG%3A4326&amp;WIDTH=762&amp;HEIGHT=1228&amp;LAYERS='||layer_id||'&amp;STYLES=&amp;FORMAT=image%2Fpng&amp;DPI=96&amp;MAP_RESOLUTION=96&amp;FORMAT_OPTIONS=dpi%3A96&amp;TRANSPARENT=TRUE' AS md_browse_graphic
    FROM spatial_metadata.layer
) l
WHERE m.mapset_id = l.mapset_id AND m.country_id = 'PH';


-- keywords
UPDATE spatial_metadata.mapset SET keyword_place = '{Philippines}'::text[] WHERE country_id = 'PH';
UPDATE spatial_metadata.mapset m SET keyword_theme = p.keyword_theme FROM spatial_metadata.property p WHERE country_id = 'PH' AND m.property_id = p.property_id;


-- licence
UPDATE spatial_metadata.mapset SET other_constraints = 'Creative Commons Attribution 4.0 International licence (CC-BY-4.0)' WHERE country_id = 'PH';


-- time period
UPDATE spatial_metadata.mapset SET time_period_begin = '1960-01-01' WHERE country_id = 'PH';
UPDATE spatial_metadata.mapset SET time_period_end = '2020-12-31' WHERE country_id = 'PH';


-- lineage
UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cc1717en'
WHERE country_id = 'PH'
  AND project_id = 'GSNM';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cb2642en'
WHERE country_id = 'PH'
  AND project_id = 'GSOCSEQ';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/ca9215en'
WHERE country_id = 'PH'
  AND project_id = 'GSAS';


-- insert organisation
INSERT INTO spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point) VALUES
    ('Departement of Agriculture - Bureau of Soils and Water Management','http://www.bswm.da.gov.ph','customers.center@bswm.da.gov.ph','Philippines','Quezon','1128','SRDC Bldg. Elliptical Road corner Visayas Avenue, Diliman')
    ON CONFLICT (organisation_id) DO NOTHING;


-- insert individual
INSERT INTO spatial_metadata.individual (individual_id, email) VALUES
    ('Andrew B. Flores','andrew.flores@bswm.da.gov.ph')
    ON CONFLICT (individual_id) DO NOTHING;


-- insert proj_x_org_x_ind
INSERT INTO spatial_metadata.proj_x_org_x_ind (country_id, project_id, tag, "role", "position", organisation_id, individual_id)
    SELECT DISTINCT country_id, project_id, 'contact', 'resourceProvider', 'Science Research Specialist', 'Departement of Agriculture - Bureau of Soils and Water Management', 'Andrew B. Flores' FROM spatial_metadata.project WHERE country_id = 'PH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Science Research Specialist', 'Departement of Agriculture - Bureau of Soils and Water Management', 'Andrew B. Flores' FROM spatial_metadata.project WHERE country_id = 'PH'
    ON CONFLICT (country_id, project_id, tag, role, "position", organisation_id, individual_id) DO NOTHING;


-- insert url
INSERT INTO spatial_metadata.url (mapset_id, protocol, url, url_name)
    -- SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', url_paper, 'Scientific paper' FROM spatial_metadata.metadata_manual WHERE url_paper IS NOT NULL
    --     UNION
    SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', 'https://www.fao.org/global-soil-partnership/resources/highlights/detail/en/c/1471478/', 'Project webpage' FROM spatial_metadata.mapset WHERE project_id = 'GSOCSEQ' AND country_id = 'PH'
            UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAP/'||'GLOSIS.'||l.mapset_id||','||l.file_extension , 'Download '||l.dimension_des 
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE l.mapset_id IN (SELECT mapset_id FROM spatial_metadata.layer GROUP BY mapset_id HAVING count(*)=1) AND m.country_id = 'PH'
            UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_des||'.'||l.file_extension , 'Download '||l.dimension_des 
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE l.mapset_id IN (SELECT mapset_id FROM spatial_metadata.layer GROUP BY mapset_id HAVING count(*)>1) AND m.country_id = 'PH'
            UNION
    SELECT mapset_id, 'OGC:WMTS', 'https://data.apps.fao.org/map/wmts/wmts?service=WMTS&amp;request=GetCapabilities&amp;version=1.0.0&amp;workspace=GLOSIS', 'WMTS (FAO)' FROM spatial_metadata.mapset WHERE country_id = 'PH'
        UNION
    SELECT mapset_id, 'OGC:WMTS', 'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;REQUEST=GetCapabilities', 'WMTS (Philippines SIS)' FROM spatial_metadata.layer WHERE layer_id LIKE 'BT-%'
    ON CONFLICT (mapset_id, protocol, url) DO NOTHING;


-- categorical class
INSERT INTO spatial_metadata."class" (mapset_id, value, code, "label", color, opacity, publish) VALUES
('PH-GSAS-SALT-2020', -9999, '-9999', '-9999 - No Data', '#000000',1, 't'),
('PH-GSAS-SALT-2020', 1, '1', '1 - No salinity', '#ffffff',1, 't'),
('PH-GSAS-SALT-2020', 2, '2', '2 - Slight Salinity', '#90ee90',1, 't'),
('PH-GSAS-SALT-2020', 3, '3', '3 - Slight Sodicity', '#add8e6',1, 't')
 ON CONFLICT (mapset_id, value) DO NOTHING;


-- INSERT INTO spatial_metadata."class" (mapset_id, value, code, "label", color, opacity, publish) VALUES
-- ('SALT', -1.0, '-1', 'No Data', '#000000', 1, 't'),
-- ('SALT', 4.0, '4', '4 - None', '#ffffff', 1, 't'),
-- ('SALT', 6.0, '6', '6 - Slight Salinity', '#90ee90', 1, 't'),
-- ('SALT', 2.0, '2', '2 - Moderate Salinity', '#f5deb3', 1, 't'),
-- ('SALT', 8.0, '8', '8 - Strong Salinity', '#f08080', 1, 't'),
-- ('SALT', 10.0, '10', '10 - Very Strong Salinity', '#f84040', 1, 't'),
-- ('SALT', 1.0, '1', '1 - Extreme Salinity', '#ff0000', 1, 't'),
-- ('SALT', 5.0, '5', '5 - Saline Sodic', '#00ffff', 1, 't'),
-- ('SALT', 7.0, '7', '7 - Slight Sodicity', '#add8e6', 1, 't'),
-- ('SALT', 3.0, '3', '3 - Moderate Sodicity', '#ee82ee', 1, 't'),
-- ('SALT', 9.0, '9', '9 - Strong Sodicity', '#da70d6', 1, 't'),
-- ('SALT', 11.0, '11', '11 - Very Strong Sodicity', '#800080', 1, 't');
