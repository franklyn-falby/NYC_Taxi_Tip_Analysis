# NYC Taxi Tipping Analysis

## Introduction
What affects how much people tip in a NYC yellow taxi? This project analyzes tip percentage across every yellow taxi trip from April 2026 (about 3.8 million) by payment type, time of day, day of week, and pickup borough.

**Headline finding:** Tipping is very consistent. Time of day and day of week barely move the average (it stays around 27–28%), while pickup location matters more: Manhattan pickups tip about 28% and Queens pickups about 23.5%. Data quality was the main challenge, and handling it shaped the results.

SQL queries: [project files](./)

## Background
This project uses current, public NYC taxi data to answer a practical question: when and where do taxi riders tip the most? The dataset is large and required several cleaning decisions before the results could be trusted.

Questions answered:
1. Which payment types have usable tip data?
2. Does tip percentage change by hour of the day?
3. Does it change by day of the week, or weekday vs. weekend?
4. Does it change by pickup borough?
5. Does the time-of-day pattern hold within each borough?

**Data:** [NYC Taxi & Limousine Commission (TLC) Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page), Yellow Taxi, April 2026, plus the TLC Taxi Zone lookup table to match pickup locations to boroughs.

**Tip percentage** = tip amount ÷ fare amount × 100. Fare amount is the metered fare only, not tolls or surcharges.

## Tools I Used
- **SQL**: All analysis
- **PostgreSQL** (Hosted on Neon): Database
- **Visual Studio Code**: Writing and running queries
- **Git & GitHub**: Setting up a Git repository and publishing the project to GitHub.

## Data Cleaning
Three filters were applied, each based on a problem found in the data. Starting from 3,831,240 trips, 2,373,125 remained for Queries 2–5.

**1. Fare of $3 or more (removed 18,013 trips)**
Without this filter, hours 3 and 10 averaged 44% and 31% while every other hour was 19–27%. The cause was trips with fares of a few cents and normal-sized tips (for example, a $0.01 fare with a $30 tip), which produce tip percentages in the thousands. The TLC's [standard metered fare](https://www.nyc.gov/site/tlc/passengers/taxi-fare.page) starts with a $3.00 initial charge, so any fare under $3 isn't a normal metered trip. Applying this filter brought every hour back into a normal range.

**2. Credit card trips only**
Query 1 shows that only credit card trips have usable tip data:

| Payment type | Avg tip % | Trips |
|---|---|---|
| Credit Card | 24.79 | 2,635,389 |
| Flex Fare | 1.99 | 797,945 |
| Dispute | 0.01 | 13,451 |
| No Charge | 0.01 | 9,976 |
| Cash | 0.00 | 356,466 |

The [TLC data dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf) confirms that the tip field is automatically filled in for credit card tips and that cash tips aren't included. Flex Fare is a newer payment type, and the TLC doesn't document how its tips are captured, so it was excluded as well.

**3. Trips with a recorded tip (removed 262,264 credit card trips)**
Before this filter, the Bronx averaged under 1% and Brooklyn about 4%, while Manhattan was about 26%. Counting $0 tips explained the gap:

| Pickup borough | Credit card trips with a $0 tip |
|---|---|
| Bronx | ~98% |
| Brooklyn | ~86% |
| Queens | ~8–30% (varies by time of day) |
| Manhattan | ~6% |

A 98% non-tipping rate among card-paying riders isn't believable, so these look like tips that weren't recorded rather than riders who didn't tip. The TLC notes that the trip data comes from outside technology providers and that it makes no representations about its accuracy. Leaving these trips in would have made the borough comparison measure missing data instead of tipping. Because of this filter, the results describe **how much people tip when a tip is recorded**, not whether they tip.

All queries after Query 1 use the same filters:

```sql
WHERE
    fare_amount >= 3
    AND payment_type = 1
    AND tip_amount > 0
```

## The Analysis

### 1. Tip percentage by payment type
[`1_payment_type.sql`](./1_payment_type.sql)

This query is the setup for the rest of the project. It shows that credit card is the only payment type with meaningful tip data (see the table under Data Cleaning), which is why Queries 2–5 use credit card trips only.

### 2. Tip percentage by time of day
[`2_hour.sql`](./2_hour.sql)

Trips are grouped by pickup hour, then into five time buckets.

| Time of day | Hours | Avg tip % | Trips |
|---|---|---|---|
| Early Morning | 1–5 AM | 28.69 | 86,694 |
| Evening | 5–9 PM | 28.60 | 651,582 |
| Night | 9 PM–1 AM | 27.45 | 427,665 |
| Afternoon | 12–5 PM | 27.06 | 706,415 |
| Morning | 6 AM–12 PM | 26.69 | 500,769 |

