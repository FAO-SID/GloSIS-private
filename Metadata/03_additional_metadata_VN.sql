-- project
UPDATE spatial_metadata.project SET project_name='Global Salt-Affected Soils' WHERE country_id='VN' AND project_id='GSAS';
UPDATE spatial_metadata.project SET project_name='Global Soil Nutrients Map' WHERE country_id='VN' AND project_id='GSNM';
UPDATE spatial_metadata.project SET project_name='Global Soil Organic Carbon Sequestration potential map' WHERE country_id='VN' AND project_id='GSOCSEQ';


-- dates
UPDATE spatial_metadata.mapset SET creation_date = '2021-11-13', publication_date = '2021-11-13', revision_date = '2021-11-13' WHERE country_id = 'VN' AND project_id = 'GSAS';
UPDATE spatial_metadata.mapset SET creation_date = '2024-12-31', publication_date = '2024-12-31', revision_date = '2024-12-31' WHERE country_id = 'VN' AND project_id = 'GSNM';
UPDATE spatial_metadata.mapset SET creation_date = '2022-04-13', publication_date = '2022-04-13', revision_date = '2022-04-13' WHERE country_id = 'VN' AND project_id = 'GSOCSEQ';


-- unit_of_measure_id
UPDATE spatial_metadata.mapset m
SET unit_of_measure_id = p.unit_of_measure_id 
FROM spatial_metadata.property p
WHERE m.country_id = 'VN'
  AND m.unit_of_measure_id IS NULL
  AND m.property_id = p.property_id;


-- title
UPDATE spatial_metadata.mapset m SET title = t.title
    FROM (SELECT DISTINCT m.mapset_id, p.name||' ('||coalesce(c.en,'')||' - '||coalesce(p.unit_of_measure_id,'')||' - '||coalesce(l.distance,'')||' '||coalesce(l.distance_uom,'')||' - '||coalesce(EXTRACT( YEAR FROM m.creation_date)::text,'')||')' AS title
            FROM spatial_metadata.mapset m
            LEFT JOIN spatial_metadata.property p ON p.property_id = m.property_id
            LEFT JOIN spatial_metadata.country c ON c.country_id = m.country_id
            LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id) t
    WHERE m.mapset_id = t.mapset_id AND m.country_id = 'VN';


-- citation
UPDATE spatial_metadata.mapset
    SET citation_md_identifier_code = 'https://doi.org/10.4060/cb9002en', 
        citation_md_identifier_code_space = 'doi'
WHERE country_id = 'VN'
  AND project_id = 'GSOCSEQ';


-- abstract
UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Country Guidelines for the GSNmap initiative (FAO, 2022), which provide technical specifications for generating national maps of soil nutrients and associated properties at 250 m resolution. The guidelines describe standardized digital soil mapping procedures to ensure consistency and comparability across countries and regions, with outputs including soil nutrient levels as well as key soil properties such as organic carbon, pH, texture, bulk density, and cation exchange capacity. These products support evidence-based agricultural planning and policy development. To cite or share: https://doi.org/10.4060/cc1717en'
WHERE country_id = 'VN'
  AND project_id = 'GSNM';

UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Global Soil Organic Carbon Sequestration Potential Map (GSOCseq), developed under the Global Soil Partnership to support Sustainable Development Goal Indicator 15.3 on land degradation neutrality. The GSOCseq map follows a country-driven bottom-up approach, where national SOC sequestration maps are produced and validated by local experts using standardized SOC models and the best available data. These products provide an evidence base for assessing soil restoration potential and supporting sustainable land management policies. To cite or share: https://doi.org/10.4060/cb2642en'
WHERE country_id = 'VN'
  AND project_id = 'GSOCSEQ';

UPDATE spatial_metadata.mapset
SET abstract = 'This dataset was developed under the AFACI project - Development of the Soil Atlas of Asia and National Soil Information Systems (2019-2023). The project supported AFACI member countries in collecting, harmonizing, and managing national soil data to strengthen evidence-based decision making for sustainable soil management. Activities included rescuing legacy soil data, harmonizing national soil maps for the Soil Atlas of Asia, building national soil profile databases and soil property maps, and establishing web-based soil information systems. The project fostered regional and international collaboration, promoted soil data sharing, and contributed to the Global Soil Information System (GLOSIS) under the Global Soil Partnership.

