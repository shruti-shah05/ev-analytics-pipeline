-- File Description: Transforms raw tables into a star schema with dimension and fact tables for Power BI

USE WAREHOUSE ev_wh;
USE DATABASE ev_analytics;
USE SCHEMA marts;

-- Dimension: Vehicle
-- Grain: one row per unique Make + Model + Year + EV Type
-- Surrogate key: vehicle_key
CREATE OR REPLACE TABLE dim_vehicle AS
SELECT DISTINCT
    "Make" || ' - ' || "Model" || ' - ' || "Model Year" || ' - ' || "Electric Vehicle Type" AS vehicle_key,
    "Make",
    "Model",
    "Model Year",
    "Electric Vehicle Type",
     MAX("Electric Range") AS electric_range
FROM raw.raw_ev_population
GROUP BY
    "Make" || ' - ' || "Model" || ' - ' || "Model Year" || ' - ' || "Electric Vehicle Type",
    "Make",
    "Model",
    "Model Year",
    "Electric Vehicle Type";

-- Dimension: Location
-- Grain: one row per unique County + City + State
-- Surrogate key: location_key
CREATE OR REPLACE TABLE dim_location AS
SELECT
    "County" || ' - ' || "City" || ' - ' || "State" AS location_key,
    "County",
    "City",
    "State",
    MAX("Postal Code") AS postal_code
FROM raw.raw_ev_population
WHERE "County" IS NOT NULL 
  AND "City" IS NOT NULL
GROUP BY
    "County" || ' - ' || "City" || ' - ' || "State",
    "County",
    "City",
    "State";

-- Fact: EV Registrations
-- Grain: one row per registered vehicle (VIN)
-- Foreign keys: vehicle_key, location_key
CREATE OR REPLACE TABLE fct_ev_registrations AS
SELECT
    "VIN (1-10)"                                                                             AS vin,
    "Make" || ' - ' || "Model" || ' - ' || "Model Year" || ' - ' || "Electric Vehicle Type" AS vehicle_key,
    "County" || ' - ' || "City" || ' - ' || "State"                                         AS location_key,
    "Make",
    "Model",
    "Model Year",
    "County",
    "City",
    "State",
    "Postal Code",
    "Electric Vehicle Type",
    "Electric Range"
FROM raw.raw_ev_population
WHERE "County" IS NOT NULL 
  AND "City" IS NOT NULL;

-- Fact: EV Adoption Over Time By County
/*
Grain: one row per county per month
Tracks BEV and PHEV counts over time
REPLACE() strips comma formatting from numbers. '9,653' → 9653 before casting to NUMBER
*/
CREATE OR REPLACE TABLE fct_ev_adoption_by_county AS
SELECT
    "Date",
    "County",
    "State",
    "Vehicle Primary Use",
    REPLACE("Battery Electric Vehicles (BEVs)", ',', '')::NUMBER AS bev_count,
    REPLACE("Plug-In Hybrid Electric Vehicles (PHEVs)", ',', '')::NUMBER AS phev_count,
    REPLACE("Electric Vehicle (EV) Total", ',', '')::NUMBER AS ev_total
FROM raw.raw_ev_county_history;

-- Row count summary
SELECT 'dim_vehicle' AS table_name, COUNT(*) AS row_count 
FROM marts.dim_vehicle
UNION ALL
SELECT 'dim_location', COUNT(*) 
FROM marts.dim_location
UNION ALL
SELECT 'fct_ev_registrations', COUNT(*) 
FROM marts.fct_ev_registrations
UNION ALL
SELECT 'fct_ev_adoption_by_county', COUNT(*) 
FROM marts.fct_ev_adoption_by_county;


-- Verify no duplicates
SELECT location_key, COUNT(*) 
FROM marts.dim_location 
GROUP BY location_key 
HAVING COUNT(*) > 1;


SELECT COUNT(*) FROM marts.dim_location;