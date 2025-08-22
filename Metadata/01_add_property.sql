INSERT INTO metadata.property (property_id, name, unit_of_measure_id) VALUES
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
('PHXSD', 'pH - Hydrogen potential standard deviation', 'pH'),
('KEXCSD', 'Potassium (K+) - exchangeable standard deviation', 'cmol(c)/kg');


INSERT INTO metadata.property (property_id, name, unit_of_measure_id, property_type, num_intervals) VALUES
('CLAWRB', 'World Reference Base', 'class', 'categorical', 7);


-- trashed
-- ('ECXU', 'Electrical conductivity uncertainty', 'dS m-1'),
-- ('ECXSE', 'Electrical conductivity spatial estimate', 'dS m-1'),
-- ('ECXTE', 'Electrical conductivity total estimate', 'dS m-1'),
-- ('PHXU', 'pH - Hydrogen potential uncertainty', 'pH'),
-- ('PHXT', 'pH - Hydrogen potential transformed', 'pH'),
-- ('NAEXCU', 'Sodium (Na+) - exchangeable uncertainty', '%'),
-- ('NAEXCPT', 'Sodium (Na+) - exchangeable Percent transformed', '%'),






upper an lower depth up to 10 m
Codigo postal can be be NULL organizacion
add mg/kg http://qudt.org/vocab/unit/MilliGM-PER-KiloGM same as ppm
add tonnes C ha-1 yr-1 = t/(ha·a) https://qudt.org/vocab/unit/TONNE-PER-HA-YR
add class and dimensionless

