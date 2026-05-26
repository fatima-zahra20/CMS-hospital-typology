-- 08_clean_ipps.sql
-- Layer 3 cleaning for stg_ipps → clean_ipps
-- 
-- Transformations applied:
--   1. CCN zero-padded to 6 chars (matches clean_cohort.facility_id)
--   2. Explicit type casts (REAL / INTEGER)
--   3. 'Zero means missing' rule applied to bed_count and cmi
--      (per CMS data dictionary: zero values may indicate unavailable data)
--   4. urban_rural_geo collapsed to U/R; raw value preserved for audit
--
-- Output: 3,103 rows (1 per IPPS hospital), 7 columns


DROP TABLE IF EXISTS clean_ipps;

CREATE TABLE clean_ipps AS
SELECT
    -- CCN: pad with leading zeros so this joins with clean_cohort.facility_id
    printf('%06d', CAST(ccn AS INTEGER)) AS ccn,

    -- Beds: integer; zero indicates missing per CMS docs, so convert to NULL
    NULLIF(CAST(bed_count AS INTEGER), 0) AS bed_count,

    -- Case Mix Index: real; zero indicates missing
    NULLIF(CAST(cmi AS REAL), 0) AS cmi,

    -- Resident-to-bed ratio: real; zero is a VALID value here (means non-teaching)
    CAST(resident_to_bed_ratio AS REAL) AS resident_to_bed_ratio,

    -- DSH patient %: real on 0-1 scale (safety-net burden indicator)
    CAST(dsh_pct AS REAL) AS dsh_pct,

    -- Coarse urban/rural standardization (fine version comes from RUCA later)
    CASE
        WHEN urban_rural_geo = 'RURAL'                       THEN 'R'
        WHEN urban_rural_geo IN ('URBAN', 'LURBAN', 'OURBAN') THEN 'U'
        ELSE NULL
    END AS urban_rural_geo,

    -- Preserve the original CMS value for audit/traceability
    urban_rural_geo AS urban_rural_geo_raw

FROM stg_ipps;