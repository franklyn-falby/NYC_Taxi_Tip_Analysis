/*
Question: What is the average tip percentage for each payment type?
- Identify the average tip percentage for each method of payment for taxi trips in April 2026.
- Focuses on trip records with fare amounts greater than or equal to 3.
- Why? Determine which payment types record meaningful tip data.
*/

WITH tip_percentage AS (
    SELECT
        fare_amount,
        tip_amount,
        ((tip_amount*100)/fare_amount) AS tip_percentage,
        CASE payment_type
        WHEN 0 THEN 'Flex Fare'
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'
        WHEN 6 THEN 'Voided Trip'
        ELSE 'Other'
    END AS payment_type_desc
    FROM
        taxi_trip_records
    WHERE
        fare_amount >= 3
)


SELECT
    payment_type_desc,
    ROUND(AVG(tip_percentage)::numeric, 2) AS average_tip_percentage,
    COUNT(*) AS count_of_trips
FROM
    tip_percentage
GROUP BY
    payment_type_desc
ORDER BY
    average_tip_percentage DESC