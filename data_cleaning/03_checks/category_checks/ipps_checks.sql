-- 1. IPPS rows that have no matching hospital in clean_cohort (orphans)
SELECT COUNT(*) AS ipps_orphans
FROM clean_ipps
WHERE ccn NOT IN (SELECT facility_id FROM clean_cohort);

-- 2. Cohort hospitals (included only) that have no IPPS data
SELECT COUNT(*) AS cohort_without_ipps
FROM clean_cohort
WHERE included = 1
  AND facility_id NOT IN (SELECT ccn FROM clean_ipps);

-- 3. Sample the orphans so we can see what kind of hospital is in IPPS but not cohort
SELECT ccn FROM clean_ipps
WHERE ccn NOT IN (SELECT facility_id FROM clean_cohort)
LIMIT 10;

SELECT 
    SUM(CASE WHEN CAST(bed_count AS TEXT) IN ('N/A', 'Not Available', '') THEN 1 ELSE 0 END) AS suspicious_beds,
    SUM(CASE WHEN CAST(cmi AS TEXT)       IN ('N/A', 'Not Available', '') THEN 1 ELSE 0 END) AS suspicious_cmi
FROM clean_ipps;