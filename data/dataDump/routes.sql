-- routes
SELECT agency_id, route_id, route_long_name, aTripID FROM cta.routeTrip
UNION
SELECT agency_id, route_id, route_long_name, aTripID FROM metra.routeTrip;
