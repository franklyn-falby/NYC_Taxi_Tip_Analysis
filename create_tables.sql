CREATE TABLE taxi_trip_records (
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    pulocationid INTEGER,
    dolocationid INTEGER,
    passenger_count DOUBLE PRECISION,
    trip_distance DOUBLE PRECISION,
    fare_amount DOUBLE PRECISION,
    tip_amount DOUBLE PRECISION,
    payment_type INTEGER
);

CREATE TABLE taxi_zone_lookup (
    locationid INTEGER,
    borough VARCHAR,
    zone VARCHAR,
    service_zone VARCHAR
);