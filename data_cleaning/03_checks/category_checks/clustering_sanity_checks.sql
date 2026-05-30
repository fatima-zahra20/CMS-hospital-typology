SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN bed_count IS NULL THEN 1 ELSE 0 END) AS bed_count_null,
    SUM(CASE WHEN bed_size_category IS NULL THEN 1 ELSE 0 END) AS bed_size_null,
    SUM(CASE WHEN cmi IS NULL THEN 1 ELSE 0 END) AS cmi_null,
    SUM(CASE WHEN is_teaching IS NULL THEN 1 ELSE 0 END) AS teaching_null,
    SUM(CASE WHEN safety_net_burden IS NULL THEN 1 ELSE 0 END) AS dsh_null,
    SUM(CASE WHEN urbanicity_bucket IS NULL THEN 1 ELSE 0 END) AS urbanicity_null,
    SUM(CASE WHEN ipps_covered IS NULL THEN 1 ELSE 0 END) AS ipps_covered_null
FROM clean_structural;


SELECT ipps_covered, COUNT(*) AS n
FROM clean_structural
GROUP BY ipps_covered;

SELECT 'bed_size_category' AS variable, COALESCE(bed_size_category, 'NULL') AS value, COUNT(*) AS n
FROM clean_structural GROUP BY bed_size_category
UNION ALL
SELECT 'urbanicity_bucket', COALESCE(urbanicity_bucket, 'NULL'), COUNT(*)
FROM clean_structural GROUP BY urbanicity_bucket
UNION ALL
SELECT 'is_teaching', COALESCE(CAST(is_teaching AS TEXT), 'NULL'), COUNT(*)
FROM clean_structural GROUP BY is_teaching
ORDER BY variable, value;	


WITH bc AS (
    SELECT bed_count, PERCENT_RANK() OVER (ORDER BY bed_count) AS pct
    FROM clean_structural WHERE bed_count IS NOT NULL
),
cm AS (
    SELECT cmi, PERCENT_RANK() OVER (ORDER BY cmi) AS pct
    FROM clean_structural WHERE cmi IS NOT NULL
),
sn AS (
    SELECT safety_net_burden, PERCENT_RANK() OVER (ORDER BY safety_net_burden) AS pct
    FROM clean_structural WHERE safety_net_burden IS NOT NULL
)
SELECT
    'bed_count' AS variable,
    (SELECT COUNT(*) FROM bc) AS n,
    (SELECT MIN(bed_count) FROM bc) AS min_val,
    (SELECT MAX(bed_count) FROM bc) AS max_val,
    ROUND((SELECT AVG(bed_count) FROM bc), 2) AS mean_val,
    (SELECT MIN(bed_count) FROM bc WHERE pct >= 0.25) AS p25,
    (SELECT MIN(bed_count) FROM bc WHERE pct >= 0.50) AS p50,
    (SELECT MIN(bed_count) FROM bc WHERE pct >= 0.75) AS p75
UNION ALL
SELECT 'cmi',
    (SELECT COUNT(*) FROM cm),
    (SELECT MIN(cmi) FROM cm),
    (SELECT MAX(cmi) FROM cm),
    ROUND((SELECT AVG(cmi) FROM cm), 4),
    (SELECT MIN(cmi) FROM cm WHERE pct >= 0.25),
    (SELECT MIN(cmi) FROM cm WHERE pct >= 0.50),
    (SELECT MIN(cmi) FROM cm WHERE pct >= 0.75)
UNION ALL
SELECT 'safety_net_burden',
    (SELECT COUNT(*) FROM sn),
    (SELECT MIN(safety_net_burden) FROM sn),
    (SELECT MAX(safety_net_burden) FROM sn),
    ROUND((SELECT AVG(safety_net_burden) FROM sn), 4),
    (SELECT MIN(safety_net_burden) FROM sn WHERE pct >= 0.25),
    (SELECT MIN(safety_net_burden) FROM sn WHERE pct >= 0.50),
    (SELECT MIN(safety_net_burden) FROM sn WHERE pct >= 0.75);
	
	
SELECT
    COUNT(*) AS total_ipps,
    SUM(CASE WHEN safety_net_burden = 0 THEN 1 ELSE 0 END) AS zero_count,
    ROUND(SUM(CASE WHEN safety_net_burden = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS zero_pct
FROM clean_structural
WHERE ipps_covered = 1;


