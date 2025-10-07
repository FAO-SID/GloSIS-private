-- project
UPDATE spatial_metadata.project SET project_name='Global Salt-Affected Soils' WHERE country_id='TH' AND project_id='GSAS';
UPDATE spatial_metadata.project SET project_name='Global Soil Nutrients Map' WHERE country_id='TH' AND project_id='GSNM';
-- UPDATE spatial_metadata.project SET project_name='Global Soil Organic Carbon Sequestration potential map' WHERE country_id='TH' AND project_id='GSOCSEQ';


-- dates
-- UPDATE spatial_metadata.mapset SET creation_date = '2020-12-16', publication_date = '2020-12-16', revision_date = '2020-12-16' WHERE country_id = 'TH' AND project_id = 'GSAS';
UPDATE spatial_metadata.mapset SET creation_date = '2025-09-01', publication_date = '2025-09-01', revision_date = '2025-09-01' WHERE country_id = 'TH' AND project_id = 'GSNM';
--UPDATE spatial_metadata.mapset SET creation_date = 'XXXXXXX', publication_date = 'XXXXXXX', revision_date = 'XXXXXXX' WHERE country_id = 'TH' AND project_id = 'GSOCSEQ';


-- unit_of_measure_id
UPDATE spatial_metadata.mapset m
SET unit_of_measure_id = p.unit_of_measure_id 
FROM spatial_metadata.property p
WHERE m.country_id = 'TH'
  AND m.unit_of_measure_id IS NULL
  AND m.property_id = p.property_id;

-- UPDATE spatial_metadata.mapset SET unit_of_measure_id = 'TH-GSNM-BKD-2025' WHERE mapset_id = 'kg/dm³';
-- UPDATE spatial_metadata.mapset SET unit_of_measure_id = 'TH-GSNM-CEC-2025' WHERE mapset_id = 'cmol/kg';
-- UPDATE spatial_metadata.mapset SET unit_of_measure_id = 'TH-GSNM-KEXT-2025' WHERE mapset_id = 'mg/kg';
-- UPDATE spatial_metadata.mapset SET unit_of_measure_id = 'TH-GSNM-PHX-2025' WHERE mapset_id = 'pH';
-- UPDATE spatial_metadata.mapset SET unit_of_measure_id = 'TH-GSNM-PXX-2025' WHERE mapset_id = 'mg/kg';


-- title
UPDATE spatial_metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, 
                          'GSASmap - '||p.name||' ('||coalesce(c.en,'')||' - '||coalesce(p.unit_of_measure_id,'')||' - '|| 
                          CASE
                            WHEN l.distance = '0.0083333' THEN '1 km'
                            WHEN l.distance = '0.0022457' THEN '250 m'
                            ELSE l.distance
                          END||' - '||coalesce(EXTRACT( YEAR FROM m.creation_date)::text,'')||')' AS title
            FROM spatial_metadata.mapset m
            LEFT JOIN spatial_metadata.property p ON p.property_id = m.property_id
            LEFT JOIN spatial_metadata.country c ON c.country_id = m.country_id
            LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'TH' AND project_id='GSAS';

UPDATE spatial_metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, 
                          'GSNmap - '||p.name||' ('||coalesce(c.en,'')||' - '||coalesce(p.unit_of_measure_id,'')||' - '|| 
                          CASE
                            WHEN l.distance = '0.0083333' THEN '1 km'
                            WHEN l.distance = '0.0022457' THEN '250 m'
                            ELSE l.distance
                          END||' - '||coalesce(EXTRACT( YEAR FROM m.creation_date)::text,'')||')' AS title
            FROM spatial_metadata.mapset m
            LEFT JOIN spatial_metadata.property p ON p.property_id = m.property_id
            LEFT JOIN spatial_metadata.country c ON c.country_id = m.country_id
            LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'TH' AND project_id='GSNM';

