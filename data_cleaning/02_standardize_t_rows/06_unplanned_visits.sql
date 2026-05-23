SELECT facility_id, measure_id , COUNT(*) 
FROM clean_unplanned_visits
GROUP BY facility_id, measure_id
HAVING COUNT(*) > 1

-- Grain: one row per (facility_id + measure_id )
-- Composite key: (facility_id, measure_id)
-- Multiple rows per hospital are expected