DROP TABLE IF EXISTS agency cascade;
CREATE TABLE agency (
    id       VARCHAR(255) NOT NULL PRIMARY KEY,
    name     VARCHAR(255),
    url      VARCHAR(255),
    timezone VARCHAR(255),
    lang     VARCHAR(255),
    phone VARCHAR(255),
    agency_fare_url VARCHAR(255)
);
COPY agency FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/agency.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS route cascade;
CREATE TABLE route (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    short_name VARCHAR(255),
    long_name VARCHAR(255),
    description VARCHAR(255),
    agency_id VARCHAR(255) REFERENCES agency (id),
    type INTEGER,
    color VARCHAR(255),
    text_color VARCHAR(255),
    url VARCHAR(255)
);
COPY route FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/routes.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS fare_attribute cascade;
CREATE TABLE fare_attribute (
    id INTEGER NOT NULL PRIMARY KEY,
    price DOUBLE PRECISION,
    currency_type VARCHAR(255),
    payment_method INTEGER,
    transfers INTEGER,
    transfer_duration INTEGER
);
COPY fare_attribute FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/fare_attributes.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS fare_rule cascade;
CREATE TABLE fare_rule (
    fare_id INTEGER REFERENCES fare_attribute (id),
    route_id VARCHAR(255)  REFERENCES route (id),
    origin_id VARCHAR(255),
    destination_id VARCHAR(255),
    contains_id VARCHAR(255)
);
COPY fare_rule FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/fare_rules.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS trip cascade;
CREATE TABLE trip (
    route_id VARCHAR(255) REFERENCES route (id),
    service_id VARCHAR(255),
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    headsign VARCHAR(255),
    block_id VARCHAR(255),
    shape_id VARCHAR(255),
    direction_id VARCHAR(255)
);
COPY trip FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/trips.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS shape cascade;
CREATE TABLE shape (
    id VARCHAR(255) NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    sequence INTEGER,
    primary key (id, latitude, longitude, sequence)
);
COPY shape FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/shapes.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS calendar cascade;
CREATE TABLE calendar (
    service_id VARCHAR(255) NOT NULL PRIMARY KEY,
    monday boolean,
    tuesday boolean,
    wednesday boolean,
    thursday boolean,
    friday boolean,
    saturday boolean,
    sunday boolean,
    start_date VARCHAR(255),
    end_date VARCHAR(255)
);
COPY calendar FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/calendar.txt'
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS calendar_date cascade;
CREATE TABLE calendar_date (
    service_id VARCHAR(255),
    date VARCHAR(255),
    exception_type INTEGER
);
COPY calendar_date FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/calendar_dates.txt'
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS stop cascade;
CREATE TABLE stop (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    latitude double precision,
    longitude double precision, 
    zone_id VARCHAR(255),
    url VARCHAR(255),
    wheelchair_boarding BOOLEAN
);
COPY stop FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/stops.txt' 
WITH CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS stop_time cascade;
CREATE TABLE stop_time (
    trip_id          VARCHAR(255) REFERENCES trip (id),
    arrival_time     VARCHAR(255),
    departure_time   VARCHAR(255),
    stop_id          VARCHAR(255) REFERENCES stop (id),
    stop_sequence    INTEGER,
    pickup_type      INTEGER,
    drop_off_type    INTEGER,
    center_boarding  BOOLEAN,
    south_boarding   BOOLEAN,
    bikes_allowed    BOOLEAN,
    notice           BOOLEAN
);
COPY stop_time FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/metra/csv/stop_times.txt' 
WITH CSV HEADER DELIMITER ',';
