#!/bin/bash

# Set country
COUNTRY_ID=BD

psql -h localhost -p 5432 -U glosis -d iso19139 -c "DROP TABLE IF EXISTS spatial_metadata.tmp"
psql -h localhost -p 5432 -U glosis -d iso19139 -c "CREATE TABLE spatial_metadata.tmp (project_id text, file text, property_id text)"

psql -h localhost -p 5432 -U glosis -d iso19139 -c "
    INSERT INTO spatial_metadata.tmp VALUES
('GSNM', 'BGD_class_peat.tif', 'PEAT'),
('GSNM', 'BGD_probability_peat.tif', 'PEAT'),
('GSNM', 'BGD_mean_bd_0_30.tif', 'BKD'),
('GSNM', 'BGD_mean_bd_30_60.tif', 'BKD'),
('GSNM', 'BGD_mean_bd_60_120.tif', 'BKD'),
('GSNM', 'BGD_mean_caco3_0_30.tif', 'CACO3ET'),
('GSNM', 'BGD_mean_caco3_30_60.tif', 'CACO3ET'),
('GSNM', 'BGD_mean_caco3_60_120.tif', 'CACO3ET'),
('GSNM', 'BGD_mean_cec_0_30.tif', 'CEC'),
('GSNM', 'BGD_mean_cec_30_60.tif', 'CEC'),
('GSNM', 'BGD_mean_cec_60_120.tif', 'CEC'),
('GSNM', 'BGD_mean_clay_0_30.tif', 'CLAY'),
('GSNM', 'BGD_mean_clay_30_60.tif', 'CLAY'),
('GSNM', 'BGD_mean_clay_60_120.tif', 'CLAY'),
('GSNM', 'BGD_mean_ec_0_30.tif', 'ECX'),
('GSNM', 'BGD_mean_ec_30_60.tif', 'ECX'),
('GSNM', 'BGD_mean_ec_60_120.tif', 'ECX'),
('GSNM', 'BGD_mean_ocs_0_30.tif', 'CORGS'),
('GSNM', 'BGD_mean_ocs_30_60.tif', 'CORGS'),
('GSNM', 'BGD_mean_ocs_60_120.tif', 'CORGS'),
('GSNM', 'BGD_mean_ph_0_10.tif', 'PHX'),
('GSNM', 'BGD_mean_ph_0_30.tif', 'PHX'),
('GSNM', 'BGD_mean_ph_30_60.tif', 'PHX'),
('GSNM', 'BGD_mean_ph_60_120.tif', 'PHX'),
('GSNM', 'BGD_mean_sand_0_30.tif', 'SAND'),
('GSNM', 'BGD_mean_sand_30_60.tif', 'SAND'),
('GSNM', 'BGD_mean_sand_60_120.tif', 'SAND'),
('GSNM', 'BGD_mean_silt_0_30.tif', 'SILT'),
('GSNM', 'BGD_mean_silt_30_60.tif', 'SILT'),
('GSNM', 'BGD_mean_silt_60_120.tif', 'SILT'),
('GSNM', 'BGD_mean_soc_0_10.tif', 'CORG'),
('GSNM', 'BGD_mean_soc_0_30.tif', 'CORG'),
('GSNM', 'BGD_mean_soc_30_60.tif', 'CORG'),
('GSNM', 'BGD_mean_soc_60_120.tif', 'CORG'),
('GSNM', 'BGD_mean_tn_0_30.tif', 'NTOT'),
('GSNM', 'BGD_mean_tn_30_60.tif', 'NTOT'),
('GSNM', 'BGD_mean_tn_60_120.tif', 'NTOT'),
('GSNM', 'BGD_sd_bd_0_30.tif', 'BKD'),
('GSNM', 'BGD_sd_bd_30_60.tif', 'BKD'),
('GSNM', 'BGD_sd_bd_60_120.tif', 'BKD'),
('GSNM', 'BGD_sd_caco3_0_30.tif', 'CACO3ET'),
('GSNM', 'BGD_sd_caco3_30_60.tif', 'CACO3ET'),
('GSNM', 'BGD_sd_caco3_60_120.tif', 'CACO3ET'),
('GSNM', 'BGD_sd_cec_0_30.tif', 'CEC'),
('GSNM', 'BGD_sd_cec_30_60.tif', 'CEC'),
('GSNM', 'BGD_sd_cec_60_120.tif', 'CEC'),
('GSNM', 'BGD_sd_clay_0_30.tif', 'CLAY'),
('GSNM', 'BGD_sd_clay_30_60.tif', 'CLAY'),
('GSNM', 'BGD_sd_clay_60_120.tif', 'CLAY'),
('GSNM', 'BGD_sd_ec_0_30.tif', 'ECX'),
('GSNM', 'BGD_sd_ec_30_60.tif', 'ECX'),
('GSNM', 'BGD_sd_ec_60_120.tif', 'ECX'),
('GSNM', 'BGD_sd_ocs_0_30.tif', 'CORGS'),
('GSNM', 'BGD_sd_ocs_30_60.tif', 'CORGS'),
('GSNM', 'BGD_sd_ocs_60_120.tif', 'CORGS'),
('GSNM', 'BGD_sd_ph_0_10.tif', 'PHX'),
('GSNM', 'BGD_sd_ph_0_30.tif', 'PHX'),
('GSNM', 'BGD_sd_ph_30_60.tif', 'PHX'),
('GSNM', 'BGD_sd_ph_60_120.tif', 'PHX'),
('GSNM', 'BGD_sd_sand_0_30.tif', 'SAND'),
('GSNM', 'BGD_sd_sand_30_60.tif', 'SAND'),
('GSNM', 'BGD_sd_sand_60_120.tif', 'SAND'),
('GSNM', 'BGD_sd_silt_0_30.tif', 'SILT'),
('GSNM', 'BGD_sd_silt_30_60.tif', 'SILT'),
('GSNM', 'BGD_sd_silt_60_120.tif', 'SILT'),
('GSNM', 'BGD_sd_soc_0_10.tif', 'CORG'),
('GSNM', 'BGD_sd_soc_0_30.tif', 'CORG'),
('GSNM', 'BGD_sd_soc_30_60.tif', 'CORG'),
('GSNM', 'BGD_sd_soc_60_120.tif', 'CORG'),
('GSNM', 'BGD_sd_tn_0_30.tif', 'NTOT'),
('GSNM', 'BGD_sd_tn_30_60.tif', 'NTOT'),
('GSNM', 'BGD_sd_tn_60_120.ti', 'NTOT')"




