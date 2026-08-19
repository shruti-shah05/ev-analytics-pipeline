-- File Description: Creates raw tables from CSV headers using INFER_SCHEMA and loads data via COPY INTO
USE WAREHOUSE ev_wh;
USE DATABASE ev_analytics;
USE SCHEMA raw;

-- Create Raw Tables USING TEMPLATE + INFER_SCHEMA 
-- EV Population table (one row per registered vehicle)
CREATE OR REPLACE TABLE raw_ev_population
USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION => '@ev_stage/Electric_Vehicle_Population_Data.csv',
      FILE_FORMAT => 'csv_format'
    )
  )
);

-- Create county history table (monthly EV counts by county)
CREATE OR REPLACE TABLE raw_ev_county_history
USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION => '@ev_stage/Electric_Vehicle_Population_Size_History_By_County.csv',
      FILE_FORMAT => 'csv_format'
    )
  )
);

/*
Load Data via COPY INTO
MATCH_BY_COLUMN_NAME matches CSV headers to table columns automatically 
ON_ERROR = CONTINUE skips bad rows instead of failing
*/

-- Load EV population data (~280K rows)
COPY INTO raw_ev_population
  FROM @ev_stage/Electric_Vehicle_Population_Data.csv
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Load county history data (~34K rows)
COPY INTO raw_ev_county_history
  FROM @ev_stage/Electric_Vehicle_Population_Size_History_By_County.csv
  FILE_FORMAT = (FORMAT_NAME = 'csv_format')
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Verify Row Counts
SELECT COUNT(*) FROM raw_ev_population;       -- expect ~280,833
SELECT COUNT(*) FROM raw_ev_county_history;   -- expect ~34,671