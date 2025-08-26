-- DROP SCHEMA IF EXISTS gn2ckan CASCADE;
CREATE SCHEMA gn2ckan;
ALTER SCHEMA gn2ckan OWNER TO sis;
COMMENT ON SCHEMA gn2ckan IS 'Schema for migrating FAO soil metadata from GeoNetwork to CKAN';
GRANT USAGE ON SCHEMA gn2ckan TO sis_r;


--------------------------
--        TABLE         --
--------------------------


CREATE TABLE gn2ckan.group (
  group_id text NOT NULL,
  group_name text,
  group_description text
);
ALTER TABLE gn2ckan.group OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.group TO sis_r;


CREATE TABLE gn2ckan.mapset (
  group_id text NOT NULL,
  mapset_id text NOT NULL,
  dimension text DEFAULT 'depth',
  parent_identifier uuid,
  file_identifier uuid,
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
  CONSTRAINT mapset_dimension_check CHECK ((dimension = ANY (ARRAY['depth', 'time']))),
  CONSTRAINT mapset_citation_md_identifier_code_space_check CHECK ((citation_md_identifier_code_space = ANY (ARRAY['doi', 'uuid']))),
  CONSTRAINT mapset_status_check CHECK ((status = ANY (ARRAY['completed', 'historicalArchive', 'obsolete', 'onGoing', 'planned', 'required', 'underDevelopment']))),
  CONSTRAINT mapset_update_frequency_check CHECK ((update_frequency = ANY (ARRAY['continual', 'daily', 'weekly', 'fortnightly', 'monthly', 'quarterly', 'biannually','annually','asNeeded','irregular','notPlanned','unknown']))),
  CONSTRAINT mapset_access_constraints_check CHECK ((access_constraints = ANY (ARRAY['copyright', 'patent', 'patentPending', 'trademark', 'license', 'intellectualPropertyRights', 'restricted','otherRestrictions']))),
  CONSTRAINT mapset_use_constraints_check CHECK ((use_constraints = ANY (ARRAY['copyright', 'patent', 'patentPending', 'trademark', 'license', 'intellectualPropertyRights', 'restricted','otherRestrictions']))),
  CONSTRAINT mapset_spatial_representation_type_code_check CHECK ((spatial_representation_type_code = ANY (ARRAY['grid', 'vector', 'textTable', 'tin', 'stereoModel', 'video']))),
  CONSTRAINT mapset_presentation_form_check CHECK ((presentation_form = ANY (ARRAY['mapDigital', 'tableDigital', 'mapHardcopy', 'atlasHardcopy'])))
);
ALTER TABLE gn2ckan.mapset OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.mapset TO sis_r;


CREATE TABLE gn2ckan.layer (
  mapset_id text NOT NULL,
  dimension_des text,
  file_path text NOT NULL,
  layer_id text NOT NULL,
  file_extension text,
  file_size integer,
  file_size_pretty text,
  reference_layer boolean DEFAULT FALSE,
  -- from layer_scan.py
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
  CONSTRAINT layer_distance_uom_check CHECK ((distance_uom = ANY (ARRAY['m', 'km', 'deg'])))
);
ALTER TABLE gn2ckan.layer OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.layer TO sis_r;


CREATE TABLE gn2ckan.mapset_x_org_x_ind (
  mapset_id text NOT NULL,
  organisation_id text NOT NULL,
  individual_id text,
  position text,
  tag text,
  role text,
  CONSTRAINT mapset_x_org_x_ind_tag_check CHECK ((tag = ANY (ARRAY['contact', 'pointOfContact']))),
  CONSTRAINT mapset_x_org_x_ind_role_check CHECK ((role = ANY (ARRAY['author', 'custodian', 'distributor', 'originator', 'owner', 'pointOfContact', 'principalInvestigator', 'processor', 'publisher', 'resourceProvider', 'user'])))
);
ALTER TABLE gn2ckan.mapset_x_org_x_ind OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.mapset_x_org_x_ind TO sis_r;


CREATE TABLE gn2ckan.organisation (
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
ALTER TABLE gn2ckan.organisation OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.organisation TO sis_r;


CREATE TABLE gn2ckan.individual (
  individual_id text NOT NULL,
  email text    
);
ALTER TABLE gn2ckan.individual OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.individual TO sis_r;


CREATE TABLE gn2ckan.url (
  mapset_id text NOT NULL,
  protocol text NOT NULL,
  url text NOT NULL,
  url_name text NOT NULL
  CONSTRAINT url_protocol_check CHECK ((protocol = ANY (ARRAY['OGC:WMS','OGC:WMTS','WWW:LINK-1.0-http--link', 'WWW:LINK-1.0-http--related'])))
);
ALTER TABLE gn2ckan.url OWNER TO sis;
GRANT SELECT ON TABLE gn2ckan.url TO sis_r;


--------------------------
--     PRIMARY KEY      --
--------------------------

ALTER TABLE gn2ckan.country ADD PRIMARY KEY (country_id);
ALTER TABLE gn2ckan.group ADD PRIMARY KEY (group_id);
ALTER TABLE gn2ckan.mapset ADD PRIMARY KEY (mapset_id);
ALTER TABLE gn2ckan.mapset ADD UNIQUE (file_identifier);
ALTER TABLE gn2ckan.layer ADD PRIMARY KEY (layer_id);
ALTER TABLE gn2ckan.mapset_x_org_x_ind ADD PRIMARY KEY (country_id, group_id, organisation_id, individual_id, position, tag, role);
ALTER TABLE gn2ckan.organisation ADD PRIMARY KEY (organisation_id);
ALTER TABLE gn2ckan.individual ADD PRIMARY KEY (individual_id);
ALTER TABLE gn2ckan.url ADD PRIMARY KEY (mapset_id, protocol, url);


--------------------------
--     FOREIGN KEY      --
--------------------------


ALTER TABLE gn2ckan.mapset_x_org_x_ind ADD FOREIGN KEY (mapset_id) REFERENCES gn2ckan.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn2ckan.mapset_x_org_x_ind ADD FOREIGN KEY (organisation_id) REFERENCES gn2ckan.organisation(organisation_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn2ckan.mapset_x_org_x_ind ADD FOREIGN KEY (individual_id) REFERENCES gn2ckan.individual(individual_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn2ckan.url ADD FOREIGN KEY (mapset_id) REFERENCES gn2ckan.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn2ckan.layer ADD FOREIGN KEY (mapset_id) REFERENCES gn2ckan.mapset(mapset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn2ckan.mapset ADD FOREIGN KEY (group_id) REFERENCES gn2ckan.group(group_id) ON UPDATE CASCADE ON DELETE CASCADE;
