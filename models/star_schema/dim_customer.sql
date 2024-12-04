
{{ config(
    materialized='incremental',
    unique_key='customer_id',
    tags=['star_schema']
) }}

WITH customer AS (

    SELECT 
    cust.customer_id            AS customer_id,
    cust.customer_full_name     AS customer_full_name,
    cust.customer_group_id      AS customer_group_id,
    cust.email                  AS email,
    cust.phone_number           AS phone_number,
    grou.customer_group_name    AS customer_group_name,
    cust.meta_processing_time   AS customer_meta_processing_time
    FROM {{ ref('staging_customer') }} cust
    LEFT JOIN {{ ref('staging_customer_group') }} grou
    ON cust.customer_group_id=grou.customer_group_id
)

SELECT
customer_id,
customer_full_name,
customer_group_id,
email,
phone_number,
customer_group_name,
customer_meta_processing_time
FROM customer