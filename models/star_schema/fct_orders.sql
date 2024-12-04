{{ config(
    materialized='incremental',
    unique_key='order_id',
    tags=['star_schema']
) }}


WITH 

orders AS (

        SELECT 
        ord.order_id                                        AS order_id,
        ord.customer_id                                     AS customer_id,
        cust.customer_group_id                              AS customer_group_id,
        trip.origin_city                                    AS origin_city,
        trip.destination_city                               AS destination_city,
        DATE_DIFF(trip.end_timestamp,trip.start_timestamp)  AS trip_duration_minutes,
        trip.aeroplane_id                                   AS aeroplane_id,
        trip.trip_id                                        AS trip_id,
        ord.price_eur                                       AS price_eur,
        ord.meta_processing_time                            AS order_meta_processing_time
        FROM {{ ref('staging_order') }} ord
        LEFT JOIN {{ ref('staging_customer') }} cust 
        ON ord.customer_id = customer.customer_id
        LEFT JOIN {{ ref('staging_trip') }} trip 
        ON o.trip_id = t.trip_id
)

SELECT 
order_id,
customer_id,
customer_group_id,
origin_city,
destination_city,
trip_duration_minutes,
aeroplane_id,
trip_id,
price_eur,
order_meta_processing_time
FROM orders