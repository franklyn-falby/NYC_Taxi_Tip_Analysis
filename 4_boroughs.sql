/*
Question: What is the average tip percentage by borough?
- Identify the average tip percentage for each borough for taxi trips in April 2026.
- Focuses on trip records with fare amounts greater than or equal to 3.
- Focuses on trip records paid for with credit card only.
- Focuses on borough where the pickup occurred.
- Focuses on trips with a recorded tip.
- Why? Identify how tipping behavior differs by pickup borough.
  */

WITH tip_percentage AS (
    SELECT
        pu.borough AS pickup_borough,
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


SELECT
    pickup_borough,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    pickup_borough
ORDER BY
    count_of_trips DESC