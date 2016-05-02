use ctametra;

CREATE TABLE stops 
SELECT * FROM (
    SELECT st.stop_sequence, rt.trip_id, s.stop_lat, s.stop_lon, s.stop_id, s.stop_name
    FROM cta.stop_times st
    JOIN cta.routetrip rt on rt.trip_id = st.trip_id
    JOIN cta.stops s on s.stop_id = st.stop_id

    UNION

    SELECT st.stop_sequence, rt.trip_id, s.stop_lat, s.stop_lon, s.stop_id, s.stop_name
    FROM metra.stop_times st
    JOIN metra.routetrip rt on rt.trip_id = st.trip_id
    JOIN metra.stops s on s.stop_id = st.stop_id
) X ;
