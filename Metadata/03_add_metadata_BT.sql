-- title
UPDATE metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, p.name||' ('||c.en||' - '||l.distance||' '||l.distance_uom||')' AS title
            FROM metadata.mapset m
            LEFT JOIN metadata.property p ON p.property_id = m.property_id
            LEFT JOIN metadata.country c ON c.country_id = m.country_id
            LEFT JOIN metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'BT';


-- dates
UPDATE metadata.mapset SET creation_date = '2021-12-17', publication_date = '2021-12-17', revision_date = '2021-12-17' WHERE country_id = 'BT' AND project_id = 'GSAS';
UPDATE metadata.mapset SET creation_date = '2024-03-28', publication_date = '2024-03-28', revision_date = '2024-03-28' WHERE country_id = 'BT' AND project_id = 'GSNM';
UPDATE metadata.mapset SET creation_date = '2022-11-11', publication_date = '2022-11-11', revision_date = '2022-11-11' WHERE country_id = 'BT' AND project_id = 'GSOC';
UPDATE metadata.mapset SET creation_date = '2024-03-28', publication_date = '2024-03-28', revision_date = '2024-03-28' WHERE country_id = 'BT' AND project_id = 'OTHER';


-- citation
UPDATE metadata.mapset m
    SET citation_md_identifier_code = t.citation_md_identifier_code, 
        citation_md_identifier_code_space = t.citation_md_identifier_code_space
    FROM (SELECT DISTINCT project_id, citation_md_identifier_code, citation_md_identifier_code_space FROM metadata.mapset WHERE country_id = 'PH' AND citation_md_identifier_code IS NOT NULL) t
    WHERE m.country_id = 'BT' AND m.project_id = t.project_id;


-- abstract
UPDATE metadata.mapset m SET abstract = t.abstract
    FROM (SELECT DISTINCT property_id, replace(abstract,'Philippines','Bhutan') AS abstract FROM metadata.mapset WHERE abstract IS NOT NULL) t
    WHERE m.country_id = 'BT' AND m.property_id = t.property_id;


-- browse_graphic
UPDATE metadata.mapset m
SET md_browse_graphic = l.md_browse_graphic
FROM (
    SELECT mapset_id, 
        'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;VERSION=1.3.0&amp;REQUEST=GetMap&amp;BBOX='||east_bound_longitude||'%2C'||north_bound_latitude||'%2C'||west_bound_longitude||'%2C'||south_bound_latitude||'&amp;CRS=EPSG%3A4326&amp;WIDTH=762&amp;HEIGHT=1228&amp;LAYERS='||layer_id||'&amp;STYLES=&amp;FORMAT=image%2Fpng&amp;DPI=96&amp;MAP_RESOLUTION=96&amp;FORMAT_OPTIONS=dpi%3A96&amp;TRANSPARENT=TRUE' AS md_browse_graphic
    FROM metadata.layer
) l
WHERE m.mapset_id = l.mapset_id AND m.country_id = 'BT';


-- keywords
UPDATE metadata.mapset SET keyword_place = '{Bhutan}'::text[] WHERE country_id = 'BT';
UPDATE metadata.mapset m SET keyword_theme = t.keyword_theme
    FROM (SELECT DISTINCT property_id, keyword_theme FROM metadata.mapset WHERE keyword_theme IS NOT NULL) t
    WHERE m.country_id = 'BT' AND m.property_id = t.property_id;


-- licence
UPDATE metadata.mapset SET other_constraints = 'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International' WHERE country_id = 'BT';


-- time period
UPDATE metadata.mapset SET time_period_begin = '1999-01-01' WHERE country_id = 'BT';
UPDATE metadata.mapset SET time_period_end = '2023-12-31' WHERE country_id = 'BT';


-- lineage
UPDATE metadata.mapset m SET lineage_statement = t.lineage_statement
    FROM (SELECT DISTINCT project_id, lineage_statement FROM metadata.mapset WHERE lineage_statement IS NOT NULL) t
    WHERE m.country_id = 'BT' AND m.project_id = t.project_id;


-- insert organisation
INSERT INTO metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point) VALUES
    ('Bhutan National Soil Services Centre','https://www.nssc.gov.bt/','nssc@moal.gov.bt','Bhutan','Thimphu','11001','P. O. Box: 907 Simtokha')
    ON CONFLICT (organisation_id) DO NOTHING;