This dataset relates to the Global Soil Organic Carbon Sequestration Potential Map (GSOCseq), developed under the Global Soil Partnership (GSP) to support Sustainable Development Goal Indicator 15.3 on land degradation neutrality. Using a country-driven bottom-up approach, national SOC sequestration maps are produced and validated by local experts with standardized SOC models and the best available data. The GSOCseq products provide a scientific basis for assessing soil restoration potential and informing sustainable land management policies. To cite or share: https://doi.org/10.4060/cb2642en'
WHERE country_id = 'VN'
  AND project_id = 'GSAS';


-- browse_graphic
UPDATE spatial_metadata.mapset m
SET md_browse_graphic = l.md_browse_graphic
FROM (
    SELECT mapset_id, 
        'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;VERSION=1.3.0&amp;REQUEST=GetMap&amp;BBOX='||east_bound_longitude||'%2C'||north_bound_latitude||'%2C'||west_bound_longitude||'%2C'||south_bound_latitude||'&amp;CRS=EPSG%3A4326&amp;WIDTH=762&amp;HEIGHT=1228&amp;LAYERS='||layer_id||'&amp;STYLES=&amp;FORMAT=image%2Fpng&amp;DPI=96&amp;MAP_RESOLUTION=96&amp;FORMAT_OPTIONS=dpi%3A96&amp;TRANSPARENT=TRUE' AS md_browse_graphic
    FROM spatial_metadata.layer
) l
WHERE m.mapset_id = l.mapset_id AND m.country_id = 'VN';


-- keywords
UPDATE spatial_metadata.mapset SET keyword_place = '{Viet Nam}'::text[] WHERE country_id = 'VN';
UPDATE spatial_metadata.mapset m SET keyword_theme = p.keyword_theme FROM spatial_metadata.property p WHERE country_id = 'VN' AND m.property_id = p.property_id;


-- licence
UPDATE spatial_metadata.mapset SET other_constraints = 'CC-BY-NC-SA-4.0' WHERE country_id = 'VN';


-- time period
UPDATE spatial_metadata.mapset SET time_period_begin = '1998-01-13' WHERE country_id = 'VN';
UPDATE spatial_metadata.mapset SET time_period_end = '2024-12-13' WHERE country_id = 'VN';


-- lineage
UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cc1717en'
WHERE country_id = 'VN'
  AND project_id = 'GSNM';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/cb2642en'
WHERE country_id = 'VN'
  AND project_id = 'GSOCSEQ';

UPDATE spatial_metadata.mapset
    SET lineage_statement = 'https://doi.org/10.4060/ca9215en'
WHERE country_id = 'VN'
  AND project_id = 'GSAS';


-- insert organisation
INSERT INTO spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point) VALUES
    ('Soils and Fertilizers Institute', 'https://sfri.org.vn/', 'sfri.org@gmail.com', 'Viet Nam', 'Ha Noi', '11910', 'Duc Thang 4')
    ON CONFLICT (organisation_id) DO NOTHING;


-- insert individual
INSERT INTO spatial_metadata.individual (individual_id, email) VALUES
    ('Quyet Manh Vu', 'vmquyet@gmail.com'),
    ('Tien Minh Tran', 'tranminhtien74@yahoo.com'),
    ('Thu Minh Tran', 'tranminhthu126@gmail.com'),
    ('Hao Thanh Dang', 'dangthanhhao2041994@gmail.com')
    ON CONFLICT (individual_id) DO NOTHING;


-- insert proj_x_org_x_ind
INSERT INTO spatial_metadata.proj_x_org_x_ind (country_id, project_id, tag, "role", "position", organisation_id, individual_id)
    SELECT DISTINCT country_id, project_id, 'contact', 'resourceProvider', 'Deputy head', 'Soils and Fertilizers Institute', 'Quyet Manh Vu' FROM spatial_metadata.project WHERE country_id = 'VN'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Deputy head', 'Soils and Fertilizers Institute', 'Quyet Manh Vu' FROM spatial_metadata.project WHERE country_id = 'VN'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Director General', 'Soils and Fertilizers Institute', 'Tien Minh Tran' FROM spatial_metadata.project WHERE country_id = 'VN'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Deputy Director General', 'Soils and Fertilizers Institute', 'Thu Minh Tran' FROM spatial_metadata.project WHERE country_id = 'VN'
            UNION
    SELECT DISTINCT country_id, project_id, 'pointOfContact', 'author', 'Reseacher', 'Soils and Fertilizers Institute', 'Hao Thanh Dang' FROM spatial_metadata.project WHERE country_id = 'VN'
    ON CONFLICT (country_id, project_id, tag, role, "position", organisation_id, individual_id) DO NOTHING;


