--  /*
--  * The code is contributed by Michael Perkins
--  * I change a little bit.
--  * The original file is located in https://raw.githubusercontent.com/sbma44/py-cta-mysql/master/sql_better/load.sql
--  *
--  * SparkandShine (sparkandshine.net)
--  */

DROP DATABASE IF EXISTS cta;
-- CREATE DATABASE IF NOT EXISTS cta;
CREATE DATABASE cta
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;

USE cta

DROP TABLE IF EXISTS agency;
-- agency_id,agency_name,agency_url,agency_timezone,agency_phone,agency_lang
CREATE TABLE `agency` (
    agency_id VARCHAR(255) NOT NULL PRIMARY KEY,
    agency_name VARCHAR(255),
    agency_url VARCHAR(255),
    agency_timezone VARCHAR(50),
    agency_phone VARCHAR(255),
    agency_lang VARCHAR(50)
);

DROP TABLE IF EXISTS shapes;
-- shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence
CREATE TABLE `shapes` (
	shape_id VARCHAR(255) NOT NULL,
	shape_pt_lat DECIMAL(8,6),
	shape_pt_lon DECIMAL(8,6),
	shape_pt_sequence INTEGER,
    shape_dist_traveled INTEGER
);

DROP TABLE IF EXISTS calendar;
-- service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
CREATE TABLE `calendar` (
    	service_id VARCHAR(255) NOT NULL PRIMARY KEY,
	monday TINYINT(1),
	tuesday TINYINT(1),
	wednesday TINYINT(1),
	thursday TINYINT(1),
	friday TINYINT(1),
	saturday TINYINT(1),
	sunday TINYINT(1),
	start_date VARCHAR(8),
	end_date VARCHAR(8)
);

DROP TABLE IF EXISTS calendar_dates;
-- service_id,date,exception_type
CREATE TABLE `calendar_dates` (
    service_id VARCHAR(255),
    `date` VARCHAR(8),
    exception_type INT(2),
    FOREIGN KEY (service_id) REFERENCES calendar(service_id),
    KEY `exception_type` (exception_type)
);

DROP TABLE IF EXISTS routes;
-- route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color
CREATE TABLE `routes` (
    route_id VARCHAR(255) NOT NULL PRIMARY KEY,
	route_short_name VARCHAR(50),
	route_long_name VARCHAR(255),
	route_type INT(2),
	route_url VARCHAR(255),
	route_color VARCHAR(20),
	route_text_color VARCHAR(20),
	KEY `route_type` (route_type)
);



DROP TABLE IF EXISTS trips;
-- trip_id,service_id,route_id,trip_headsign,direction_id,shape_id
CREATE TABLE `trips` (
    route_id                VARCHAR(255),
    service_id              VARCHAR(255),
    trip_id                 VARCHAR(255) NOT NULL PRIMARY KEY,
    direction_id            INT(2),
    block_id                VARCHAR(255),
    shape_id                VARCHAR(255),
    direction               VARCHAR(255),
    wheelchair_accessible   VARCHAR(255),
    sched_trip_id           VARCHAR(255),
    KEY `route_id` (route_id),
    KEY `service_id` (service_id)
);


DROP TABLE IF EXISTS stops;
-- stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station,wheelchair_boarding
CREATE TABLE `stops` (
    stop_id VARCHAR(255) NOT NULL PRIMARY KEY,
	stop_code VARCHAR(255),
	stop_name VARCHAR(255),
	stop_desc VARCHAR(255),
	stop_lat DECIMAL(8,6),
	stop_lon DECIMAL(8,6)
);


DROP TABLE IF EXISTS stop_times;
CREATE TABLE `stop_times` (
    trip_id               VARCHAR(255),
    arrival_time          VARCHAR(8),
    departure_time        VARCHAR(8),
    stop_id               VARCHAR(255),
    stop_sequence         VARCHAR(255),
    stop_headsign         VARCHAR(8),
    pickup_type           INT(2),
    shape_dist_traveled   VARCHAR(8),
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    KEY `trip_id` (trip_id),
    KEY `stop_id` (stop_id),
    KEY `stop_sequence` (stop_sequence),
    KEY `pickup_type` (pickup_type)
);


DROP TABLE IF EXISTS frequencies;

-- trip_id,start_time,end_time,headway_secs
CREATE TABLE `frequencies` (
	trip_id VARCHAR(255),
	start_time VARCHAR(50),
	end_time VARCHAR(50),
	headway_secs VARCHAR(50),
	FOREIGN KEY (trip_id) REFERENCES trips(trip_id)
);

LOAD DATA LOCAL INFILE 'tmp/agency.txt'         INTO TABLE agency         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/shapes.txt'         INTO TABLE shapes         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/routes.txt'         INTO TABLE routes         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/stops.txt'          INTO TABLE stops          FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/trips.txt'          INTO TABLE trips          FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/stop_times.txt'     INTO TABLE stop_times     FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
