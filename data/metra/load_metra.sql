--  /*
--  * The code is contributed by Michael Perkins
--  * I change a little bit.
--  * The original file is located in https://raw.githubusercontent.com/sbma44/py-metra-mysql/master/sql_better/load.sql
--  *
--  * SparkandShine (sparkandshine.net)
--  */

DROP DATABASE IF EXISTS metra;
-- CREATE DATABASE IF NOT EXISTS metra;
CREATE DATABASE metra
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;

USE metra

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
	shape_pt_sequence VARCHAR(255),
    shape_dist_traveled DECIMAL(8,6)
);

DROP TABLE IF EXISTS routes;
-- route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color
CREATE TABLE `routes` (
    route_id VARCHAR(255) NOT NULL PRIMARY KEY,
	route_short_name VARCHAR(50),
	route_long_name VARCHAR(255),
	route_desc VARCHAR(255),
	agency_id VARCHAR(255),
	route_type INT(2),
	route_color VARCHAR(20),
	route_text_color VARCHAR(20),
	route_url VARCHAR(255),
	FOREIGN KEY (agency_id) REFERENCES agency(agency_id),
	KEY `agency_id` (agency_id),
	KEY `route_type` (route_type)
);



DROP TABLE IF EXISTS trips;
-- trip_id,service_id,route_id,trip_headsign,direction_id,shape_id
CREATE TABLE `trips` (
    route_id VARCHAR(255),
	service_id VARCHAR(255),
	trip_id VARCHAR(255) NOT NULL PRIMARY KEY,
	trip_headsign VARCHAR(255),
	block_id VARCHAR(255),
	shape_id VARCHAR(255),
	FOREIGN KEY (route_id) REFERENCES routes(route_id),
	KEY `route_id` (route_id),
	KEY `service_id` (service_id)
);


DROP TABLE IF EXISTS stops;
-- stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station,wheelchair_boarding
CREATE TABLE `stops` (
    	stop_id VARCHAR(255) NOT NULL PRIMARY KEY,
	stop_code VARCHAR(255),
	stop_name VARCHAR(255),
	stop_lat DECIMAL(8,6),
	stop_lon DECIMAL(8,6),
	location_type INT(2),
	parent_station VARCHAR(255),
	wheelchair_boarding INT(2),
	stop_desc VARCHAR(255),
	zone_id VARCHAR(255)
);


DROP TABLE IF EXISTS stop_times;
-- trip_id,stop_id,stop_sequence,arrival_time,departure_time,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled
CREATE TABLE `stop_times` (
    trip_id          VARCHAR(255),
    arrival_time     VARCHAR(8),
    departure_time   VARCHAR(8),
    stop_id          VARCHAR(255),
    stop_sequence    SMALLINT UNSIGNED,
    pickup_type      INT(2),
    drop_off_type    INT(2),

	FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
	FOREIGN KEY (stop_id) REFERENCES stops(stop_id),
	KEY `trip_id` (trip_id),
	KEY `stop_id` (stop_id),
	KEY `stop_sequence` (stop_sequence),
	KEY `pickup_type` (pickup_type),
	KEY `drop_off_type` (drop_off_type)
);


LOAD DATA LOCAL INFILE 'tmp/agency.txt' INTO TABLE agency                 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/shapes.txt' INTO TABLE shapes                 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/routes.txt' INTO TABLE routes                 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/stops.txt' INTO TABLE stops                   FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/trips.txt' INTO TABLE trips                   FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE 'tmp/stop_times.txt' INTO TABLE stop_times         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
