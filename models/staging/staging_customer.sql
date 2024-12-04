{{ config(
    materialized='incremental',
    unique_key='customer_id',
    tags=['staging']
) }}

WITH 

raw_customer AS (

    SELECT 
    Customer_ID         AS customer_id,
    Name                AS customer_full_name,
    Customer_Group_ID   AS customer_group_id,
    Email               AS email,
    Phone_Number        AS phone_number
    FROM {{ source('raw_data', 'raw_customer') }}
)

SELECT 
SAFE_CAST(customer_id AS INTEGER)       AS customer_id,
SAFE_CAST(customer_full_name AS STRING) AS customer_full_name,
SAFE_CAST(customer_group_id AS INTEGER) AS customer_group_id,
SAFE_CAST(email AS STRING)              AS email,
SAFE_CAST(phone_number AS STRING)       AS phone_number,
CURRENT_TIMESTAMP()                     AS meta_processing_time
FROM raw_customer
