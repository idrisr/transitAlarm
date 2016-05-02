--  https://developers.google.com/transit/gtfs/reference#routestxt
use cta;

ALTER TABLE agency ADD agency_id VARCHAR(255);
UPDATE agency set agency_id = "CTAL" WHERE agency_name = "CTA Train";
UPDATE agency set agency_id = "CTABus" WHERE agency_name = "CTA Bus";

ALTER TABLE routes ADD agency_id VARCHAR(255);
UPDATE routes set agency_id = (SELECT agency_id from agency WHERE agency_name = "CTA Bus") WHERE route_type = 3;
UPDATE routes set agency_id = (SELECT agency_id from agency WHERE agency_name = "CTA Train") WHERE route_type = 1;
