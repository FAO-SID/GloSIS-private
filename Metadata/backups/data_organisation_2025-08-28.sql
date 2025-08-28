--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-2.pgdg22.04+1)
-- Dumped by pg_dump version 16.2

-- Started on 2025-08-28 20:24:36 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4000 (class 0 OID 54008890)
-- Dependencies: 218
-- Data for Name: organisation; Type: TABLE DATA; Schema: spatial_metadata; Owner: glosis
--

INSERT INTO spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point, phone, facsimile) VALUES ('Departement of Agriculture - Bureau of Soils and Water Management', 'http://www.bswm.da.gov.ph', 'customers.center@bswm.da.gov.ph', 'Philippines', 'Quezon', '1128', 'SRDC Bldg. Elliptical Road corner Visayas Avenue, Diliman', NULL, NULL);
INSERT INTO spatial_metadata.organisation (organisation_id, url, email, country, city, postal_code, delivery_point, phone, facsimile) VALUES ('Bhutan National Soil Services Centre', 'https://www.nssc.gov.bt/', 'nssc@moal.gov.bt', 'Bhutan', 'Thimphu', '11001', 'P. O. Box: 907 Simtokha', NULL, NULL);


-- Completed on 2025-08-28 20:24:36 CEST

--
-- PostgreSQL database dump complete
--

