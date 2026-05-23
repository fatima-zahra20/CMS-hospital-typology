DROP TABLE IF EXISTS clean_medicare_spending;
CREATE TABLE clean_medicare_spending AS
SELECT
    -- CCN: pad to 6 digits to restore leading zeros stripped by pandas
    printf('%06d', CAST("Facility ID" AS INTEGER))               AS facility_id,
    
    -- Text dimensions: trim + null out empty strings
    NULLIF(TRIM("Period"),       '')                              AS period,
    NULLIF(TRIM("Claim Type"),   '')                              AS claim_type,
    
    -- Spending amounts: already numeric in staging, just cast to REAL to be safe
    CAST("Avg Spndg Per EP Hospital" AS REAL)                    AS avg_spd_ep_hospital,
    CAST("Avg Spndg Per EP State"    AS REAL)                    AS avg_spd_ep_state,
    CAST("Avg Spndg Per EP National" AS REAL)                    AS avg_spd_ep_national,
    
    -- Percentages: strip '%' sign, then cast to REAL
    CAST(REPLACE("Percent of Spndg Hospital", '%', '') AS REAL)  AS pct_spend_hospital,
    CAST(REPLACE("Percent of Spndg State",    '%', '') AS REAL)  AS pct_spend_state,
    CAST(REPLACE("Percent of Spndg National", '%', '') AS REAL)  AS pct_spend_national,
    
    -- Reporting window — match your ISO-date pattern from the other clean tables
    DATE(NULLIF(TRIM("Start Date"), ''))                         AS start_date,
    DATE(NULLIF(TRIM("End Date"),   ''))                         AS end_date
FROM stg_medicare_spending;

SELECT COUNT(*) AS row_count FROM clean_medicare_spending;
-- Expected: close to 63,646 (matched 63,448 originally)