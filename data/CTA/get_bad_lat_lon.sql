USE cta;

SELECT distinct stop_id
FROM stops s
WHERE (stop_lat=0 OR stop_lat=1 OR stop_lat=99 OR stop_lon=0 OR stop_lon=1 OR stop_lon=99)
ORDER BY s.stop_id
