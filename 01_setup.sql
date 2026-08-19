-- File Description: Creates compute, database, schemas, file format, and stage for the pipeline

-- Create Virtual Warehouse
-- AUTO_SUSPEND = 60 seconds to minimize credit usage
CREATE WAREHOUSE IF NOT EXISTS ev_wh
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create Database and Schemas
CREATE DATABASE IF NOT EXISTS ev_analytics;
CREATE SCHEMA IF NOT EXISTS ev_analytics.raw;
CREATE SCHEMA IF NOT EXISTS ev_analytics.marts;

USE WAREHOUSE ev_wh;
USE DATABASE ev_analytics;
USE SCHEMA raw;

USE WAREHOUSE ev_wh;
USE DATABASE ev_analytics;
USE SCHEMA raw;

/*
Create File Format
PARSE_HEADER = TRUE treats row 1 as column names
FIELD_OPTIONALLY_ENCLOSED_BY handles quoted fields
NULL_IF converts empty strings to NULL
*/
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  PARSE_HEADER = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL');

-- Create Internal Stage
CREATE OR REPLACE STAGE ev_stage
  FILE_FORMAT = csv_format;

LIST @ev_analytics.raw.ev_stage;