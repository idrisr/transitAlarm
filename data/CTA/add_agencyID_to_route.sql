use metra;
UPDATE routes set agency_id = (SELECT agency_id from agency);
ALTER TABLE routes ADD CONSTRAINT FK_AGENCY_TABLE_ROUTE_ID FOREIGN KEY (agency_id) REFERENCES agency(agency_id);