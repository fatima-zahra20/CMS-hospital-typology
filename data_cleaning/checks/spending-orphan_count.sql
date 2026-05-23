SELECT DISTINCT m.facility_id
FROM clean_medicare_spending m
LEFT JOIN clean_hospital_general_info h ON h.facility_id = m.facility_id
WHERE h.facility_id IS NULL
ORDER BY m.facility_id;

-- Known orphans on snapshot 20260520 (likely closed/merged hospitals with lingering MSPB data):
-- 010008, 010059, 050589, 100047, 100092, 390326, 420117, 450271, 450411
-- These are naturally excluded by spine join; no cleaning action needed