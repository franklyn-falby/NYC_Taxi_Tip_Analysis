/*
Question: What is the average tip percentage by time of day?
- Identify the average tip percentage for each time of day for taxi trips in April 2026.
- Also breaks hours into five buckets (Early Morning, Morning, Afternoon, Evening, Night)
to see if that broader pattern holds.
- Focuses on trip records with fare amounts greater than or equal to 3.
- Focuses on trip records paid for with credit card only.
- Focuses on the time of day where the pickup occurred.
- Focuses on trips with a recorded tip.
- Why? Highlight the time of day that sees the highest tip percentage, offering
insights into tipping behavior.
*/

WITH tip_percentage AS (
    SELECT
        EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
        fare_amount,
        tip_amount,
        ((tip_amount*100)/fare_amount) AS tip_percentage
    FROM
        taxi_trip_records
    WHERE
        fare_amount >= 3
        AND
        payment_type = 1
        AND
        tip_amount > 0
)

SELECT
    pickup_hour,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    pickup_hour
ORDER BY
    average_tip_percentage DESC;

WITH tip_percentage AS (
    SELECT
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
        taxi_trip_records
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
    hour_type,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    hour_type
ORDER BY
    average_tip_percentage DESC;