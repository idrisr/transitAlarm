-- route_trip
use ctametra;

CREATE TABLE routeTrip SELECT * FROM (
    SELECT route_id, trip_id FROM cta.routetrip
    UNION
    SELECT route_id, trip_id FROM metra.routetrip
) X
