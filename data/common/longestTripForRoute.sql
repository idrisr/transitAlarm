use DB_REPLACE_ME;

-- get max counts per trip
CREATE TABLE routeTrip AS (
	SELECT W.*, t.shape_id FROM (
		SELECT z.route_id, max(z.trip_id) as trip_id
		FROM
		(   SELECT max(count_stop_sequence) as max_stop, route_id
			FROM 
				-- count stops per trip per route
				( SELECT   count(stop_sequence) as count_stop_sequence, t.route_id, t.trip_id
					FROM     trips t
					JOIN     stop_times st ON st.trip_id = t.trip_id
					JOIN     stops s       ON st.stop_id = s.stop_id
					GROUP BY t.route_id, t.trip_id
					ASC ORDER BY  t.route_id, count_stop_sequence, t.trip_id
				) X
			GROUP BY route_id
		) Y
		JOIN 
		(   SELECT   count(stop_sequence) as count_stop_sequence, t.route_id, t.trip_id
			FROM     trips t
			JOIN     stop_times st ON st.trip_id = t.trip_id
			JOIN     stops s       ON st.stop_id = s.stop_id
			GROUP BY t.route_id, t.trip_id
			ASC ORDER BY  t.route_id, count_stop_sequence, t.trip_id
		) Z
		WHERE Y.max_stop = Z.count_stop_sequence 
		AND  Z.route_id = Y.route_id
		GROUP BY z.route_id
	) W
	JOIN trips t on W.trip_id = t.trip_id
);
