-- 1. Bucket distribution
SELECT urbanicity_bucket, COUNT(*) AS n
FROM clean_ruca
GROUP BY urbanicity_bucket
ORDER BY n DESC;

-- 2. Padding sanity check — should all be exactly 5 chars
SELECT LENGTH(zip_code) AS zip_len, COUNT(*) AS n
FROM clean_ruca
GROUP BY zip_len;