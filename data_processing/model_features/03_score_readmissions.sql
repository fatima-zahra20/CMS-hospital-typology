-- Within-cluster scoring for the readmissions_and_deaths dataset.
-- 
-- For each measure, computes each hospital's rank and percentile within its
-- KMeans cluster. NULL scores (CMS-suppressed by footnote) are excluded.
--
-- Direction: all measures here are LOWER-IS-BETTER (readmission/mortality
-- rates). Percentile is computed in numerical order; direction is applied
-- at the display layer via model_measure_lookup (built later).

DROP TABLE IF EXISTS model_scores_readmissions;
CREATE TABLE model_scores_readmissions AS
SELECT
    r.facility_id AS ccn,
    hc.cluster_id,
    'readmissions_and_deaths' AS measure_dataset,
    r.measure_id,
    r.score AS measure_value,
    r.denominator,
    RANK() OVER (
        PARTITION BY hc.cluster_id, r.measure_id
        ORDER BY r.score
    ) AS cluster_rank,
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY hc.cluster_id, r.measure_id
            ORDER BY r.score
        ) * 100,
        2
    ) AS cluster_pct,
    COUNT(*) OVER (
        PARTITION BY hc.cluster_id, r.measure_id
    ) AS cluster_n
FROM clean_readmissions_and_deaths r
INNER JOIN model_hospital_clusters hc
    ON r.facility_id = hc.ccn
WHERE r.score IS NOT NULL;