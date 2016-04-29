-- routes
use ctametra;

CREATE TABLE routes SELECT * FROM (
    SELECT 
    A.agency_id,
    A.route_color,
    A.route_id,
    A.route_long_name,
    A.route_short_name,
    A.route_text_color,
    A.route_type,
    A.route_url,
    B.trip_id,
    B.shape_id

    FROM cta.routes     A
    JOIN cta.routeTrip B ON A.route_id = B.route_id

    UNION

    SELECT 
    Z.agency_id,
    Z.route_color,
    Z.route_id,
    Z.route_long_name,
    Z.route_short_name,
    Z.route_text_color,
    Z.route_type,
    Z.route_url,
    Y.trip_id,
    Y.shape_id

    FROM metra.routes     Z
    JOIN metra.routeTrip  Y ON Z.route_id = Y.route_id
) X
