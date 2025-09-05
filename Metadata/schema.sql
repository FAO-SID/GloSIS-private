-- DROP SCHEMA IF EXISTS spatial_metadata CASCADE;
CREATE SCHEMA spatial_metadata;
ALTER SCHEMA spatial_metadata OWNER TO sis;
COMMENT ON SCHEMA spatial_metadata IS 'Schema for spatial metadata';
GRANT USAGE ON SCHEMA spatial_metadata TO sis_r;


--------------------------------
--     TRIGGER FUNCTION       --
--------------------------------

CREATE OR REPLACE FUNCTION spatial_metadata.class()
RETURNS TRIGGER AS $$
DECLARE
  rec_layer RECORD;
  rec_property RECORD;
  range FLOAT;
  interval_size FLOAT;
  current_min FLOAT;
  current_max FLOAT;
  i INT := 1;
  start_r INT;
  start_g INT;
  start_b INT;
  end_r INT;
  end_g INT;
  end_b INT;
  color TEXT;
BEGIN

SELECT  mapset_id, 
        min(stats_minimum) min, 
        max(stats_maximum) max
INTO rec_layer
FROM spatial_metadata.layer
WHERE mapset_id = NEW.mapset_id
GROUP BY mapset_id;

SELECT  property_type, 
        num_intervals,
        start_color,
        end_color
