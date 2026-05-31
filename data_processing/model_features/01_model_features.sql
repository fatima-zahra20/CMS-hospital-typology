DROP TABLE IF EXISTS model_features;
CREATE TABLE model_features AS

-- Group-aware median of safety_net_burden for imputation.
-- Group = bed_size_category x urbanicity_bucket. 21 hospitals have NULL DSH
-- after the zero-as-missing fix in 09_clean_ipps.sql; imputing within a
-- structural peer group is more honest than the global median.
WITH ranked AS (
    SELECT
        bed_size_category,
        urbanicity_bucket,
        safety_net_burden,
        ROW_NUMBER() OVER (
            PARTITION BY bed_size_category, urbanicity_bucket
            ORDER BY safety_net_burden
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY bed_size_category, urbanicity_bucket
        ) AS n
    FROM clean_structural
    WHERE ipps_covered = 1
      AND safety_net_burden IS NOT NULL
),
group_medians AS (
    -- Standard SQL median pattern: AVG of middle row(s).
    -- Odd n: (n+1)/2 = (n+2)/2, single middle row.
    -- Even n: two middle rows, AVG gives the median.
    SELECT
        bed_size_category,
        urbanicity_bucket,
        AVG(safety_net_burden) AS group_median_dsh
    FROM ranked
    WHERE rn IN ((n+1)/2, (n+2)/2)
    GROUP BY bed_size_category, urbanicity_bucket
),
-- Fallback: overall cohort median for any group with no non-NULL DSH.
overall_ranked AS (
    SELECT
        safety_net_burden,
        ROW_NUMBER() OVER (ORDER BY safety_net_burden) AS rn,
        COUNT(*) OVER () AS n
    FROM clean_structural
    WHERE ipps_covered = 1
      AND safety_net_burden IS NOT NULL
),
overall_median AS (
    SELECT AVG(safety_net_burden) AS overall_median_dsh
    FROM overall_ranked
    WHERE rn IN ((n+1)/2, (n+2)/2)
)

SELECT
    cs.ccn,

    -- Log-transform bed count to pull in the right-skewed tail.
    -- LN() requires SQLite 3.35+ math functions; DB Browser includes them.
    LN(cs.bed_count) AS log_bed_count,

    cs.cmi,
    cs.is_teaching,

    -- Impute NULL DSH with group median; fall back to overall median.
    COALESCE(
        cs.safety_net_burden,
        gm.group_median_dsh,
        (SELECT overall_median_dsh FROM overall_median)
    ) AS safety_net_burden,

    -- Audit flag: 1 if DSH was imputed, 0 if original. Excluded from
    -- the clustering feature set in Python; kept here for traceability.
    CASE WHEN cs.safety_net_burden IS NULL THEN 1 ELSE 0 END AS safety_net_burden_imputed,

    -- One-hot encoding of urbanicity. KMeans handles nominal categories
    -- via dummies; ordinal encoding would imply equal distance between
    -- metro->micro->small_town->rural, which isn't structurally true.
    CASE WHEN cs.urbanicity_bucket = 'metro'      THEN 1 ELSE 0 END AS is_metro,
    CASE WHEN cs.urbanicity_bucket = 'micro'      THEN 1 ELSE 0 END AS is_micro,
    CASE WHEN cs.urbanicity_bucket = 'small_town' THEN 1 ELSE 0 END AS is_small_town,
    CASE WHEN cs.urbanicity_bucket = 'rural'      THEN 1 ELSE 0 END AS is_rural

FROM clean_structural cs
LEFT JOIN group_medians gm
    ON cs.bed_size_category = gm.bed_size_category
   AND cs.urbanicity_bucket = gm.urbanicity_bucket
WHERE cs.ipps_covered = 1;