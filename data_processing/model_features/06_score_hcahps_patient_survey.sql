-- Within-cluster scoring for the hcahps_patient_survey dataset.
--
-- Structural quirk: each HCAHPS domain (nurse communication, cleanliness,
-- etc.) has ~5 sub-rows per hospital-A_P (% always), U_P (% usually),
-- SN_P (% sometimes/never), LINEAR_SCORE (composite), STAR_RATING (1-5).
-- Values are spread across three different columns depending on row type.
--
-- We rank on the LINEAR_SCORE rows only:
--  - Most granular (very few ties; star ratings only have 5 possible values)
--  - Covers every HCAHPS domain at the same granularity
--  - It's what CMS's own star ratings are derived from
-- Coverage is ~3,176 hospitals overall; ~25% have percent data but not
-- enough surveys to compute a stable linear composite.
--
-- Direction: HCAHPS linear scores are HIGHER-IS-BETTER. Per project
-- convention, percentile is still computed in numerical order; the
-- direction flag lives in model_measure_lookup (built once all score
-- scripts are done). So in THIS table, cluster_rank=1 is the LOWEST
-- score (worst), and cluster_rank=N is the HIGHEST score (best).

DROP TABLE IF EXISTS model_scores_hcahps_patient_survey;
CREATE TABLE model_scores_hcahps_patient_survey AS
SELECT
    r.facility_id AS ccn,
    hc.cluster_id,
    'hcahps_patient_survey' AS measure_dataset,
    r.measure_id,
    r.hcahps_linear_mean_value AS measure_value,
    r.number_of_completed_surveys AS survey_n,       -- context: sample size
    r.survey_response_rate_percent AS response_rate, -- context: response rate
    RANK() OVER (
        PARTITION BY hc.cluster_id, r.measure_id
        ORDER BY r.hcahps_linear_mean_value
    ) AS cluster_rank,
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY hc.cluster_id, r.measure_id
            ORDER BY r.hcahps_linear_mean_value
        ) * 100,
        2
    ) AS cluster_pct,
    COUNT(*) OVER (
        PARTITION BY hc.cluster_id, r.measure_id
    ) AS cluster_n
FROM clean_hcahps_patient_survey r
INNER JOIN model_hospital_clusters hc
    ON r.facility_id = hc.ccn
WHERE r.measure_id LIKE '%_LINEAR_SCORE'
  AND r.hcahps_linear_mean_value IS NOT NULL;