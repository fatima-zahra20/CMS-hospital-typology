DROP TABLE IF EXISTS clean_healthcare_infections;
CREATE TABLE clean_healthcare_infections AS
SELECT

    "Facility ID"                        AS facility_id,
    "Measure ID"                         AS measure_id,
    "Measure Name"                       AS measure_name,
    "Compared to National"               AS compared_to_national,
    "Score"                              AS score,
    "Footnote"                           AS footnote,
    "Start Date"                         AS start_date,
    "End Date"                           AS end_date
FROM stg_healthcare_infections;

SELECT COUNT(*) AS row_count FROM clean_healthcare_infections;