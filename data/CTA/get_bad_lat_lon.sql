USE cta;

SELECT distinct s.stop_id
FROM stops s
JOIN stop_times st ON s.stop_id = st.stop_id 
JOIN trips t ON st.trip_id = t.trip_id
WHERE (stop_lat=0 OR stop_lat=1 OR stop_lat=99 OR
       stop_lon=0 OR stop_lon=1 OR stop_lon=99)
ORDER BY s.stop_id
