{{ config(
    materialized='incremental',
    unique_key='aeroplane_id',
    tags=['staging']
) }}

WITH 

raw_aeroplane AS (

    SELECT 
    Airplane_ID     AS aeroplane_id,
    Airplane_Model  AS aeroplane_model,
    Manufacturer    AS manufacturer
    FROM {{ source('raw_data', 'raw_aeroplane') }}

)

SELECT 
SAFE_CAST(aeroplane_id AS INTEGER)   AS aeroplane_id,
SAFE_CAST(aeroplane_model AS STRING) AS aeroplane_model,
SAFE_CAST(manufacturer AS STRING)    AS manufacturer,
CURRENT_TIMESTAMP()                  AS meta_processing_time
FROM raw_aeroplane