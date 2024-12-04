{{ 
    config(
        materialized='incremental',
        unique_key='aeroplane_model_id',
        tags=['staging']
    ) 
}}

WITH 

raw_aeroplane AS (

    SELECT 
    ABS(FARM_FINGERPRINT(model)) AS aeroplane_model_id,
    manufacturer    AS aeroplane_manufacturer,
    model           AS aeroplane_model,
    max_seats       AS max_seats,
    max_weight      AS max_weight,
    max_distance    AS max_distance,
    engine_type     AS engine_type,
    FROM {{ source('raw_data', 'raw_aeroplane_model') }}
)

SELECT 
SAFE_CAST(aeroplane_model_id AS INTEGER)        AS aeroplane_model_id,
SAFE_CAST(aeroplane_manufacturer AS STRING)     AS aeroplane_manufacturer,
SAFE_CAST(aeroplane_model AS STRING)            AS aeroplane_model,
SAFE_CAST(max_seats AS INTEGER)                 AS max_seats, 
SAFE_CAST(max_weight AS INT64)                  AS max_weight,
SAFE_CAST(max_distance AS INT64)                AS max_distance,
SAFE_CAST(engine_type AS STRING)                AS engine_type,
CURRENT_TIMESTAMP()                             AS meta_processing_time
FROM raw_aeroplane
