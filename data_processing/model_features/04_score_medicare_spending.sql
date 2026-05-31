-- Within-cluster scoring for the medicare_spending dataset (MSPB measures).
--
-- This dataset has no single measure_id column. The "measure" is implicit in
-- the (period, claim_type) combination, so we construct a synthetic
-- measure_id by concatenating them. 22 total measures per hospital.
-- SELECT period, claim_type, COUNT(*) AS n_rows
-- Direction: all measures are LOWER-IS-BETTER (less Medicare spending per
-- episode = more efficient hospital). Same convention as readmissions:
-- percentile is computed in numerical order; direction is applied at the
-- display layer via cluster_lookup.

DROP TABLE IF EXISTS model_scores_medicare_spending;
CREATE TABLE model_scores_medicare_spending AS
SELECT
    m.facility_id AS ccn,
    hc.cluster_id,
    'medicare_spending' AS measure_dataset,
    m.period || ' | ' || m.claim_type AS measure_id,
    m.avg_spd_ep_hospital AS measure_value,
    m.pct_spend_hospital,           
    m.avg_spd_ep_national,           
    RANK() OVER (
        PARTITION BY hc.cluster_id, m.period, m.claim_type
        ORDER BY m.avg_spd_ep_hospital
    ) AS cluster_rank,
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY hc.cluster_id, m.period, m.claim_type
            ORDER BY m.avg_spd_ep_hospital
        ) * 100,
        2
    ) AS cluster_pct,
    COUNT(*) OVER (
        PARTITION BY hc.cluster_id, m.period, m.claim_type
    ) AS cluster_n
FROM clean_medicare_spending m
INNER JOIN model_hospital_clusters hc
    ON m.facility_id = hc.ccn
WHERE m.avg_spd_ep_hospital IS NOT NULL;