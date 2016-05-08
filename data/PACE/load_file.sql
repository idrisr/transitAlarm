drop table if exists stop CASCADE;
create table stop (
    id            char(8) PRIMARY KEY,
    name          varchar(255),
    description   varchar(255),
    latitude      double precision,
    longitude     double precision,
    street        varchar(255),
    city          varchar(255),
    region        varchar(255),
    postcode      varchar(255),
    country       varchar(255),
    zone_id       INTEGER,
    geo_node_id   INTEGER
);
COPY stop FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/stops.txt' 
WITH CSV HEADER DELIMITER ',';

drop table if exists agency CASCADE;
create table agency (
    name       varchar(255),
    url        varchar(255),
    timezone   varchar(255),
    lang       varchar(255)
);
COPY agency FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/agency.txt'
WITH CSV HEADER DELIMITER ',';

drop table if exists calendar CASCADE;
create table calendar (
   service_id   varchar(255) PRIMARY KEY,
   monday       BOOLEAN,
   tuesday      BOOLEAN,
   wednesday    BOOLEAN,
   thursday     BOOLEAN,
   friday       BOOLEAN,
   saturday     BOOLEAN,
   sunday       BOOLEAN,
   start_date   VARCHAR(255),
   end_date     VARCHAR(255)
);
COPY calendar FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/calendar.txt'
WITH CSV HEADER DELIMITER ',';

drop table if exists route CASCADE;
create table route (
    id            varchar(255) PRIMARY KEY,
    short_name    varchar(255),
    long_name     varchar(255),
    description   varchar(255),
    type          INTEGER
);
COPY route FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/routes.txt'
WITH CSV HEADER DELIMITER ',';

drop table if exists trip CASCADE;
create table trip (
    route_id varchar(255) REFERENCES route (id),
    service_id varchar(255) REFERENCES calendar (service_id),
    id INTEGER PRIMARY KEY,
    direction_id INTEGER,
    block_id INTEGER
);
COPY trip FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/trips.txt'
WITH CSV HEADER DELIMITER ',';

drop table if exists stop_time CASCADE;
create table stop_time (
    trip_id  INTEGER REFERENCES trip (id),
    arrival_time VARCHAR(255),
    departure_time VARCHAR(255),
    stop_id char(8) REFERENCES stop (id),
    stop_sequence INTEGER,
    pickup_type INTEGER,
    drop_off_type INTEGER,
    bikes_allowed boolean
);
COPY stop_time FROM '/Users/id/Dropbox/learning/mobile_makers/TransitAlarm/data/PACE/csv/stop_times.txt'
WITH CSV HEADER DELIMITER ',';