UPDATE spatial_metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, 
                          p.name||' ('||coalesce(c.en,'')||' - '||coalesce(p.unit_of_measure_id,'')||' - '|| 
                          CASE
                            WHEN l.distance = '0.0083333' THEN '1 km'
                            WHEN l.distance = '0.0022457' THEN '250 m'
                            ELSE l.distance
                          END||' - '||coalesce(EXTRACT( YEAR FROM m.creation_date)::text,'')||')' AS title
            FROM spatial_metadata.mapset m
            LEFT JOIN spatial_metadata.property p ON p.property_id = m.property_id
            LEFT JOIN spatial_metadata.country c ON c.country_id = m.country_id
            LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'TH' AND project_id='GSOCSEQ';


-- citation
UPDATE spatial_metadata.mapset
    SET citation_md_identifier_code = 'https://doi.org/10.4060/cb9002en', 
        citation_md_identifier_code_space = 'doi'
WHERE country_id = 'TH'
  AND project_id = 'GSOCSEQ';


-- abstract
UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Country Guidelines for the GSNmap initiative (FAO, 2022), which provide technical specifications for generating national maps of soil nutrients and associated properties at 250 m resolution. The guidelines describe standardized digital soil mapping procedures to ensure consistency and comparability across countries and regions, with outputs including soil nutrient levels as well as key soil properties such as organic carbon, pH, texture, bulk density, and cation exchange capacity. These products support evidence-based agricultural planning and policy development. To cite or share: https://doi.org/10.4060/cc1717en'
WHERE country_id = 'TH'
  AND project_id = 'GSNM';

UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Global Soil Organic Carbon Sequestration Potential Map (GSOCseq), developed under the Global Soil Partnership to support Sustainable Development Goal Indicator 15.3 on land degradation neutrality. The GSOCseq map follows a country-driven bottom-up approach, where national SOC sequestration maps are produced and validated by local experts using standardized SOC models and the best available data. These products provide an evidence base for assessing soil restoration potential and supporting sustainable land management policies. To cite or share: https://doi.org/10.4060/cb2642en'
WHERE country_id = 'TH'
  AND project_id = 'GSOCSEQ';

UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Technical Guidelines for Mapping and Harmonizing Salt-Affected Soils (FAO, 2021), which provide approaches for developing multiscale spatial information on saline and sodic soils. The guidelines describe the characteristics, distribution, and drivers of salt-affected soils, and outline standardized procedures for harmonizing data from multiple sources to produce consistent spatial maps. They also include recommendations for information sharing, capacity building, and supporting sustainable management of salt-affected soils. To cite or share: https://doi.org/10.4060/ca9215en'
WHERE country_id = 'TH'
  AND project_id = 'GSAS';


-- browse_graphic
UPDATE spatial_metadata.mapset m
SET md_browse_graphic = l.md_browse_graphic
FROM (
    SELECT mapset_id, 
        'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;VERSION=1.3.0&amp;REQUEST=GetMap&amp;BBOX='||east_bound_longitude||'%2C'||north_bound_latitude||'%2C'||west_bound_longitude||'%2C'||south_bound_latitude||'&amp;CRS=EPSG%3A4326&amp;WIDTH=762&amp;HEIGHT=1228&amp;LAYERS='||layer_id||'&amp;STYLES=&amp;FORMAT=image%2Fpng&amp;DPI=96&amp;MAP_RESOLUTION=96&amp;FORMAT_OPTIONS=dpi%3A96&amp;TRANSPARENT=TRUE' AS md_browse_graphic
    FROM spatial_metadata.layer
) l
WHERE m.mapset_id = l.mapset_id AND m.country_id = 'TH';


-- keywords
UPDATE spatial_metadata.mapset SET keyword_place = '{Thaliand}'::text[] WHERE country_id = 'TH';
UPDATE spatial_metadata.mapset m SET keyword_theme = p.keyword_theme FROM spatial_metadata.property p WHERE country_id = 'TH' AND m.property_id = p.property_id;


-- licence
UPDATE spatial_metadata.mapset SET other_constraints = 'CC BY-NC-ND 4.0' WHERE country_id = 'TH';


-- time period
UPDATE spatial_metadata.mapset SET time_period_begin = '2000-01-01' WHERE country_id = 'TH';
UPDATE spatial_metadata.mapset SET time_period_end = '2024-09-01' WHERE country_id = 'TH';


