DROP TABLE IF EXISTS clean_timely_effective_care;

CREATE TABLE clean_timely_effective_care AS
SELECT
    "Facility ID"   AS facility_id,
    "Condition"     AS condition,
    "Measure ID"    AS measure_id,
    "Measure Name"  AS measure_name,
    "Score"         AS score,
    "Sample"        AS sample,
    "Footnote"      AS footnote,
    "Start Date"    AS start_date,
    "End Date"      AS end_date
FROM stg_timely_effective_care;

SELECT COUNT(*) AS row_count FROM clean_timely_effective_care;