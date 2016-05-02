DROP DATABASE IF EXISTS ctametra;
CREATE DATABASE ctametra
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;

USE ctametra;

--  DROP TABLE IF EXISTS agency;
--  CREATE TABLE `agency` (
    --  agency_name VARCHAR(255),
    --  agency_url VARCHAR(255),
    --  agency_timezone VARCHAR(50),
    --  agency_lang VARCHAR(50),
    --  agency_phone VARCHAR(255),
    --  agency_fare_url VARCHAR(255)
--  );

--  DROP TABLE IF EXISTS shapes;
--  CREATE TABLE `shapes` (
	--  shape_id INTEGER NOT NULL,
	--  shape_pt_lat DECIMAL(8,6),
	--  shape_pt_lon DECIMAL(8,6),
	--  shape_pt_sequence INTEGER,
    --  shape_dist_traveled INTEGER,
    --  primary key (shape_id, shape_pt_sequence, shape_pt_lat, shape_pt_lon)
--  );

--  DROP TABLE IF EXISTS routes;
--  -- route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color
--  CREATE TABLE `routes` (
    --  route_id VARCHAR(255) NOT NULL PRIMARY KEY,
	--  route_short_name VARCHAR(50),
	--  route_long_name VARCHAR(255),
	--  --  agency_id VARCHAR(255) add this, but not the one in the file
	--  route_type INT(2),
	--  route_url VARCHAR(255),
	--  route_color VARCHAR(20),
	--  route_text_color VARCHAR(20),
	--  --  FOREIGN KEY (agency_id) REFERENCES agency(agency_id),
	--  --  KEY `agency_id` (agency_id),
	--  KEY `route_type` (route_type)
--  );

--  DROP TABLE IF EXISTS trips;
--  -- trip_id,service_id,route_id,trip_headsign,direction_id,shape_id
--  CREATE TABLE `trips` (
--  route_id VARCHAR(255),
--  service_id VARCHAR(255),
--  trip_id VARCHAR(255) NOT NULL PRIMARY KEY,
--  direction_id INT,
--  block_id VARCHAR(255),
--  shape_id VARCHAR(255),
--  direction VARCHAR(255),
--  wheelchair_accessible INT,
--  schd_trip_id VARCHAR(255),
--  FOREIGN KEY (route_id) REFERENCES routes(route_id),
--  KEY `route_id` (route_id),
--  KEY `service_id` (service_id)
--  );

--  DROP TABLE IF EXISTS stops;
--  -- stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,parent_station,wheelchair_boarding
--  CREATE TABLE `stops` (
    --  stop_id INTEGER NOT NULL,
	--  stop_code VARCHAR(255),
	--  stop_name VARCHAR(255),
	--  stop_desc VARCHAR(255),
	--  stop_lat DECIMAL(8,6) NOT NULL,
	--  stop_lon DECIMAL(8,6) NOT NULL,
    --  primary key (stop_id, stop_lat, stop_lon)
--  );

--  DROP TABLE IF EXISTS stop_times;
--  CREATE TABLE `stop_times` (
    --  trip_id               VARCHAR(255),
    --  arrival_time          VARCHAR(8),
    --  departure_time        VARCHAR(8),
    --  stop_id               INTEGER,
    --  stop_sequence         SMALLINT UNSIGNED,
    --  stop_headsign         VARCHAR(8),
    --  pickup_type           INT(2),
    --  shape_dist_traveled   VARCHAR(8),
    --  FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    --  KEY `trip_id` (trip_id),
    --  KEY `stop_id` (stop_id),
    --  KEY `stop_sequence` (stop_sequence),
    --  KEY `pickup_type` (pickup_type)
--  );

--  LOAD DATA LOCAL INFILE 'tmp/agency.txt'         INTO TABLE agency         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
--  LOAD DATA LOCAL INFILE 'tmp/shapes.txt'         INTO TABLE shapes         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
--  LOAD DATA LOCAL INFILE 'tmp/routes.txt'         INTO TABLE routes         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
--  LOAD DATA LOCAL INFILE 'tmp/stops.txt'          INTO TABLE stops          FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
--  LOAD DATA LOCAL INFILE 'tmp/trips.txt'          INTO TABLE trips          FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
--  LOAD DATA LOCAL INFILE 'tmp/stop_times.txt'     INTO TABLE stop_times     FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
