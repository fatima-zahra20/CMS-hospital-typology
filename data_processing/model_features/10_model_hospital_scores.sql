-- Unified within-cluster scoring table. UNION ALL of the 6 per-dataset
-- score tables, restricted to the columns they all share.
--
-- Context columns specific to each dataset (denominator, sample_n,
-- response_rate, infection_count, etc.) stay in the per-dataset tables
-- and can be joined back when needed. Keeps the unified table semantically
-- clean while preserving rich context per dataset.
--
-- Direction is NOT in this table — it lives in model_measure_lookup and
-- is applied at the display layer (Layer 5 / Power BI). The score table
-- stays direction-neutral.

DROP TABLE IF EXISTS model_hospital_scores;
CREATE TABLE model_hospital_scores AS
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_readmissions
UNION ALL
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_medicare_spending
UNION ALL
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_healthcare_infections
UNION ALL
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_hcahps_patient_survey
UNION ALL
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_unplanned_visits
UNION ALL
SELECT ccn, cluster_id, measure_dataset, measure_id, measure_value,
       cluster_rank, cluster_pct, cluster_n
FROM model_scores_timely_effective_care;

-- Indexes for the common query patterns: lookup by hospital, by measure,
-- and by cluster. Power BI and Layer 5 will hit these often.
CREATE INDEX idx_scores_ccn      ON model_hospital_scores(ccn);
CREATE INDEX idx_scores_measure  ON model_hospital_scores(measure_dataset, measure_id);
CREATE INDEX idx_scores_cluster  ON model_hospital_scores(cluster_id, measure_id);