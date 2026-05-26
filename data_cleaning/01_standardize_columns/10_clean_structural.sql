--clean_structural.sql
-- Final Layer 3 table: one row per in-scope hospital, with all
-- structural features needed for Layer 4 clustering.
--
-- Sources:
--   clean_cohort     — defines scope (WHERE included = 1)
--   clean_ipps       — beds, CMI, teaching, DSH (LEFT JOIN on ccn)
--   clean_ruca       — urbanicity bucket from ZIP (LEFT JOIN on zip)
--
-- Analytical decisions baked in:
--   - bed_size_category cutpoints: <100 small, 100-399 medium, 400+ large
--   - is_teaching: 1 if resident_to_bed_ratio > 0, else 0
--   - urbanicity fallback: if RUCA doesn't match, use clean_ipps.urban_rural_geo
--   - ipps_covered flag: lets downstream code know which fields are NULL on purpose
--
-- Output: ~3,115 rows (= clean_cohort.included = 1)

DROP TABLE IF EXISTS clean_structural;

CREATE TABLE clean_structural AS
SELECT
    c.facility_id                                AS ccn,

    -- Bed count (raw) and bucketed
    i.bed_count,
    CASE
        WHEN i.bed_count IS NULL          THEN NULL
        WHEN i.bed_count < 100            THEN 'small'
        WHEN i.bed_count < 400            THEN 'medium'
        ELSE                                   'large'
    END                                          AS bed_size_category,

    -- Case mix index (passthrough)
    i.cmi,

    -- Teaching status: binary derived from resident-to-bed ratio
    -- 0 = no residents (non-teaching), >0 = has residents (teaching)
    -- NULL only if IPPS data is missing entirely
    CASE
        WHEN i.resident_to_bed_ratio IS NULL THEN NULL
        WHEN i.resident_to_bed_ratio > 0     THEN 1
        ELSE                                      0
    END                                          AS is_teaching,

    -- Safety-net burden (DSH patient %, 0-1 scale, passthrough)
    i.dsh_pct                                    AS safety_net_burden,

    -- Urbanicity: prefer RUCA's 4-level bucket, fall back to IPPS U/R if no match
    COALESCE(
        r.urbanicity_bucket,
        CASE i.urban_rural_geo
            WHEN 'U' THEN 'metro'   -- coarsest fallback; not strictly correct but better than NULL
            WHEN 'R' THEN 'rural'
        END
    )                                            AS urbanicity_bucket,

    -- Flag telling downstream code whether IPPS data was found
    -- (so NULLs in bed_count/cmi/etc are interpretable, not mysterious)
    CASE WHEN i.ccn IS NULL THEN 0 ELSE 1 END    AS ipps_covered

FROM clean_cohort c
LEFT JOIN clean_ipps i ON c.facility_id = i.ccn
LEFT JOIN clean_ruca r ON c.zip_code    = r.zip_code
WHERE c.included = 1;
