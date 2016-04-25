-- finds the trip for a route with the max number of stops.
-- if trip with max stops tied, chooses the max trip_id

use DB_REPLACE_ME;
CREATE TABLE routeTrip AS (
    SELECT r.agency_id, z.route_id, r.route_long_name, MAX(z.trip_id) as aTripID
    FROM (
        SELECT t.trip_id, t.route_id, st.stop_sequence
        FROM trips t
        JOIN stop_times st
        ON t.trip_id = st.trip_id
    ) z
    JOIN
        (SELECT   t.route_id, max(stop_sequence) as max_stop_sequence
        FROM     trips t
        JOIN     stop_times st ON st.trip_id = t.trip_id
        JOIN     stops s       ON st.stop_id = s.stop_id
        GROUP BY t.route_id
    ) y
    ON y.route_id = z.route_id AND y.max_stop_sequence = z.stop_sequence
    JOIN routes r ON r.route_id = z.route_id
    GROUP BY z.route_id, r.route_long_name, z.stop_sequence
)
