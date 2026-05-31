-- Within-cluster scoring for the unplanned_visits dataset.
-- Structurally identical to readmissions: single measure_id, single score.
-- 
-- Measures include EDAC_30_* (Excess Days in Acute Care for AMI, HF, PN, etc.),
-- OP_* (outpatient procedure return rates), and Hybrid_HWM (which also appears
-- in readmissions_and_deaths — both rankings are kept; see project notes).
--
-- Note on EDAC scores: values can be NEGATIVE. A negative EDAC means fewer
-- excess days than expected (good); positive means more (bad). Numerical-order
-- ranking handles this naturally — most-negative gets rank 1.
--
-- Direction: all measures are LOWER-IS-BETTER.

DROP TABLE IF EXISTS model_scores_unplanned_visits;
CREATE TABLE model_scores_unplanned_visits AS
SELECT
    r.facility_id AS ccn,
    hc.cluster_id,
    'unplanned_visits' AS measure_dataset,
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
FROM clean_unplanned_visits r
INNER JOIN model_hospital_clusters hc
    ON r.facility_id = hc.ccn
WHERE r.score IS NOT NULL;