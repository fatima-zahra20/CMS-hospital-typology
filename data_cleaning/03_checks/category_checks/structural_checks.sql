-- 1. Row count and NULL pattern
SELECT
    COUNT(*)                                                AS total_rows,
    SUM(CASE WHEN bed_count          IS NULL THEN 1 ELSE 0 END) AS null_beds,
    SUM(CASE WHEN cmi                IS NULL THEN 1 ELSE 0 END) AS null_cmi,
    SUM(CASE WHEN is_teaching        IS NULL THEN 1 ELSE 0 END) AS null_teaching,
    SUM(CASE WHEN urbanicity_bucket  IS NULL THEN 1 ELSE 0 END) AS null_urbanicity,
    SUM(CASE WHEN ipps_covered = 0   THEN 1 ELSE 0 END)         AS no_ipps_match
FROM clean_structural;

-- 2. Feature distributions — sanity check before clustering
SELECT bed_size_category, COUNT(*) AS n FROM clean_structural GROUP BY bed_size_category ORDER BY n DESC;
SELECT urbanicity_bucket, COUNT(*) AS n FROM clean_structural GROUP BY urbanicity_bucket ORDER BY n DESC;
SELECT is_teaching,       COUNT(*) AS n FROM clean_structural GROUP BY is_teaching;