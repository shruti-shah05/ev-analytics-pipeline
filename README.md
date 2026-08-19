# ev-analytics-pipeline
An end-to-end analytics pipeline built with Snowflake and Power BI to analyze  electric vehicle adoption trends across Washington State (2017–2026).

CSV Files (WA State Open Data)
│
▼
Snowflake Internal Stage (ev_stage)
│
▼
Raw Schema (exact copy of source data)
├── raw_ev_population (280,821 rows)
└── raw_ev_county_history (34,671 rows)
│
▼
Marts Schema (star schema)
├── dim_vehicle (732 unique vehicles)
├── dim_location (988 unique locations)
├── fct_ev_registrations (280,821 rows)
└── fct_ev_adoption_by_county (34,671 rows)
│
▼
Power BI Dashboard

## Data Sources
- **EV Population Data** — Washington State Department of Licensing
  via [data.wa.gov](https://data.wa.gov)
- **EV Population Size History By County** — Washington State DOL
  via [data.wa.gov](https://data.wa.gov)

## Tech Stack
| Tool      | Purpose |
|---------  |---------|
| Snowflake | Cloud data warehouse — storage + compute |
| SQL       | Data transformation + star schema modeling |
| Power BI  | Dashboard + visualization |

## Key Snowflake Concepts Applied
- **Virtual warehouse** with AUTO_SUSPEND (60s) for cost optimization
- **Internal stage** for CSV file landing before bulk load
- **COPY INTO** with MATCH_BY_COLUMN_NAME for header-based loading
- **PARSE_HEADER** file format for automatic column detection
- **Raw/Marts schema separation** following medallion architecture principles
- **Surrogate keys** for dimension table relationships
