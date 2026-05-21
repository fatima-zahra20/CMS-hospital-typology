DROP TABLE IF EXISTS clean_hcahps_patient_survey;

CREATE TABLE clean_hcahps_patient_survey AS
SELECT
    "Facility ID"                              AS facility_id,
    "HCAHPS Measure ID"                        AS measure_id,
    "HCAHPS Question"                          AS hcahps_question,
    "HCAHPS Answer Description"                AS hcahps_answer_description,
    "Patient Survey Star Rating"               AS patient_survey_star_rating,
    "Patient Survey Star Rating Footnote"      AS patient_survey_star_rating_footnote,
    "HCAHPS Answer Percent"                    AS hcahps_answer_percent,
    "HCAHPS Answer Percent Footnote"           AS hcahps_answer_percent_footnote,
    "HCAHPS Linear Mean Value"                 AS hcahps_linear_mean_value,
    "Number of Completed Surveys"              AS number_of_completed_surveys,
    "Number of Completed Surveys Footnote"     AS number_of_completed_surveys_footnote,
    "Survey Response Rate Percent"             AS survey_response_rate_percent,
    "Survey Response Rate Percent Footnote"    AS survey_response_rate_percent_footnote,
    "Start Date"                               AS start_date,
    "End Date"                                 AS end_date
FROM stg_hcahps_patient_survey;

SELECT COUNT(*) AS row_count FROM clean_hcahps_patient_survey;