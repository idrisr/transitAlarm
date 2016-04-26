use ctametra;

CREATE TABLE shapes SELECT * FROM (
    SELECT s.shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence 
    FROM cta.shapes s
    JOIN cta.routeTrip t ON s.shape_id = t.shape_id

    UNION

    SELECT s.shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence 
    FROM metra.shapes s
    JOIN metra.trips t ON s.shape_id = t.trip_id
) X
