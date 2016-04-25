-- route_trip
SELECT 
agency_id, route_id, route_long_name, aTripID cta.routetrip
UNION
SELECT 
agency_id, route_id, route_long_name, aTripID from metra.routetrip
