-- ============================================================
-- 10_clean_ruca.sql
-- Layer 3 cleaning for stg_ruca → clean_ruca
-- 
-- Transformations applied:
--   1. ZIP zero-padded to 5 chars (matches clean_cohort.zip_code format)
--   2. Primary RUCA (1-10) mapped to 4-bucket urbanicity:
--        1-3  → metro       (large urbanized areas + their commuter belts)
--        4-6  → micro       (cities of 10K-50K + their commuter belts)
--        7-9  → small_town  (clusters of 2.5K-10K + commuter belts)
--        10   → rural       (everything else)
--   3. Original primary_ruca kept for audit/traceability
--
-- Output: 41,146 rows (1 per ZIP), 5 columns
-- ============================================================

DROP TABLE IF EXISTS clean_ruca;

CREATE TABLE clean_ruca AS
SELECT
    -- Zero-pad ZIP to 5 chars so this joins with clean_cohort.zip_code
    printf('%05d', CAST(zip_code AS INTEGER)) AS zip_code,

    -- Keep for audit / debugging hospital matches
    state,
    zip_code_type,

    -- Map RUCA 1-10 to 4-bucket urbanicity (the analytical decision)
    CASE
        WHEN primary_ruca BETWEEN 1 AND 3 THEN 'metro'
        WHEN primary_ruca BETWEEN 4 AND 6 THEN 'micro'
        WHEN primary_ruca BETWEEN 7 AND 9 THEN 'small_town'
        WHEN primary_ruca = 10            THEN 'rural'
        ELSE NULL
    END AS urbanicity_bucket,

    -- Preserve the original code for traceability
    primary_ruca AS primary_ruca_raw

FROM stg_ruca;