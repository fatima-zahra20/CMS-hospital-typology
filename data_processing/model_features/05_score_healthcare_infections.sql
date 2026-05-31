-- Within-cluster scoring for the healthcare_infections dataset.
--
-- Structural quirk: CMS encodes 6 sub-rows per (hospital, infection type):
--   _SIR        - Standardized Infection Ratio (the rankable headline metric)
--   _NUMERATOR  - raw infection count
--   _DOPC       - device-days or eligible procedures (SIR denominator)
--   _ELIGCASES  - number of eligible cases
--   _CILOWER, _CIUPPER - 95% CI bounds on the SIR
-- We rank only on the SIR rows. NUMERATOR and DOPC are pulled in via
-- self-joins as context columns alongside each ranked SIR.
--
-- Direction: SIR is LOWER-IS-BETTER. A SIR of 1.0 means infections matched
-- the expected count given case mix; <1.0 = better than expected,
-- >1.0 = worse than expected.

DROP TABLE IF EXISTS model_scores_healthcare_infections;
CREATE TABLE model_scores_healthcare_infections AS
SELECT
    sir.facility_id AS ccn,
    hc.cluster_id,
    'healthcare_infections' AS measure_dataset,
    sir.measure_id,
    sir.score AS measure_value,
    num.score  AS infection_count,    -- raw count of infections (NUMERATOR)
    dopc.score AS at_risk_volume,     -- device-days or procedures (DOPC)
    RANK() OVER (
        PARTITION BY hc.cluster_id, sir.measure_id
        ORDER BY sir.score
    ) AS cluster_rank,
    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY hc.cluster_id, sir.measure_id
            ORDER BY sir.score
        ) * 100,
        2
    ) AS cluster_pct,
    COUNT(*) OVER (
        PARTITION BY hc.cluster_id, sir.measure_id
    ) AS cluster_n
FROM clean_healthcare_infections sir
INNER JOIN model_hospital_clusters hc
    ON sir.facility_id = hc.ccn
LEFT JOIN clean_healthcare_infections num
    ON sir.facility_id = num.facility_id
   AND num.measure_id = REPLACE(sir.measure_id, '_SIR', '_NUMERATOR')
LEFT JOIN clean_healthcare_infections dopc
    ON sir.facility_id = dopc.facility_id
   AND dopc.measure_id = REPLACE(sir.measure_id, '_SIR', '_DOPC')
WHERE sir.measure_id LIKE 'HAI_%_SIR'
  AND sir.score IS NOT NULL;