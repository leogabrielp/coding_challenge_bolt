{{ config(
    materialized='incremental',
    unique_key='trip_id',
    tags=['star_schema']
) }}

WITH 

trips AS (

        SELECT 
        trip_id,
        origin_city,
        destination_city,
        aeroplane_id,
        start_timestamp,
        end_timestamp,
        DATE_DIFF(DATETIME(end_timestamp), DATETIME(start_timestamp),MINUTE) AS trip_duration_minutes,
        meta_processing_time
        FROM {{ ref('staging_trip') }} trip

        {% if is_incremental() %}
        
        WHERE CURRENT_DATE()  <=  DATE(start_timestamp)
        --If incremental, only look for those trips that didnt start yet, so still receiving orders
        {% endif %}

)

,kpis_computation AS (

    SELECT 
    ord.trip_id                                                             AS trip_id,
    COUNT(ord.order_id)                                                     AS total_orders,
    COUNT(CASE WHEN status IN ("Cancelled") THEN ord.order_id ELSE 0 END)   AS cancelled_orders,
    SUM(ord.price_eur)                                                      AS total_revenue,
    SUM(CASE WHEN status IN ("Cancelled") THEN ord.price_eur ELSE 0 END)    AS revenue_cancelled_orders,
    FROM {{ ref('staging_order') }} AS ord
    INNER JOIN trips --join to only compute kpis for trips that didnt start yet
    ON ord.trip_id=trips.trip_id
    GROUP BY 1


)

SELECT
trips.trip_id,
trips.origin_city,
trips.destination_city,
trips.aeroplane_id,
trips.start_timestamp,
trips.end_timestamp,
trips.trip_duration_minutes,
kpis.total_orders,
kpis.cancelled_orders,
kpis.total_revenue,
kpis.revenue_cancelled_orders,
trips.meta_processing_time
FROM trips
INNER JOIN kpis_computation AS kpis
ON trips.trip_id=kpis.trip_id 
