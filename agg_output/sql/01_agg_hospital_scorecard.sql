-- =============================================================================
-- Layer 5 Output  01_agg_hospital_scorecard.sql
-- =============================================================================
-- Purpose : One row per hospital + measure, with display-ready percentile scores.
--           This is the headline output it directly answers "how does Hospital X
--           perform across all measures relative to its structural peers?"
--
-- Convention : display_pct always means "higher = better performance."
--              For lower_better measures (readmissions, infections, etc.),
--              display_pct = 100 - cluster_pct, so a hospital with low raw values
--              scores near 100 rather than near 0.
--
-- Source tables:
--   model_hospital_scores   - ccn, cluster_id, measure_dataset, measure_id,
--                             measure_value, cluster_rank, cluster_pct, cluster_n
--   model_measure_lookup    - measure_dataset, measure_id, direction, display_name
--   model_cluster_lookup    - cluster_id, cluster_name
--   clean_structural        - ccn, bed_size_category, urbanicity_bucket,
--                             is_teaching, safety_net_burden, ipps_covered
--   clean_hospital_general_info - facility_id

-- =============================================================================
 
DROP TABLE IF EXISTS agg_hospital_scorecard;
 
CREATE TABLE agg_hospital_scorecard AS
 
SELECT
 
    -- Hospital identity 
    s.ccn,
    h.hospital_name,
    h.state,
    h.zip_code,
 
    -- Cluster context 
    s.cluster_id,
    cl.cluster_name,
 
    -- Structural profile (for dashboard filter/slice) 
    cs.bed_size_category,
    cs.urbanicity_bucket,
    cs.is_teaching,
    cs.safety_net_burden,
 
    -- Measure identity 
    s.measure_dataset,
    s.measure_id,
    l.display_name      AS measure_display_name,
    l.direction         AS measure_direction,   -- lower_better | higher_better
 
    -- Raw performance
    s.measure_value,
 
    -- Within-cluster position 
    s.cluster_rank,                             -- ordinal rank within cluster
    s.cluster_n,                                -- total peers in cluster for this measure
    s.cluster_pct,                              -- raw percentile (high value = high number)
 
    -- Display percentile (Convention B: 100 = best performer) 
    CASE
        WHEN l.direction = 'lower_better'  THEN ROUND(100.0 - s.cluster_pct, 1)
        WHEN l.direction = 'higher_better' THEN ROUND(s.cluster_pct, 1)
        ELSE NULL   -- direction not set in lookup; surfaced here as NULL for review
    END AS display_pct,
 
    -- Performance band (for dashboard colour-coding)
    -- Derived from display_pct after the flip, so bands are always intuitive:
    --   top    ≥ 75th   → strong performer within peer group
    --   middle 25–74th  → average
    --   bottom < 25th   → below average
    CASE
        WHEN (
            CASE
                WHEN l.direction = 'lower_better'  THEN 100.0 - s.cluster_pct
                WHEN l.direction = 'higher_better' THEN s.cluster_pct
                ELSE NULL
            END
        ) >= 75 THEN 'top'
        WHEN (
            CASE
                WHEN l.direction = 'lower_better'  THEN 100.0 - s.cluster_pct
                WHEN l.direction = 'higher_better' THEN s.cluster_pct
                ELSE NULL
            END
        ) >= 25 THEN 'middle'
        WHEN (
            CASE
                WHEN l.direction = 'lower_better'  THEN 100.0 - s.cluster_pct
                WHEN l.direction = 'higher_better' THEN s.cluster_pct
                ELSE NULL
            END
        ) IS NOT NULL THEN 'bottom'
        ELSE NULL
    END AS performance_band
 
FROM model_hospital_scores        s
 
-- Measure metadata (direction + display name)
LEFT JOIN model_measure_lookup    l
       ON s.measure_dataset = l.measure_dataset
      AND s.measure_id      = l.measure_id
 
-- Cluster name
LEFT JOIN model_cluster_lookup    cl
       ON s.cluster_id = cl.cluster_id
 
-- Structural profile
LEFT JOIN clean_structural        cs
       ON s.ccn = cs.ccn
 
-- Hospital name + geography
-- Adjust table name if your cleaned general info table differs
LEFT JOIN clean_hospital_general_info h
       ON s.ccn = h.facility_id
 
ORDER BY
    s.ccn,
    s.measure_dataset,
    s.measure_id;
 
 