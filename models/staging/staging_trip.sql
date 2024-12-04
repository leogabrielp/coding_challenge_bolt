{{ config(
    materialized='incremental',
    unique_key='trip_id',
    partition_by={'field': 'DATE(start_timestamp)', 'data_type': 'date'},
    tags=['staging']
) }}

WITH

raw_trip AS (

    SELECT 
    Trip_ID         AS trip_id,
    Origin_City     AS origin_city,
    Destination_City AS destination_city,
    Airplane_ID     AS aeroplane_id,
    Start_Timestamp AS start_timestamp,
    End_Timestamp   AS end_timestamp
    FROM {{ source('raw_data', 'raw_trip') }}
)

SELECT 
SAFE_CAST(trip_id AS INTEGER)                       AS trip_id,
SAFE_CAST(origin_city AS STRING)                    AS origin_city,
SAFE_CAST(destination_city AS STRING)               AS destination_city,
SAFE_CAST(aeroplane_id AS INTEGER)                  AS aeroplane_id,
SAFE_CAST(start_timestamp AS TIMESTAMP)             AS start_timestamp,
SAFE_CAST(end_timestamp AS TIMESTAMP)               AS end_timestamp,
CURRENT_TIMESTAMP()                                 AS meta_processing_time
FROM raw_trip