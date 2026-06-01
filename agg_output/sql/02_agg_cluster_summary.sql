-- =============================================================================
-- Layer 5 Output 02_agg_cluster_summary.sql
-- =============================================================================
-- Purpose : One row per cluster, summarising the structural profile and size
--           of each peer group. Used in Power BI for slicer labels, cluster
--           description cards, and header context on hospital scorecards.
--
-- Source tables:
--   model_hospital_clusters - ccn, cluster_id
--   model_cluster_lookup    - cluster_id, cluster_name
--   clean_structural        - ccn, bed_count, cmi, is_teaching,
--                              safety_net_burden, urbanicity_bucket,
--                              bed_size_category, ipps_covered
-- =============================================================================

DROP TABLE IF EXISTS agg_cluster_summary;

CREATE TABLE agg_cluster_summary AS

SELECT

    -- Cluster identity
    c.cluster_id,
    cl.cluster_name,

    --  Size 
    COUNT(*)                                        AS n_hospitals,

    --  Bed count 
    ROUND(AVG(cs.bed_count), 0)                     AS avg_bed_count,
    MIN(cs.bed_count)                               AS min_bed_count,
    MAX(cs.bed_count)                               AS max_bed_count,

    -- Case Mix Index
    ROUND(AVG(cs.cmi), 3)                           AS avg_cmi,

    --  Teaching (share of hospitals with residents) 
    ROUND(100.0 * SUM(cs.is_teaching) / COUNT(*), 1) AS pct_teaching,

    --Safety-net burden (avg DSH percentage across cluster)
    ROUND(AVG(cs.safety_net_burden), 3)             AS avg_safety_net_burden,

    -- Urbanicity composition 
    ROUND(100.0 * SUM(CASE WHEN cs.urbanicity_bucket = 'metro'       THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_metro,
    ROUND(100.0 * SUM(CASE WHEN cs.urbanicity_bucket = 'micro'       THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_micro,
    ROUND(100.0 * SUM(CASE WHEN cs.urbanicity_bucket = 'small_town'  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_small_town,
    ROUND(100.0 * SUM(CASE WHEN cs.urbanicity_bucket = 'rural'       THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_rural,

    -- Bed size composition 
    ROUND(100.0 * SUM(CASE WHEN cs.bed_size_category = 'small'  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_small,
    ROUND(100.0 * SUM(CASE WHEN cs.bed_size_category = 'medium' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_medium,
    ROUND(100.0 * SUM(CASE WHEN cs.bed_size_category = 'large'  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_large,

    -- IPPS coverage (share with full structural data)
    ROUND(100.0 * SUM(cs.ipps_covered) / COUNT(*), 1) AS pct_ipps_covered

FROM model_hospital_clusters      c

LEFT JOIN model_cluster_lookup    cl
       ON c.cluster_id = cl.cluster_id

LEFT JOIN clean_structural        cs
       ON c.ccn = cs.ccn

GROUP BY
    c.cluster_id,
    cl.cluster_name

ORDER BY
    c.cluster_id;