psql -h localhost -p 5432 -U glosis -d iso19139 -c "\copy (
        SELECT  t.project_id AS project, 
                t.file, 
                p.property_id AS code, 
                p.name, 
                p.unit_of_measure_id AS unit
        FROM spatial_metadata.tmp t
        LEFT JOIN spatial_metadata.property p ON p.property_id = t.property_id 
        ORDER BY p.property_id
        ) 
TO '/home/carva014/Downloads/${COUNTRY_ID}-Property_list_for_validation.csv' WITH CSV HEADER";

psql -h localhost -p 5432 -U glosis -d iso19139 -c "DROP TABLE IF EXISTS spatial_metadata.tmp"


# VN
#     ('GSAS', 'Top0_30ECse_VN.tif', 'ECX'),
#     ('GSAS', 'Top0_30ESP_VN.tif', 'NAEXC'),
#     ('GSAS', 'Top0_30saltaffected_VN.tif', 'SALT'),
#     ('GSNM','VNM_mean_avai_k2o_0_30.tif', 'KEXT'),
#     ('GSNM','VNM_mean_avai_p2o5_0_30.tif', 'PEXT'),
#     ('GSNM','VNM_mean_base_sat_0_30.tif', 'BASAT'),
#     ('GSNM','VNM_mean_bd_0_30.tif', 'BKD'),
#     ('GSNM','VNM_mean_cec_0_30.tif', 'CEC'),
#     ('GSNM','VNM_mean_clay_0_30.tif', 'CLAY'),
#     ('GSNM','VNM_mean_crf_0_30.tif', 'CFRAGF'),
#     ('GSNM','VNM_mean_ec_0_30.tif', 'ECX'),
#     ('GSNM','VNM_mean_ocs_0_30.tif', 'CORGS'),
#     ('GSNM','VNM_mean_ph_0_30.tif', 'PHX'),
#     ('GSNM','VNM_mean_sand_0_30.tif', 'SAND'),
#     ('GSNM','VNM_mean_silt_0_30.tif', 'SILT'),
#     ('GSNM','VNM_mean_sum_bases_0_30.tif', 'BSATS'),
#     ('GSNM','VNM_mean_total_k2o_0_30.tif', 'KTOT'),
#     ('GSNM','VNM_mean_total_n_0_30.tif', 'NTOT'),
#     ('GSNM','VNM_mean_total_oc_0_30.tif', 'CORG'),
#     ('GSNM','VNM_mean_total_p2o5_0_30.tif', 'PTOT'),
#     ('GSNM','VNM_sd_avai_k2o_0_30.tif', 'KEXT'),
#     ('GSNM','VNM_sd_avai_p2o5_0_30.tif', 'PEXT'),
#     ('GSNM','VNM_sd_base_sat_0_30.tif', 'BASAT'),
#     ('GSNM','VNM_sd_bd_0_30.tif', 'BKD'),
#     ('GSNM','VNM_sd_cec_0_30.tif', 'CEC'),
#     ('GSNM','VNM_sd_clay_0_30.tif', 'CLAY'),
#     ('GSNM','VNM_sd_crf_0_30.tif', 'CFRAGF'),
#     ('GSNM','VNM_sd_ec_0_30.tif', 'ECX'),
#     ('GSNM','VNM_sd_ocs_0_30.tif', 'CORGS'),
#     ('GSNM','VNM_sd_ph_0_30.tif', 'PHX'),
#     ('GSNM','VNM_sd_sand_0_30.tif', 'SAND'),
#     ('GSNM','VNM_sd_silt_0_30.tif', 'SILT'),
#     ('GSNM','VNM_sd_sum_bases_0_30.tif', 'BSATS'),
#     ('GSNM','VNM_sd_total_k2o_0_30.tif', 'KTOT'),
#     ('GSNM','VNM_sd_total_n_0_30.tif', 'NTOT'),
#     ('GSNM','VNM_sd_total_oc_0_30.tif', 'CORG'),
#     ('GSNM','VNM_sd_total_p2o5_0_30.tif', 'PTOT')"