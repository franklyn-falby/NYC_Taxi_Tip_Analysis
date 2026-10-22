/*
Question: What is the average tip percentage by pickup borough and time of day?
- Identify the average tip percentage for each pickup borough across five time buckets
  (Early Morning, Morning, Afternoon, Evening, Night) for taxi trips in April 2026.
- Focuses on trip records with fare amounts greater than or equal to 3.
- Focuses on trip records paid for with credit card only.
- Focuses on borough where the pickup occurred.
- Focuses on trips with a recorded tip.
- Focuses on the time of day when the pickup occurred.
- Why? Identify whether the time of day tipping pattern holds across boroughs or whether
  the best time to get tipped depends on where the pickup happens.
  */

WITH tip_percentage AS (
    SELECT
        pu.borough AS pickup_borough,
        CASE
            WHEN EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 1 AND 5 THEN 'Early Morning'
            WHEN EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 17 AND 20 THEN 'Evening'
            ELSE 'Night'
        END AS hour_type,
        fare_amount,
        tip_amount,
        ((tip_amount*100)/fare_amount) AS tip_percentage
    FROM
        taxi_trip_records t
    INNER JOIN
        taxi_zone_lookup pu ON t.pulocationid = pu.locationid
    WHERE
        fare_amount >= 3
        AND
        payment_type = 1
        AND
        tip_amount > 0
)

/*
1 AM to 6 AM = Early Morning
6 AM to 12 PM = Morning
12 PM to 5 PM = Afternoon
5 PM to 9 PM = Evening
9 PM to 1 AM = Night
*/

SELECT
    pickup_borough,
    hour_type,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    pickup_borough,
    hour_type
ORDER BY
    pickup_borough,
    CASE hour_type
        WHEN 'Early Morning' THEN 1
        WHEN 'Morning' THEN 2
        WHEN 'Afternoon' THEN 3
        WHEN 'Evening' THEN 4
        ELSE 5
    END