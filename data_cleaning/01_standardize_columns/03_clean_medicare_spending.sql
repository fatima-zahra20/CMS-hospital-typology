DROP TABLE IF EXISTS clean_medicare_spending;

CREATE TABLE clean_medicare_spending AS
SELECT
    "Facility ID"            AS facility_id,
    "Period"                 AS period,
    "Claim Type"             AS claim_type,
    "Avg Spndg Per EP Hospital"   AS avg_spd_ep_hospital,
    "Avg Spndg Per EP State"      AS avg_spd_ep_state,
    "Avg Spndg Per EP National"   AS avg_spd_ep_national,
    "Percent of Spndg Hospital"   AS pct_spend_hospital,
    "Percent of Spndg State"      AS pct_spend_state,
    "Percent of Spndg National"   AS pct_spend_national
FROM stg_medicare_spending;

SELECT COUNT(*) AS row_count FROM clean_medicare_spending;
