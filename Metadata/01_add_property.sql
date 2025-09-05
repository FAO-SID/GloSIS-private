-- INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id) VALUES
-- ('CORGASRBAUU', 'Organic Carbon Sequestration Potential - ASR Business As Usual (BAU) uncertainty', 't/(ha·a)'),
-- ('CORGASRSSM1U', 'Organic Carbon Sequestration Potential - ASR SSM1 uncertainty', 't/(ha·a)'),
-- ('CORGASRSSM2U', 'Organic Carbon Sequestration Potential - ASR SSM2 uncertainty', 't/(ha·a)'),
-- ('CORGASRSSM3U', 'Organic Carbon Sequestration Potential - ASR SSM3 uncertainty', 't/(ha·a)'),
-- ('CORGT0U', 'Organic Carbon Sequestration Potential - Time Zero (TO) uncertainty', 't/(ha·a)'),
-- ('KXXSD', 'Potassium (K) standard deviation', 'ppm'),
-- ('PXXSD', 'Phosphorus (P) standard deviation', 'ppm'),
-- ('BKDSD', 'Bulk density standard deviation', 'g/cm3'),
-- ('BASATSD', 'Base saturation standard deviation', '%'),
-- ('CECSD', 'Cation exchange capacity standard deviation', 'cmol(c)/kg'),
-- ('CLAYSD', 'Clay texture fraction standard deviation', '%'),
-- ('CORGNTOTRSD', 'Organic Carbon (C) Nitrogen (N) ratio standard deviation', 'dimensionless'),
-- ('CORGSD', 'Carbon (C) - organic standard deviation', '%'),
-- ('PHAQSD', 'pH - Hydrogen potential in water standard deviation', 'pH'),
-- ('SALTU', 'Salinification uncertainty', 'class'),
-- ('SANDSD', 'Sand texture fraction standard deviation', '%'),
-- ('SILTSD', 'Silt texture fraction standard deviation', '%'),
-- ('NTOTSD', 'Nitrogen (N) - total standard deviation', '%'),
-- ('CAEXCSD', 'Calcium (Ca++) - exchangeable standard deviation', 'cmol(c)/kg'),
-- ('CFRAGFSD', 'Coarse fragments - field class standard deviation', '%'),
-- ('MGEXCSD', 'Magnesium (Mg++) - exchangeable standard deviation', 'cmol(c)/kg'),
-- ('NAEXCSD', 'Sodium (Na+) - exchangeable standard deviation', '%'),
-- ('BSEXCSD', 'Exchangeable bases standard deviation', 'cmol(c)/kg'),
-- ('ECXSD', 'Electrical conductivity standard deviation', 'dS m-1'),
-- ('PHXSD', 'pH - Hydrogen potential standard deviation', 'pH'),
-- ('KEXCSD', 'Potassium (K+) - exchangeable standard deviation', 'cmol(c)/kg')
--  ON CONFLICT (property_id) DO NOTHING;

INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id) VALUES
('BASAT', 'Base saturation', '%'),
('CORGNTOTR', 'Organic Carbon (C) Nitrogen (N) ratio', 'dimensionless'),
('PHAQ', 'pH - Hydrogen potential in water', 'pH'),
('CFRAGF', 'Coarse fragments - field class', '%')
 ON CONFLICT (property_id) DO NOTHING;

INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, property_type, num_intervals) VALUES
('CLAWRB', 'World Reference Base', 'class', 'categorical', 7)
 ON CONFLICT (property_id) DO NOTHING;
