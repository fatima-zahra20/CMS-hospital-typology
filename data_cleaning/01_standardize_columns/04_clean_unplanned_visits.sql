DROP TABLE IF EXISTS clean_unplanned_visits;

CREATE TABLE clean_unplanned_visits AS
SELECT
    "Facility ID"            AS facility_id,
    "Measure ID"             AS measure_id,
    "Measure Name"           AS measure_name,
    "Compared to National"   AS compared_to_national,
    "Denominator"            AS denominator,
    "Score"                  AS score,
    "Lower Estimate"         AS lower_estimate,
    "Higher Estimate"        AS higher_estimate,
    "Footnote"               AS footnote,
    "Start Date"             AS start_date,
    "End Date"               AS end_date
FROM stg_unplanned_visits;

SELECT COUNT(*) AS row_count FROM clean_unplanned_visits;