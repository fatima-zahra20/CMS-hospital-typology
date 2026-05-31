-- Within-cluster scoring for the timely_effective_care dataset.
--
-- Most structurally heterogeneous of the six performance datasets:
--  - `score` is the rankable numerical column; `score_tier` is categorical
--    (e.g., "very high") and not used for ranking
--  - EDV (Emergency Department Volume) only has tier, never score — excluded
--    automatically by the NULL filter
--  - GMCS family currently entirely suppressed in this snapshot — also
--    excluded automatically
--  - Coverage varies widely: high-coverage measures (~1,600 hospitals) down
--    to sparse measures like OP_31 (~15 hospitals). Sparse measures produce
--    small per-cluster groups; that's fine — downstream consumers can filter
--    on cluster_n if they want statistical-stability thresholds.
--
-- Direction: MIXED in this dataset. Most measures are HIGHER-IS-BETTER 
-- (compliance rates with care protocols like "% stroke patients discharged
-- on statin"), but a few are LOWER-IS-BETTER (ED wait times in minutes,
-- Hospital Harm rates). Per project convention, percentile is computed in
-- numerical order; direction is applied per-measure at the display layer
-- via model_measure_lookup.

DROP TABLE IF EXISTS model_scores_timely_effective_care;
CREATE TABLE model_scores_timely_effective_care AS
SELECT
    r.facility_id AS ccn,
    hc.cluster_id,
    'timely_effective_care' AS measure_dataset,
    r.measure_id,
    r.score AS measure_value,
    r.sample AS sample_size,        -- context: case count denominator
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
FROM clean_timely_effective_care r
INNER JOIN model_hospital_clusters hc
    ON r.facility_id = hc.ccn
WHERE r.score IS NOT NULL;