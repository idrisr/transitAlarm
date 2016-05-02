-- agency
use ctametra;

CREATE TABLE agency SELECT * FROM (
    SELECT agency_id, agency_name, agency_url, agency_timezone, agency_lang from cta.agency

    UNION

    SELECT agency_id, agency_name, agency_url, agency_timezone, agency_lang from metra.agency
) X
 
