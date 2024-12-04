{{ config(
    materialized='incremental',
    unique_key='order_id',
    tags=['staging']
) }}


WITH 

raw_order AS (

    SELECT 
    Order_ID    AS order_id,
    Customer_ID AS customer_id,
    Trip_ID     AS trip_id,
    Price__EUR_  AS price_eur,
    Seat_No     AS seat_number,
    Status      AS status
    FROM {{ source('raw_data', 'raw_order') }}
)

SELECT 
SAFE_CAST(order_id AS INTEGER)      AS order_id,
SAFE_CAST(customer_id AS INTEGER)   AS customer_id,
SAFE_CAST(trip_id AS INTEGER)       AS trip_id,
SAFE_CAST(price_eur AS INT64)       AS price_eur,
SAFE_CAST(seat_number AS STRING)    AS seat_number,
SAFE_CAST(status AS STRING)         AS status,
CURRENT_TIMESTAMP()                 AS meta_processing_time
FROM raw_order

{% if is_incremental() %}

WHERE order_id NOT IN (SELECT DISTINCT order_id FROM {{ this }})

{% endif %}