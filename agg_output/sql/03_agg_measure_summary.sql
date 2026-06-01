-- =============================================================================
-- Layer 5 Output 03_agg_measure_summary.sql
-- =============================================================================
-- Purpose : One row per cluster × measure, describing the distribution of
--           performance within each peer group. Used in Power BI for:
--             - Benchmark reference lines on hospital scorecards
--             - "How does this cluster typically perform on this measure?"
--             - Box-plot / distribution visuals per measure × cluster
--
-- Key design note: all statistics are computed on measure_value (the raw CMS
-- number), NOT on display_pct. This preserves the clinical meaning of the
-- distribution (e.g. "median readmission rate in this cluster is 14.2%").
-- display_pct is a ranking artifact — averaging percentiles is meaningless.
--
-- Source tables:
--   model_hospital_scores   — ccn, cluster_id, measure_dataset, measure_id,
--                             measure_value, cluster_pct, cluster_n
--   model_measure_lookup    — measure_dataset, measure_id, direction, display_name
--   model_cluster_lookup    — cluster_id, cluster_name
-- =============================================================================

DROP TABLE IF EXISTS agg_measure_summary;

CREATE TABLE agg_measure_summary AS

SELECT

    --  Cluster identity
    s.cluster_id,
    cl.cluster_name,

    -- Measure identity 
    s.measure_dataset,
    s.measure_id,
    l.display_name      AS measure_display_name,
    l.direction         AS measure_direction,

    --  Peer group size for this measure
    -- cluster_n is already stored per row; take MAX (all rows identical per group)
    MAX(s.cluster_n)    AS n_hospitals_reporting,

    -- Distribution of raw measure_value within the cluster
    ROUND(MIN(s.measure_value),  3)   AS min_value,
    ROUND(AVG(s.measure_value),  3)   AS mean_value,
    ROUND(MAX(s.measure_value),  3)   AS max_value,

    -- Percentile approximations via SQLite window functions
    -- p25 / median / p75 give Power BI enough to draw a box plot reference
    ROUND(
        AVG(s.measure_value) FILTER (
            WHERE s.cluster_pct BETWEEN 20 AND 30
        ), 3
    )                                 AS p25_value,

    ROUND(
        AVG(s.measure_value) FILTER (
            WHERE s.cluster_pct BETWEEN 45 AND 55
        ), 3
    )                                 AS median_value,

    ROUND(
        AVG(s.measure_value) FILTER (
            WHERE s.cluster_pct BETWEEN 70 AND 80
        ), 3
    )                                 AS p75_value

FROM model_hospital_scores        s

LEFT JOIN model_measure_lookup    l
       ON s.measure_dataset = l.measure_dataset
      AND s.measure_id      = l.measure_id

LEFT JOIN model_cluster_lookup    cl
       ON s.cluster_id = cl.cluster_id

GROUP BY
    s.cluster_id,
    cl.cluster_name,
    s.measure_dataset,
    s.measure_id,
    l.display_name,
    l.direction

ORDER BY
    s.cluster_id,
    s.measure_dataset,
    s.measure_id;
