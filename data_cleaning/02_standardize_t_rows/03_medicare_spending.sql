SELECT facility_id, claim_type ,period ,COUNT(*)
FROM clean_medicare_spending
GROUP BY facility_id, claim_type, period
HAVING COUNT(*) > 1 

-- Grain: one row per (facility_id + measure_id + period)
-- Composite key: (facility_id, measure_id , period)
-- Multiple rows per hospital are expected