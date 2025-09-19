INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id) VALUES
('BASAT', 'Base saturation', '%'),
('CORGNTOTR', 'Organic Carbon (C) Nitrogen (N) ratio', 'dimensionless'),
('PHAQ', 'pH - Hydrogen potential in water', 'pH'),
('CFRAGF', 'Coarse fragments - field class', '%')
 ON CONFLICT (property_id) DO NOTHING;

INSERT INTO spatial_metadata.property (property_id, name, unit_of_measure_id, property_type, num_intervals) VALUES
('CLAWRB', 'World Reference Base', 'class', 'categorical', 7)
 ON CONFLICT (property_id) DO NOTHING;