INTO rec_property
FROM spatial_metadata.property
WHERE property_id = split_part(NEW.mapset_id,'-',3);

  -- Only when property_type is quantitative
  IF rec_property.property_type = 'quantitative' THEN

    -- Validate num_intervals
    IF rec_property.num_intervals <= 0 THEN
        RAISE EXCEPTION 'Number of intervals must be greater than 0.';
    END IF;

    -- Validate start_color and end_color
    IF rec_property.start_color NOT LIKE '#______' OR rec_property.end_color NOT LIKE '#______' THEN
        RAISE EXCEPTION 'Colors must be in HEX format (e.g., #F4E7D3).';
    END IF;

    -- Check if stats_minimum and max are not NULL
    -- IF rec_layer.min IS NULL OR rec_layer.max IS NULL THEN
    --     RAISE EXCEPTION 'min and max must not be NULL.';
    -- END IF;

    -- Calculate the range and interval size
    range := rec_layer.max - rec_layer.min;
    IF range = 0 THEN
        RAISE EXCEPTION 'Range is 0. Cannot create intervals for layer_id %.', rec_property.layer_id;
    END IF;
    interval_size := range / rec_property.num_intervals;
    current_min := rec_layer.min;
    current_max := rec_layer.min + interval_size;

    -- Delete existing rows for this mapset_id
    DELETE FROM spatial_metadata.class WHERE mapset_id = rec_layer.mapset_id;

    -- Extract RGB components from start_color and end_color
    start_r := ('x' || SUBSTRING(rec_property.start_color FROM 2 FOR 2))::BIT(8)::INT;
    start_g := ('x' || SUBSTRING(rec_property.start_color FROM 4 FOR 2))::BIT(8)::INT;
    start_b := ('x' || SUBSTRING(rec_property.start_color FROM 6 FOR 2))::BIT(8)::INT;
    end_r := ('x' || SUBSTRING(rec_property.end_color FROM 2 FOR 2))::BIT(8)::INT;
    end_g := ('x' || SUBSTRING(rec_property.end_color FROM 4 FOR 2))::BIT(8)::INT;
    end_b := ('x' || SUBSTRING(rec_property.end_color FROM 6 FOR 2))::BIT(8)::INT;

    -- Loop to create intervals
    WHILE i <= rec_property.num_intervals LOOP
        -- Interpolate the color based on the interval index
        color := '#' || 
                LPAD(TO_HEX(start_r + (end_r - start_r) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_g + (end_g - start_g) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0') ||
                LPAD(TO_HEX(start_b + (end_b - start_b) * (i - 1) / (rec_property.num_intervals - 1)), 2, '0');

        -- Insert the class interval and color into the categories table
        INSERT INTO spatial_metadata.class (mapset_id, value, code, "label", color, opacity, publish)
        VALUES (rec_layer.mapset_id, 
                COALESCE(current_min::numeric(20,2),0), 
                COALESCE(current_min::numeric(20,2),0) || ' - ' || COALESCE(current_max::numeric(20,2),0), 
                COALESCE(current_min::numeric(20,2),0) || ' - ' || COALESCE(current_max::numeric(20,2),0), 
                color, 
                1, 
                't')
        ON CONFLICT (mapset_id, value)
        DO UPDATE SET
            code = EXCLUDED.code,
            label = EXCLUDED.label,
            color = EXCLUDED.color,
            opacity = EXCLUDED.opacity,
            publish = EXCLUDED.publish;

        -- Update the current_min and current_max for the next interval
        current_min := current_max;
        current_max := current_max + interval_size;
        i := i + 1;
    END LOOP;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
ALTER FUNCTION spatial_metadata.class() OWNER TO sis;


CREATE OR REPLACE FUNCTION spatial_metadata.map()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  rec_property RECORD;
  rec_layer RECORD;
BEGIN

SELECT 
	l.layer_id,
  CASE 
    WHEN l.distance_uom='m'  THEN 'METERS'
    WHEN l.distance_uom='km' THEN 'KILOMETERS'
    WHEN l.distance_uom='deg' THEN 'DD'
  END distance_uom,
  l.reference_system_identifier_code,
	l.extent,
	l.file_extension,
	l.stats_minimum,
	l.stats_maximum
INTO rec_layer
FROM spatial_metadata.layer l 
WHERE l.layer_id = NEW.layer_id;

SELECT m.mapset_id,
  p.start_color,
  p.end_color
INTO rec_property
FROM spatial_metadata.mapset m, spatial_metadata.property p
WHERE m.property_id = split_part(NEW.layer_id,'-',3);

UPDATE spatial_metadata.layer l SET map = 'MAP
  NAME "'||rec_layer.layer_id||'"
  EXTENT '||rec_layer.extent||'
  UNITS '||rec_layer.distance_uom||'
  SHAPEPATH "./"
  SIZE 800 600
  IMAGETYPE "PNG24"
  PROJECTION
      "init=epsg:'||rec_layer.reference_system_identifier_code||'"
  END # PROJECTION
  WEB
      METADATA
          "ows_title" "'||rec_layer.layer_id||' web-service" 
          "ows_enable_request" "*" 
          "ows_srs" "EPSG:'||rec_layer.reference_system_identifier_code||' EPSG:4326 EPSG:3857"
          "wms_getfeatureinfo_formatlist" "text/plain,text/html,application/json,geojson,application/vnd.ogc.gml,gml"
          "wms_feature_info_mime_type" "application/json"
      END # METADATA
  END # WEB
  LAYER
      TEMPLATE "getfeatureinfo.tmpl"
      NAME "'||rec_layer.layer_id||'"
      DATA "'||rec_layer.layer_id||'.'||rec_layer.file_extension||'"
      TYPE RASTER
      STATUS ON
      METADATA
        "wms_include_items" "all"
        "gml_include_items" "all"
      END # METADATA
      CLASS
        NAME "'||rec_layer.layer_id||'"
        STYLE
            COLORRANGE "'||rec_property.start_color||'" "'||rec_property.end_color||'"
            DATARANGE '||rec_layer.stats_minimum||' '||rec_layer.stats_maximum||'
            RANGEITEM "pixel"
          END # STYLE
      END # CLASS
  END # LAYER
END # MAP'
WHERE l.layer_id = NEW.layer_id;

  RETURN NEW;
END
$function$;
ALTER FUNCTION spatial_metadata.map() OWNER TO sis;


CREATE OR REPLACE FUNCTION spatial_metadata.sld()
RETURNS trigger
LANGUAGE 'plpgsql'
COST 100
VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
  rec RECORD;
  sub_rec RECORD;
  part_1 text := '<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>LAYER_NAME</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="property_type">';
  part_2 text :='';
  new_row text;
  part_3 text := '
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>';

BEGIN
    FOR rec IN SELECT DISTINCT NEW.mapset_id, 
            CASE WHEN p.property_type='categorical'  THEN 'values'
                 WHEN p.property_type='quantitative' THEN 'intervals'
              END property_type
            FROM spatial_metadata.mapset m, 
                 spatial_metadata.property p
            WHERE split_part(NEW.mapset_id,'-',3) = p.property_id
            ORDER BY NEW.mapset_id

    LOOP
	
      FOR sub_rec IN SELECT code, value, color, opacity, label FROM spatial_metadata.class WHERE mapset_id = NEW.mapset_id AND publish IS TRUE ORDER BY value
    	LOOP
		
			SELECT E'\n             <sld:ColorMapEntry quantity="' ||sub_rec.value|| '" color="' ||sub_rec.color|| '" opacity="' ||sub_rec.opacity|| '" label="' ||sub_rec.label|| '"/>' INTO new_row;

			SELECT part_2 || new_row INTO part_2;
		
		END LOOP;
		
		  UPDATE spatial_metadata.mapset SET sld = replace(replace(part_1,'LAYER_NAME',NEW.mapset_id),'property_type',rec.property_type) || part_2 || part_3 WHERE mapset_id = NEW.mapset_id;
		  SELECT '' INTO part_2;
		  SELECT '' INTO new_row;
		  
	END LOOP;
  RETURN NEW;
END
$BODY$;
ALTER FUNCTION spatial_metadata.sld() OWNER TO sis;


--------------------------
--        TABLE         --
--------------------------

CREATE TABLE spatial_metadata.country (
	country_id bpchar(2) NOT NULL,
	iso3_code bpchar(3) NULL,
	gaul_code int4 NULL,
	color_code bpchar(3) NULL,
	ar text NULL,
	en text NULL,
	es text NULL,
	fr text NULL,
	pt text NULL,
	ru text NULL,
	zh text NULL,
	status text NULL,
	disp_area varchar(3) NULL,
	capital text NULL,
	continent text NULL,
	un_reg text NULL,
	unreg_note text NULL,
	continent_custom text NULL
);
ALTER TABLE spatial_metadata.country OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.country TO sis_r;


CREATE TABLE spatial_metadata.project (
  country_id text NOT NULL,
  project_id text NOT NULL,
  project_name text,
  project_description text
);
ALTER TABLE spatial_metadata.project OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.project TO sis_r;


CREATE TABLE spatial_metadata.mapset (
  country_id text NOT NULL,
  project_id text NOT NULL,
  property_id text NOT NULL,
  mapset_id text NOT NULL,
  dimension text DEFAULT 'depth',
  parent_identifier uuid,
  file_identifier uuid DEFAULT public.uuid_generate_v1(),
  language_code text DEFAULT 'eng',
  metadata_standard_name text DEFAULT 'ISO 19115/19139',
  metadata_standard_version text DEFAULT '1.0',
  reference_system_identifier_code_space text DEFAULT 'EPSG',
  title text,
  unit_of_measure_id text,
  creation_date date,
  publication_date date,
  revision_date date,
  edition text,
  citation_md_identifier_code text,
  citation_md_identifier_code_space text DEFAULT 'doi',
  abstract text,
  status text DEFAULT 'completed',
  update_frequency text DEFAULT 'asNeeded',
  md_browse_graphic text,
  keyword_theme text[],
  keyword_place text[],
  keyword_discipline text[] DEFAULT '{Soil science}'::text[],
  access_constraints text DEFAULT 'copyright',
  use_constraints text DEFAULT 'license',
  other_constraints text,
  spatial_representation_type_code text DEFAULT 'grid',
  presentation_form text DEFAULT 'mapDigital',
  topic_category text[] DEFAULT '{geoscientificInformation,environment}'::text[],
  time_period_begin date,
  time_period_end date,
  scope_code text DEFAULT 'dataset',
  lineage_statement text,
  lineage_source_uuidref text,
  lineage_source_title text,
  xml text,
  sld text,
  CONSTRAINT mapset_dimension_check CHECK ((dimension = ANY (ARRAY['depth', 'time']))),
  CONSTRAINT mapset_citation_md_identifier_code_space_check CHECK ((citation_md_identifier_code_space = ANY (ARRAY['doi', 'uuid']))),
  CONSTRAINT mapset_status_check CHECK ((status = ANY (ARRAY['completed', 'historicalArchive', 'obsolete', 'onGoing', 'planned', 'required', 'underDevelopment']))),
  CONSTRAINT mapset_update_frequency_check CHECK ((update_frequency = ANY (ARRAY['continual', 'daily', 'weekly', 'fortnightly', 'monthly', 'quarterly', 'biannually','annually','asNeeded','irregular','notPlanned','unknown']))),
  CONSTRAINT mapset_access_constraints_check CHECK ((access_constraints = ANY (ARRAY['copyright', 'patent', 'patentPending', 'trademark', 'license', 'intellectualPropertyRights', 'restricted','otherRestrictions']))),
  CONSTRAINT mapset_use_constraints_check CHECK ((use_constraints = ANY (ARRAY['copyright', 'patent', 'patentPending', 'trademark', 'license', 'intellectualPropertyRights', 'restricted','otherRestrictions']))),
  CONSTRAINT mapset_spatial_representation_type_code_check CHECK ((spatial_representation_type_code = ANY (ARRAY['grid', 'vector', 'textTable', 'tin', 'stereoModel', 'video']))),
  CONSTRAINT mapset_presentation_form_check CHECK ((presentation_form = ANY (ARRAY['mapDigital', 'tableDigital', 'mapHardcopy', 'atlasHardcopy'])))
);
ALTER TABLE spatial_metadata.mapset OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.mapset TO sis_r;

CREATE TABLE spatial_metadata.property (
  property_id text NOT NULL,
  name text,
  property_phys_chem_id text,
  unit_of_measure_id text,
  min real,
  max real,
  property_type text NOT NULL,
  num_intervals smallint NOT NULL, 
  start_color text NOT NULL, 
  end_color text NOT NULL,
  keyword_theme text[],
  CONSTRAINT property_property_type_check CHECK ((property_type = ANY (ARRAY['quantitative', 'categorical'])))
);
ALTER TABLE spatial_metadata.property OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.property TO sis_r;


CREATE TABLE spatial_metadata.layer (
  mapset_id text NOT NULL,
  dim_depth text, -- dimension_des
  dim_stats text, -- MEAN / SDEV / UNCT / X
  file_path text NOT NULL,
  layer_id text NOT NULL,
  file_extension text,
  file_size integer,
  file_size_pretty text,
  reference_layer boolean DEFAULT FALSE,
  -- from geotiff_metadata_to_postgres.py
  reference_system_identifier_code text,
  distance text,
  distance_uom text,
  extent text,
  west_bound_longitude numeric(4,1),
  east_bound_longitude numeric(4,1),
  south_bound_latitude numeric(4,1),
  north_bound_latitude numeric(4,1),
  distribution_format text,
  -- extra metadata
  compression text,
  raster_size_x real,
  raster_size_y real,
  pixel_size_x real,
  pixel_size_y real,
  origin_x real,
  origin_y real,
  spatial_reference text,
  data_type text,
  no_data_value float,
  stats_minimum real,
  stats_maximum real,
  stats_mean real,
  stats_std_dev real,
  scale text,
  n_bands integer,
  metadata text[],
  map text,
  CONSTRAINT layer_distance_uom_check CHECK ((distance_uom = ANY (ARRAY['m', 'km', 'deg']))),
  CONSTRAINT layer_dim_stats_check CHECK ((dim_stats = ANY (ARRAY['MEAN', 'SDEV', 'UNCT', 'X'])))
);
ALTER TABLE spatial_metadata.layer OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.layer TO sis_r;


CREATE TABLE IF NOT EXISTS spatial_metadata.class
(
  mapset_id text NOT NULL,
  value real NOT NULL,
  code text NOT NULL,
  label text NOT NULL,
  color text NOT NULL,
  opacity real NOT NULL,
  publish boolean NOT NULL
);
ALTER TABLE spatial_metadata.class OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.class TO sis_r;


CREATE TABLE spatial_metadata.proj_x_org_x_ind (
  country_id text NOT NULL,
  project_id text NOT NULL,
  organisation_id text NOT NULL,
  individual_id text,
  position text,
  tag text,
  role text,
  CONSTRAINT proj_x_org_x_ind_tag_check CHECK ((tag = ANY (ARRAY['contact', 'pointOfContact']))),
  CONSTRAINT proj_x_org_x_ind_role_check CHECK ((role = ANY (ARRAY['author', 'custodian', 'distributor', 'originator', 'owner', 'pointOfContact', 'principalInvestigator', 'processor', 'publisher', 'resourceProvider', 'user'])))
);
ALTER TABLE spatial_metadata.proj_x_org_x_ind OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.proj_x_org_x_ind TO sis_r;


CREATE TABLE spatial_metadata.organisation (
  organisation_id text NOT NULL,
  url text,
  email text,
  country text,
  city text,
  postal_code text,
  delivery_point text,
  phone text,
  facsimile text
);
ALTER TABLE spatial_metadata.organisation OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.organisation TO sis_r;


CREATE TABLE spatial_metadata.individual (
  individual_id text NOT NULL,
  email text    
);
ALTER TABLE spatial_metadata.individual OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.individual TO sis_r;


CREATE TABLE spatial_metadata.url (
  mapset_id text NOT NULL,
  protocol text NOT NULL,
  url text NOT NULL,
  url_name text NOT NULL
  CONSTRAINT url_protocol_check CHECK ((protocol = ANY (ARRAY['OGC:WMS','OGC:WMTS','WWW:LINK-1.0-http--link', 'WWW:LINK-1.0-http--related'])))
);
ALTER TABLE spatial_metadata.url OWNER TO sis;
GRANT SELECT ON TABLE spatial_metadata.url TO sis_r;


--------------------------
--     PRIMARY KEY      --
--------------------------

ALTER TABLE spatial_metadata.country ADD PRIMARY KEY (country_id);
ALTER TABLE spatial_metadata.project ADD PRIMARY KEY (country_id, project_id);
ALTER TABLE spatial_metadata.mapset ADD PRIMARY KEY (mapset_id);
ALTER TABLE spatial_metadata.mapset ADD UNIQUE (file_identifier);
ALTER TABLE spatial_metadata.property ADD PRIMARY KEY (property_id);
ALTER TABLE spatial_metadata.layer ADD PRIMARY KEY (layer_id);
ALTER TABLE spatial_metadata.class ADD PRIMARY KEY (mapset_id, value);
ALTER TABLE spatial_metadata.proj_x_org_x_ind ADD PRIMARY KEY (country_id, project_id, organisation_id, individual_id, position, tag, role);
ALTER TABLE spatial_metadata.organisation ADD PRIMARY KEY (organisation_id);
ALTER TABLE spatial_metadata.individual ADD PRIMARY KEY (individual_id);
ALTER TABLE spatial_metadata.url ADD PRIMARY KEY (mapset_id, protocol, url);


--------------------------
--     FOREIGN KEY      --
--------------------------


ALTER TABLE spatial_metadata.proj_x_org_x_ind ADD FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.proj_x_org_x_ind ADD FOREIGN KEY (organisation_id) REFERENCES spatial_metadata.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.proj_x_org_x_ind ADD FOREIGN KEY (individual_id) REFERENCES spatial_metadata.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.url ADD FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.class ADD FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.layer ADD FOREIGN KEY (mapset_id) REFERENCES spatial_metadata.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.mapset ADD FOREIGN KEY (country_id, project_id) REFERENCES spatial_metadata.project(country_id, project_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE spatial_metadata.mapset ADD FOREIGN KEY (property_id) REFERENCES spatial_metadata.property(property_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE spatial_metadata.mapset ADD FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE spatial_metadata.project ADD FOREIGN KEY (country_id) REFERENCES spatial_metadata.country(country_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE spatial_metadata.property ADD FOREIGN KEY (property_phys_chem_id) REFERENCES soil_data.property_phys_chem(property_phys_chem_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE spatial_metadata.property ADD FOREIGN KEY (unit_of_measure_id) REFERENCES soil_data.unit_of_measure(unit_of_measure_id) ON UPDATE CASCADE ON DELETE NO ACTION;


--------------------------
--       TRIGGER        --
--------------------------


DROP TRIGGER IF EXISTS class_func_on_layer_table ON spatial_metadata.layer;
DROP TRIGGER IF EXISTS map_func_on_layer_table ON spatial_metadata.layer;
DROP TRIGGER IF EXISTS sld_func_on_class_table ON spatial_metadata.class;

CREATE TRIGGER class_func_on_layer_table
  AFTER UPDATE OF stats_minimum, stats_maximum
    ON spatial_metadata.layer
  FOR EACH ROW
  EXECUTE FUNCTION spatial_metadata.class();

CREATE TRIGGER map_func_on_layer_table
  AFTER UPDATE OF layer_id, mapset_id, distance_uom, reference_system_identifier_code, extent, file_extension, stats_minimum, stats_maximum
    ON spatial_metadata.layer
  FOR EACH ROW
  EXECUTE FUNCTION spatial_metadata.map();

CREATE TRIGGER sld_func_on_class_table
  AFTER INSERT OR UPDATE 
    ON spatial_metadata.class
  FOR EACH ROW
  EXECUTE FUNCTION spatial_metadata.sld();