-- insert url
INSERT INTO spatial_metadata.url (mapset_id, protocol, url, url_name)
    -- SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', url_paper, 'Scientific paper' FROM spatial_metadata.metadata_manual WHERE url_paper IS NOT NULL
    --     UNION
    SELECT DISTINCT mapset_id, 'WWW:LINK-1.0-http--link', 'https://www.fao.org/global-soil-partnership/resources/highlights/detail/en/c/1471478/', 'Project webpage' FROM spatial_metadata.mapset WHERE project_id = 'GSOCSEQ' AND country_id = 'VN'
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAP/GLOSIS.'||l.mapset_id||', '||l.file_extension , 'Download'
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'VN'
          AND l.dimension_depth IS NULL 
          AND l.dimension_stats IS NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_stats||'.'||l.file_extension , 'Download '||l.dimension_stats
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'VN'
          AND l.dimension_depth IS NULL
          AND l.dimension_stats IS NOT NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_depth||'.'||l.file_extension , 'Download '||l.dimension_depth
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'VN'
          AND l.dimension_depth IS NOT NULL
          AND l.dimension_stats IS NULL
      UNION
    SELECT m.mapset_id, 'WWW:LINK-1.0-http--link', 'https://storage.googleapis.com/fao-gismgr-glosis-data/DATA/GLOSIS/MAPSET/'||l.mapset_id||'/GLOSIS.'||l.mapset_id||'.D-'||l.dimension_depth||'.D-'||l.dimension_stats||'.'||l.file_extension , 'Download '||l.dimension_depth||' '||l.dimension_stats
        FROM spatial_metadata.mapset m
        LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = 'VN'
          AND l.dimension_depth IS NOT NULL
          AND l.dimension_stats IS NOT NULL
      UNION
    SELECT mapset_id, 'OGC:WMTS', 'https://data.apps.fao.org/map/wmts/wmts?service=WMTS&amp;request=GetCapabilities&amp;version=1.0.0&amp;workspace=GLOSIS', 'WMTS (FAO)' FROM spatial_metadata.mapset WHERE country_id = 'VN'
      UNION
    SELECT mapset_id, 'OGC:WMTS', 'http://localhost:8082/?map=/etc/mapserver/'||layer_id||'.map&amp;SERVICE=WMS&amp;REQUEST=GetCapabilities', 'WMTS (Viet Nam SIS)' FROM spatial_metadata.layer WHERE layer_id LIKE 'VN-%'
    ON CONFLICT (mapset_id, protocol, url) DO NOTHING;


-- categorical class
INSERT INTO spatial_metadata."class" (mapset_id, value, code, "label", color, opacity, publish) VALUES
('VN-GSAS-SALT-2021', -1, '-1', '-1 - No Data', '#000000', 0, 't'),
('VN-GSAS-SALT-2021', 1, '1', '1 - Extreme Salinity', '#ff0000', 1, 't'),
('VN-GSAS-SALT-2021', 2, '2', '2 - Moderate Salinity', '#f5deb3', 1, 't'),
('VN-GSAS-SALT-2021', 3, '3', '3 - Moderate Sodicity', '#ee82ee', 1, 't'),
('VN-GSAS-SALT-2021', 4, '4', '4 - None', '#ffffff', 1, 't'),
('VN-GSAS-SALT-2021', 5, '5', '5 - Saline Sodic', '#00ffff', 1, 't'),
('VN-GSAS-SALT-2021', 6, '6', '6 - Slight Salinity', '#90ee90', 1, 't'),
('VN-GSAS-SALT-2021', 7, '7', '7 - Slight Sodicity', '#add8e6', 1, 't'),
('VN-GSAS-SALT-2021', 8, '8', '8 - Strong Salinity', '#f08080', 1, 't'),
('VN-GSAS-SALT-2021', 9, '9', '9 - Strong Sodicity', '#da70d6', 1, 't'),
('VN-GSAS-SALT-2021', 10, '10', '10 - Very Strong Salinity', '#f84040', 1, 't'),
('VN-GSAS-SALT-2021', 11, '11', '11 - Very Strong Sodicity', '#800080', 1, 't')
 ON CONFLICT (mapset_id, value) DO NOTHING;
