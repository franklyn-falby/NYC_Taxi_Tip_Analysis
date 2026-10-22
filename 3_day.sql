/*
Question: What is the average tip percentage for every day of the week and does it differ
between weekdays and weekends?
- Identify the average tip percentage for each day of the week for taxi trips in April 2026.
- Also breaks the data into weekday vs. weekend to see if that broader pattern holds.
- Focuses on trip records with fare amounts greater than or equal to 3.
- Focuses on trip records paid for with credit card only.
- Focuses on the day of week where the pickup occurred.
- Focuses on trips with a recorded tip.
- Why? Highlight which days (and whether weekdays or weekends) see the highest tip percentage, offering insights into tipping behavior.
*/

WITH tip_percentage AS (
    SELECT
        CASE
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 0 THEN 'Sunday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 1 THEN 'Monday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 2 THEN 'Tuesday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 3 THEN 'Wednesday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 4 THEN 'Thursday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 5 THEN 'Friday'
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) = 6 THEN 'Saturday'
            ELSE 'Other'
        END AS day,
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
    day,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    day
ORDER BY
    average_tip_percentage DESC;

WITH tip_percentage AS (
    SELECT
        CASE
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) BETWEEN 1 AND 5 THEN 'Weekday'
            ELSE 'Weekend'
        END AS day_type,
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
    day_type,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    day_type
ORDER BY
    average_tip_percentage DESC;