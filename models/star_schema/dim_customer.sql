
{{ config(
    materialized='incremental',
    unique_key='customer_id',
    tags=['star_schema']
) }}

WITH 

customer AS (

    SELECT 
    cust.customer_id                                                            AS customer_id,
    cust.customer_full_name                                                     AS customer_full_name,
    cust.customer_group_id                                                      AS customer_group_id,
    cust.email                                                                  AS email,
    cust.phone_number                                                           AS phone_number,
    cust.meta_processing_time                                                   AS customer_meta_processing_time,
    SUM(CASE WHEN status IN ("Booked","Finished") THEN ord.price_eur END)       AS revenue_generated,
    COUNT(CASE WHEN status IN ("Booked","Finished") THEN ord.order_id END)      AS orders_placed,
    MAX(DATETIME(ord.meta_processing_time))                                     AS last_order_datetime, 
    --assuming that order datetime is the same as the moment when the entry was ingested in staging_order table

    FROM {{ ref('staging_customer') }} AS cust
    LEFT JOIN {{ ref('staging_order') }} AS ord
    ON cust.customer_id=ord.customer_id
    GROUP BY 1,2,3,4,5,6
)

SELECT
customer_id,
customer_full_name,
customer_group_id,
email,
phone_number,
revenue_generated,
orders_placed,
last_order_datetime,
customer_meta_processing_time
FROM customer