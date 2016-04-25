use cta;
ALTER TABLE routes ADD agency_id VARCHAR(255);
UPDATE routes set agency_id = (SELECT agency_id from agency);
ALTER TABLE routes ADD CONSTRAINT fk_agency_id FOREIGN KEY (agency_id) REFERENCES agency(agency_id);
