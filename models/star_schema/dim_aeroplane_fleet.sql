{{ config(
    materialized='incremental',
    unique_key='customer_id',
    tags=['star_schema']
) }}

WITH

fleet AS (

    SELECT 
    aero.aeroplane_id,
    aero.aeroplane_model,
    model.aeroplane_model_id,
    model.aeroplane_manufacturer,
    aero.manufacturer,
    aero.meta_processing_time,
    FROM {{ ref('staging_aeroplane') }} AS aero
    LEFT JOIN {{ ref('staging_aeroplane_model') }} AS model
    ON LOWER(aero.aeroplane_model) = LOWER(model.aeroplane_model)

)


SELECT 
aeroplane_id,
aeroplane_model,
aeroplane_model_id,
aeroplane_manufacturer,
manufacturer,
meta_processing_time
FROM fleet