- By individual hour, the highest averages are 3–5 AM (about 29.5%) and 5–7 PM (about 28.8%).
- The lowest are the morning commute (7–9 AM) and mid-afternoon (3 PM), at about 26.5%.
- The full range is only about 3 percentage points, so time of day has a real but small effect.

### 3. Tip percentage by day of week
[`3_day.sql`](./3_day.sql)

| Day | Avg tip % | Trips |
|---|---|---|
| Friday | 27.85 | 318,970 |
| Monday | 27.77 | 279,342 |
| Tuesday | 27.68 | 326,533 |
| Wednesday | 27.68 | 419,853 |
| Thursday | 27.55 | 439,721 |
| Sunday | 27.16 | 263,145 |
| Saturday | 26.99 | 325,561 |

| Day type | Avg tip % | Trips |
|---|---|---|
| Weekday | 27.69 | 1,784,419 |
| Weekend | 27.06 | 588,706 |

- Every day falls within 1 percentage point of the others.
- Weekends are slightly lower than weekdays, but the difference is small.
- The day of the week has essentially no effect on tip percentage.

### 4. Tip percentage by pickup borough
[`4_boroughs.sql`](./4_boroughs.sql)

This joins each trip's pickup location to the TLC zone lookup table to get the borough.

| Pickup borough | Avg tip % | Trips |
|---|---|---|
| Manhattan | 27.87 | 2,161,609 |
| Queens | 23.47 | 197,793 |
| Brooklyn | 30.70 | 8,670 |
| Unknown | 27.50 | 3,462 |
| N/A (outside NYC) | 59.75 | 773 |
| Bronx | 35.26 | 515 |
| EWR (Newark Airport) | 36.02 | 282 |
| Staten Island | 705.19 | 21 |

- Manhattan and Queens are the only boroughs with enough trips to trust. Together they make up over 99% of the filtered trips.
- Queens tips about 4.4 points lower than Manhattan, the largest reliable difference in the project. One possible reason is that Queens includes JFK and LaGuardia. Airport trips are long and expensive (JFK to Manhattan is a [$70 flat fare](https://www.nyc.gov/site/tlc/passengers/taxi-fare.page)), and riders may tip a smaller percentage on a large fare. This wasn't tested.
- The other rows have too few trips to interpret. Staten Island's 705% average comes from just 21 trips, where a few unusual tips decide the number.

### 5. Tip percentage by borough and time of day
[`5_borough_times.sql`](./5_borough_times.sql)

This combines Queries 2 and 4 to check whether the time-of-day pattern holds within each borough. Manhattan and Queens are shown since they're the only boroughs with reliable trip counts.

| Time of day | Manhattan avg tip % | Queens avg tip % |
|---|---|---|
| Early Morning | 29.07 | 21.77 |
| Morning | 26.90 | 23.09 |
| Afternoon | 27.39 | 23.60 |
| Evening | 28.98 | 23.84 |
| Night | 27.88 | 23.29 |

- Manhattan follows the same pattern as the citywide results: highest early morning and evening, lowest in the morning.
- Queens stays almost flat all day, between about 22% and 24%.
- In every time bucket, Manhattan is higher than Queens, so the location gap isn't caused by timing.

## Limitations
- **One month of data.** April 2026 may not represent other months or seasons.
- **Excluding $0 tips removes some real non-tippers.** Some of the excluded trips are probably people who actually didn't tip, not missing data. The results only describe tip size when a tip was recorded.
- **Small samples outside Manhattan and Queens.** After filtering, the Bronx has 515 trips, Brooklyn 8,670, and Staten Island 21. Their averages aren't reliable.
- **Pickup borough only.** Dropoff location, which matters for airport trips, isn't included.
- **Tip percentage uses the base fare only.** Riders may calculate tips on the total including surcharges and tolls, which would change the percentages somewhat.

## What I Learned
- **Investigating unusual results:** The $3 fare floor and the zero-tip filter both came from results that looked wrong. Checking the raw rows instead of accepting the averages changed the analysis.
- **Verifying documentation:** An outdated data dictionary was missing Flex Fare (payment type 0); the current version includes it.
- **Documenting cleaning decisions:** Excluding $0 tips fixed the borough comparison but changed what the averages measure, so the change has to be stated alongside the results.
- **SQL techniques:** CTEs, CASE statements for labeling and bucketing, joins to a lookup table, date and time extraction, and casting to `numeric` for `ROUND()` in PostgreSQL.
- **Version control:** Using Git throughout the project.

## Conclusions
For credit card trips with a recorded tip, NYC taxi riders tip about 27–28% on average, and that number is stable. Time of day changes it by about 3 points, and the day of the week barely changes it. Pickup location matters more: Manhattan pickups tip about 4–7 points more than Queens pickups at every time of day.

Data quality also shaped the results. Over 260,000 credit card trips recorded no tip, concentrated in the Bronx and Brooklyn, and handling that problem affected the findings more than any single query.