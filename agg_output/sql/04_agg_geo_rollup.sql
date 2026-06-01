-- =============================================================================
-- Layer 5 Output 04_agg_geo_rollup.sql
-- =============================================================================
-- Purpose : One row per state × cluster, showing hospital count, structural
--           profile, and average performance within that geography × peer group
--           combination. Used in Power BI for:
--             - Map visuals (state-level cluster distribution)
--             - "How does my state compare to national peers in the same cluster?"
--             - Regional pattern analysis across archetypes
--
-- Design note: performance is summarised as the average display_pct across all
--           measures for a hospital, then averaged across hospitals in the
--           state × cluster. This gives a single "overall peer-relative
--           performance" number per geography — useful for map colouring but
--           should be interpreted carefully (it collapses 94 measures into one).
--
-- Source tables:
--   agg_hospital_scorecard      — ccn, cluster_id, cluster_name, state,
--                                 measure_dataset, display_pct, performance_band
--   model_hospital_clusters     — ccn, cluster_id (for hospitals with no scores)
--   clean_structural            — ccn, bed_size_category, urbanicity_bucket,
--                                 is_teaching, safety_net_burden
--   clean_hospital_general_info — facility_id, state, city, zip_code
-- =============================================================================

DROP TABLE IF EXISTS agg_geo_rollup;

CREATE TABLE agg_geo_rollup AS

-- Step 1: hospital-level summary - one row per ccn with avg display_pct
--         across all measures (overall peer-relative performance score)
WITH hospital_avg AS (
    SELECT
        ccn,
        cluster_id,
        cluster_name,
        ROUND(AVG(display_pct), 1)  AS avg_display_pct,

        -- Share of measures where hospital is in the top band
        ROUND(
            100.0 * SUM(CASE WHEN performance_band = 'top'    THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(*), 0), 1
        )                           AS pct_measures_top,

        ROUND(
            100.0 * SUM(CASE WHEN performance_band = 'bottom' THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(*), 0), 1
        )                           AS pct_measures_bottom,

        COUNT(DISTINCT measure_id)  AS n_measures_reported

    FROM agg_hospital_scorecard
    WHERE display_pct IS NOT NULL
    GROUP BY ccn, cluster_id, cluster_name
),

-- Step 2: attach geography
hospital_geo AS (
    SELECT
        h.ccn,
        h.cluster_id,
        h.cluster_name,
        h.avg_display_pct,
        h.pct_measures_top,
        h.pct_measures_bottom,
        h.n_measures_reported,
        g.state,
        g.city,
        cs.bed_size_category,
        cs.urbanicity_bucket,
        cs.is_teaching,
        cs.safety_net_burden
    FROM hospital_avg               h
    LEFT JOIN clean_hospital_general_info g  ON h.ccn = g.facility_id
    LEFT JOIN clean_structural            cs ON h.ccn = cs.ccn
)

-- Step 3: roll up to state × cluster
SELECT

    --  Geography 
    state,

    -- Cluster identity
    cluster_id,
    cluster_name,

    -- Size 
    COUNT(*)                                            AS n_hospitals,

    --  Overall peer-relative performance 
    -- Average of each hospital's avg_display_pct within this state × cluster
    -- Interpretation: "On average, hospitals in this state × peer group score
    -- at the Xth percentile relative to national peers in the same cluster"
    ROUND(AVG(avg_display_pct), 1)                      AS avg_peer_pct,
    ROUND(AVG(pct_measures_top), 1)                     AS avg_pct_measures_top,
    ROUND(AVG(pct_measures_bottom), 1)                  AS avg_pct_measures_bottom,

    --  Structural profile 
    ROUND(AVG(safety_net_burden), 3)                    AS avg_safety_net_burden,
    ROUND(100.0 * SUM(is_teaching) / COUNT(*), 1)       AS pct_teaching,

    --  Urbanicity composition 
    ROUND(100.0 * SUM(CASE WHEN urbanicity_bucket = 'metro'      THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_metro,
    ROUND(100.0 * SUM(CASE WHEN urbanicity_bucket = 'micro'      THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_micro,
    ROUND(100.0 * SUM(CASE WHEN urbanicity_bucket = 'small_town' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_small_town,
    ROUND(100.0 * SUM(CASE WHEN urbanicity_bucket = 'rural'      THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_rural,

    --  Bed size composition
    ROUND(100.0 * SUM(CASE WHEN bed_size_category = 'small'  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_small,
    ROUND(100.0 * SUM(CASE WHEN bed_size_category = 'medium' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_medium,
    ROUND(100.0 * SUM(CASE WHEN bed_size_category = 'large'  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_large

FROM hospital_geo

WHERE state IS NOT NULL

GROUP BY
    state,
    cluster_id,
    cluster_name

ORDER BY
    state,
    cluster_id;