-- lineage
UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cc1717en'
WHERE country_id = 'TH'
  AND project_id = 'GSNM';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cb2642en'
WHERE country_id = 'TH'
  AND project_id = 'GSOCSEQ';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/ca9215en'
WHERE country_id = 'TH'
  AND project_id = 'GSAS';


-- insert organisation
INSERT INTO spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point) VALUES
    ('Land Development Department', 'https://www.ldd.go.th/home/', 'saraban@ldd.go.th', 'Thaliand', 'Bangkok', '10900', '2003/61 Phahonyothin Road, Lat Yao Subdistrict, Chatuchak District')
    ON CONFLICT (organisation_id) DO NOTHING;


-- insert individual
INSERT INTO spatial_metadata.individual (individual_id, email) VALUES
    ('Satira Udomsri', 'domsrisat@gmail.com'),
    ('Pichamon Intamo', 'pichamonip@gmail.com'),
    ('Worawan Laopansakul', 'oss_4@ldd.go.th'),
    ('Naruekamon Janjirawuttikul', 'naruekamon@ldd.go.th'),
    ('Kridsopon Duangkamol', 'kridldd1@gmail.com'),
    ('Kunnika Homyamyen', 'kunnihyy@gmail.com'),
    ('Thawin Norkham', 'thawinnorkham@gmail.com'),
    ('Phanlob Hongcharoenthai', 'oss_5@ldd.go.th'),
    ('Wattana Pattanathaworn', 'wattanaatmcc@hotmail.com')
    ON CONFLICT (individual_id) DO NOTHING;


-- insert proj_x_org_x_ind
INSERT INTO spatial_metadata.proj_x_org_x_ind (country_id, project_id, tag, "role", "position", organisation_id, individual_id)
    SELECT DISTINCT country_id, project_id, 'contact', 'resourceProvider', 'Soil surveyor', 'Land Development Department', 'Pichamon Intamo' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Pichamon Intamo' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Director', 'Land Development Department', 'Satira Udomsri' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Worawan Laopansakul' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Naruekamon Janjirawuttikul' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Kridsopon Duangkamol' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Kunnika Homyamyen' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Thawin Norkham' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Phanlob Hongcharoenthai' FROM spatial_metadata.project WHERE country_id = 'TH'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Soil surveyor', 'Land Development Department', 'Wattana Pattanathaworn' FROM spatial_metadata.project WHERE country_id = 'TH'
    ON CONFLICT (country_id, project_id, tag, role, "position", organisation_id, individual_id) DO NOTHING;


-- insert url
INSERT INTO spatial_metadata.url (mapset_id, protocol, url, url_name)
    -- SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', url_paper, 'Scientific paper' FROM spatial_metadata.metadata_manual WHERE url_paper IS NOT NULL
    --     UNION
    SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', 'https://www.fao.org/global-soil-partnership/resources/highlights/detail/en/c/1471478/', 'Project webpage' FROM spatial_metadata.mapset WHERE project_id = 'GSOCSEQ' AND country_id = 'TH'
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAP/GLOSIS.'||l.mapset_id||', '||l.file_extension , 'Download'
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'TH'
          AND l.dimension_depth IS NULL 
          AND l.dimension_stats IS NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_stats||'.'||l.file_extension , 'Download '||l.dimension_stats
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'TH'
          AND l.dimension_depth IS NULL
          AND l.dimension_stats IS NOT NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_depth||'.'||l.file_extension , 'Download '||l.dimension_depth
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'TH'
          AND l.dimension_depth IS NOT NULL
          AND l.dimension_stats IS NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_depth||'.D-'||l.dimension_stats||'.'||l.file_extension , 'Download '||l.dimension_depth||' '||l.dimension_stats
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'TH'
          AND l.dimension_depth IS NOT NULL
          AND l.dimension_stats IS NOT NULL
      UNION
    SELECT mapset_id, 'OGC:WMTS', 'https://data.apps.fao.org/map/wmts/wmts?service=WMTS&amp;request=GetCapabilities&amp;version=1.0.0&amp;workspace=GLOSIS', 'WMTS (FAO)' FROM spatial_metadata.mapset WHERE country_id = 'TH'
      UNION
    SELECT mapset_id, 'OGC:WMTS', 'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;REQUEST=GetCapabilities', 'WMTS (Thaliand SIS)' FROM spatial_metadata.layer WHERE layer_id LIKE 'TH-%'
    ON CONFLICT (mapset_id, protocol, url) DO NOTHING;


