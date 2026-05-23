SELECT COUNT(DISTINCT m.facility_id) AS orphan_count
FROM clean_readmissions_and_deaths m
LEFT JOIN clean_hospital_general_info h ON h.facility_id = m.facility_id
WHERE h.facility_id IS NULL;

-- Check: referential integrity for clean_readmissions_and_deaths
-- Every facility_id in this metric table must exist in clean_hospital_general_info
-- Expected: 0 
