SELECT facility_id, COUNT(*)
FROM clean_hospital_general_info 
GROUP BY facility_id
HAVING COUNT(*) > 1
-- Grain: one row per (facility_id )
-- Composite key: (facility_id)
-- Multiple rows per hospital are NOT expected