-- categorical class
-- INSERT INTO spatial_metadata."class" (mapset_id, value, code, "label", color, opacity, publish) VALUES
-- ('TH-GSAS-SALT-2020', -9999, '-9999', 'No Data', '#000000', 0, 't'),
-- ('TH-GSAS-SALT-2020', 1, '1', '1 - Extreme Salinity', '#ff0000', 1, 't'),
-- ('TH-GSAS-SALT-2020', 2, '2', '2 - Moderate Salinity', '#f5deb3', 1, 't'),
-- ('TH-GSAS-SALT-2020', 3, '3', '3 - Moderate Sodicity', '#ee82ee', 1, 't'),
-- ('TH-GSAS-SALT-2020', 4, '4', '4 - None', '#ffffff', 1, 't'),
-- ('TH-GSAS-SALT-2020', 5, '5', '5 - Saline Sodic', '#00ffff', 1, 't'),
-- ('TH-GSAS-SALT-2020', 6, '6', '6 - Slight Salinity', '#90ee90', 1, 't'),
-- ('TH-GSAS-SALT-2020', 7, '7', '7 - Slight Sodicity', '#add8e6', 1, 't'),
-- ('TH-GSAS-SALT-2020', 8, '8', '8 - Strong Salinity', '#f08080', 1, 't'),
-- ('TH-GSAS-SALT-2020', 9, '9', '9 - Strong Sodicity', '#da70d6', 1, 't'),
-- ('TH-GSAS-SALT-2020', 10, '10', '10 - Very Strong Salinity', '#f84040', 1, 't'),
-- ('TH-GSAS-SALT-2020', 11, '11', '11 - Very Strong Sodicity', '#800080', 1, 't')
--  ON CONFLICT (mapset_id, value) DO NOTHING;


-- fix extreme legend values
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN
        SELECT mapset_id FROM spatial_metadata.layer WHERE mapset_id ILIKE 'VN%' AND stats_minimum < -100
    LOOP
        -- Delete existing records
        EXECUTE format('DELETE FROM spatial_metadata.class WHERE mapset_id = %L', f.mapset_id);
        
        -- Insert new classification records
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, -339999995214436420000000000000000000000, %L, %L, %L, 1, %L)', f.mapset_id, 'lower -100', 'lower -100', '#ff0000', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, -100, %L, %L, %L, 1, %L)', f.mapset_id, '-100 - 0', '-100 - 0', '#e4d5c2', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 0, %L, %L, %L, 1, %L)', f.mapset_id, '0 - 10', '0 - 10', '#d3c2b0', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 10, %L, %L, %L, 1, %L)', f.mapset_id, '10 - 25', '10 - 25', '#c2b09e', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 25, %L, %L, %L, 1, %L)', f.mapset_id, '25 - 50', '25 - 50', '#b19d8c', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 50, %L, %L, %L, 1, %L)', f.mapset_id, '50 - 100', '50 - 100', '#a08b7b', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 100, %L, %L, %L, 1, %L)', f.mapset_id, '100 - 150', '100 - 150', '#8f7869', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 150, %L, %L, %L, 1, %L)', f.mapset_id, '150 - 250', '150 - 250', '#7e6657', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 250, %L, %L, %L, 1, %L)', f.mapset_id, '250 - 500', '250 - 500', '#6d5345', 't');
        EXECUTE format('INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish) VALUES (%L, 500, %L, %L, %L, 1, %L)', f.mapset_id, 'bigger 500', 'bigger 500', '#800080', 't');
    END LOOP;
END $$;
