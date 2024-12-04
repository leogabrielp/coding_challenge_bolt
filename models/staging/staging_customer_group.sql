{{ 
    config(
        materialized='incremental',
        unique_key='customer_group_id',
        tags=['staging']
    ) 
}}

WITH 

raw_customer_group AS (

    SELECT 
    ID              AS customer_group_id,
    Type            AS customer_group_type,
    Name            AS customer_group_name,
    Registry_number AS registry_number,
    FROM {{ source('raw_data', 'raw_customer_group') }}
)

SELECT 
SAFE_CAST(customer_group_id AS INTEGER)     AS customer_group_id,
SAFE_CAST(customer_group_type AS STRING)    AS customer_group_type,
SAFE_CAST(customer_group_name AS STRING)    AS customer_group_name,
SAFE_CAST(registry_number AS STRING)        AS registry_number,
CURRENT_TIMESTAMP()                         AS meta_processing_time
FROM raw_customer_group