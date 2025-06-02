INSERT INTO metadata.project (country_id, project_id, project_name) SELECT 'BT', project_id, project_name FROM metadata.project WHERE country_id = 'PH';
INSERT INTO metadata.project (country_id, project_id, project_name) VALUES ('BT', 'OTHER', 'Other maps');


INSERT INTO metadata.property (property_id, name, unit_id) VALUES
('CORGASRBAUU', 'Organic Carbon Sequestration Potential - ASR Business As Usual (BAU) uncertainty', 'tonnes C ha-1 yr-1'),
('CORGASRSSM1U', 'Organic Carbon Sequestration Potential - ASR SSM1 uncertainty', 'tonnes C ha-1 yr-1'),
('CORGASRSSM2U', 'Organic Carbon Sequestration Potential - ASR SSM2 uncertainty', 'tonnes C ha-1 yr-1'),
('CORGASRSSM3U', 'Organic Carbon Sequestration Potential - ASR SSM3 uncertainty', 'tonnes C ha-1 yr-1'),
('CORGBAUU', 'Organic Carbon Sequestration Potential - Business As Usual (BAU) uncertainty', 'tonnes C ha-1 yr-1'),
('CORGT0U', 'Organic Carbon Sequestration Potential - Time Zero (TO) uncertainty', 'tonnes C ha-1 yr-1'),
('KXXSD', 'Potassium (K) standard deviation', 'ppm'),
('PXXSD', 'Phosphorus (P) standard deviation', 'ppm'),
('BKDSD', 'Bulk density standard deviation', 'g/cm3'),
('BASAT', 'Base saturation', '%'),
('BASATSD', 'Base saturation standard deviation', '%'),
('CECSD', 'Cation exchange capacity standard deviation', 'cmol(c)/kg'),
('CLAYSD', 'Clay texture fraction standard deviation', '%'),
('CORGNTOTR', 'Organic Carbon (C) Nitrogen (N) ratio', 'dimensionless'),
('CORGNTOTRSD', 'Organic Carbon (C) Nitrogen (N) ratio standard deviation', 'dimensionless'),
('CORGSD', 'Carbon (C) - organic standard deviation', '%'),
('PHAQ', 'pH - Hydrogen potential in water', 'pH'),
('PHAQSD', 'pH - Hydrogen potential in water standard deviation', 'pH'),
('SALTU', 'Salinification uncertainty', 'class'),
('SANDSD', 'Sand texture fraction standard deviation', '%'),
('SILTSD', 'Silt texture fraction standard deviation', '%'),
('NTOTSD', 'Nitrogen (N) - total standard deviation', '%'),
('CAEXCSD', 'Calcium (Ca++) - exchangeable standard deviation', 'cmol(c)/kg'),
('CFRAGF', 'Coarse fragments - field class', '%'),
('CFRAGFSD', 'Coarse fragments - field class standard deviation', '%'),
('MGEXCSD', 'Magnesium (Mg++) - exchangeable standard deviation', 'cmol(c)/kg'),
('NAEXCSD', 'Sodium (Na+) - exchangeable standard deviation', '%'),
('BSEXCSD', 'Exchangeable bases standard deviation', 'cmol(c)/kg'),
('ECXSD', 'Electrical conductivity standard deviation', 'dS m-1'),
('ECXU', 'Electrical conductivity uncertainty', 'dS m-1'),
('ECXSE', 'Electrical conductivity spatial estimate', 'dS m-1'),
('ECXTE', 'Electrical conductivity total estimate', 'dS m-1'),
('NAEXCU', 'Sodium (Na+) - exchangeable uncertainty', '%'),
('NAEXCPT', 'Sodium (Na+) - exchangeable Percent transformed', '%'),
('PHXSD', 'pH - Hydrogen potential standard deviation', 'pH'),
('PHXU', 'pH - Hydrogen potential uncertainty', 'pH'),
('PHXT', 'pH - Hydrogen potential transformed', 'pH');

INSERT INTO metadata.property (property_id, name, unit_id, property_type, num_intervals) VALUES
('CLAWRB', 'World Reference Base', 'class', 'categorical', 7);