-- insert individual
INSERT INTO metadata.individual (individual_id, email) VALUES
    ('Thinley Dorji','Thhinjid@gmail.com'),
    ('Tsheten Dorji','tshetendorji08@gmail.com'),
    ('Sangita Pradhan','pitabhutan@gmail.com')
    ON CONFLICT (individual_id) DO NOTHING;


-- insert ver_x_org_x_ind
INSERT INTO metadata.ver_x_org_x_ind (mapset_id, tag, "role", "position", organisation_id, individual_id)
    SELECT DISTINCT mapset_id, 'contact', 'resourceProvider', 'GIS technician', 'Bhutan National Soil Services Centre', 'Sangita Pradhan' FROM metadata.mapset WHERE country_id = 'BT'
            UNION
    SELECT DISTINCT mapset_id, 'pointOfContact', 'author', 'Soil Survey & Land Evaluation Supervisor', 'Bhutan National Soil Services Centre', 'Thinley Dorji' FROM metadata.mapset WHERE country_id = 'BT'
            UNION
    SELECT DISTINCT mapset_id, 'pointOfContact', 'author', 'Principal Soil Survey & Land Evaluation Officer', 'Bhutan National Soil Services Centre', 'Tsheten Dorji' FROM metadata.mapset WHERE country_id = 'BT'
    ON CONFLICT (mapset_id, tag, role, "position", organisation_id, individual_id) DO NOTHING;


-- insert url
INSERT INTO metadata.url (mapset_id, protocol, url, url_name)
    -- SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', url_paper, 'Scientific paper' FROM metadata.metadata_manual WHERE url_paper IS NOT NULL
    --     UNION
    SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', 'https://www.fao.org/global-soil-partnership/resources/highlights/detail/en/c/1471478/', 'Project webpage' FROM metadata.mapset WHERE project_id = 'GSOC' AND country_id = 'BT'
            UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAP/'||'GLOSIS.'||l.mapset_id||','||l.file_extension , 'Download '||l.dimension_des 
        FROM metadata.mapset m
        LEFT JOIN metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE l.mapset_id IN (SELECT mapset_id FROM metadata.layer GROUP BY mapset_id HAVING count(*)=1) AND m.country_id = 'BT'
            UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_des||'.'||l.file_extension , 'Download '||l.dimension_des 
        FROM metadata.mapset m
        LEFT JOIN metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE l.mapset_id IN (SELECT mapset_id FROM metadata.layer GROUP BY mapset_id HAVING count(*)>1) AND m.country_id = 'BT'
            UNION
    SELECT mapset_id, 'OGC:WMTS', 'https://data.apps.fao.org/map/wmts/wmts?service=WMTS&amp;request=GetCapabilities&amp;version=1.0.0&amp;workspace=GLOSIS', 'WMTS (FAO)' FROM metadata.mapset WHERE country_id = 'BT'
        UNION
    SELECT mapset_id, 'OGC:WMTS', 'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;REQUEST=GetCapabilities', 'WMTS (Bhutan SIS)' FROM metadata.layer WHERE layer_id LIKE 'BT-%'
    ON CONFLICT (mapset_id, protocol, url) DO NOTHING;


-- categorical class
INSERT INTO metadata."class" (property_id, value, code, "label", color, opacity, publish) VALUES
('CLAWRB', -1, '-1', '-1 - No Data', '#000000',1, 't'),
('CLAWRB', 1, '1', '1 - Anthraquic Cambisols', '#800080',1, 't'),
('CLAWRB', 2, '2', '2 - Dystric Cambisols', '#f84040',1, 't'),
('CLAWRB', 3, '3', '3 - Eutric Cambisols', '#da70d6',1, 't'),
('CLAWRB', 4, '4', '4 - Haplic Acrisols', '#f08080',1, 't'),
('CLAWRB', 5, '5', '5 - Haplic Alisols', '#00ffff',1, 't'),
('CLAWRB', 6, '6', '6 - Haplic Lixisols', '#f5deb3',1, 't'),
('CLAWRB', 7, '7', '7 - Skeletic Cambisols', '#ee82ee',1, 't');
