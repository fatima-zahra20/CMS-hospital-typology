DROP TABLE IF EXISTS clean_hcahps_patient_survey;

CREATE TABLE clean_hcahps_patient_survey AS
SELECT
    -- CCN: already TEXT and 6 digits, just trim defensively
    NULLIF(TRIM("Facility ID"), '')                                                    AS facility_id,
    
    -- Categorical text columns
    NULLIF(TRIM("HCAHPS Measure ID"),         '')                                      AS measure_id,
    NULLIF(TRIM("HCAHPS Question"),           '')                                      AS hcahps_question,
    NULLIF(TRIM("HCAHPS Answer Description"), '')                                      AS hcahps_answer_description,
    
    -- Star rating: INTEGER 1-5 (or NULL)
    CASE 
        WHEN TRIM("Patient Survey Star Rating") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Patient Survey Star Rating" AS INTEGER)
    END                                                                                AS patient_survey_star_rating,
    
    NULLIF(TRIM("Patient Survey Star Rating Footnote"), '')                            AS patient_survey_star_rating_footnote,
    
    -- Answer percent: REAL
    CASE 
        WHEN TRIM("HCAHPS Answer Percent") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("HCAHPS Answer Percent" AS REAL)
    END                                                                                AS hcahps_answer_percent,
    
    NULLIF(TRIM("HCAHPS Answer Percent Footnote"), '')                                 AS hcahps_answer_percent_footnote,
    
    -- Linear mean value: REAL
    CASE 
        WHEN TRIM("HCAHPS Linear Mean Value") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("HCAHPS Linear Mean Value" AS REAL)
    END                                                                                AS hcahps_linear_mean_value,
    
    -- Number of completed surveys: INTEGER (count)
    CASE 
        WHEN TRIM("Number of Completed Surveys") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Number of Completed Surveys" AS INTEGER)
    END                                                                                AS number_of_completed_surveys,
    
    NULLIF(TRIM("Number of Completed Surveys Footnote"), '')                           AS number_of_completed_surveys_footnote,
    
    -- Survey response rate: REAL (percent)
    CASE 
        WHEN TRIM("Survey Response Rate Percent") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Survey Response Rate Percent" AS REAL)
    END                                                                                AS survey_response_rate_percent,
    
    NULLIF(TRIM("Survey Response Rate Percent Footnote"), '')                          AS survey_response_rate_percent_footnote,
    
    -- Dates: MM/DD/YYYY → YYYY-MM-DD
    CASE
        WHEN "Start Date" IS NULL OR TRIM("Start Date") = '' THEN NULL
        ELSE substr("Start Date", 7, 4) || '-' || substr("Start Date", 1, 2) || '-' || substr("Start Date", 4, 2)
    END                                                                                AS start_date,
    
    CASE
        WHEN "End Date" IS NULL OR TRIM("End Date") = '' THEN NULL
        ELSE substr("End Date", 7, 4) || '-' || substr("End Date", 1, 2) || '-' || substr("End Date", 4, 2)
    END                                                                                AS end_date

FROM stg_hcahps_patient_survey;

SELECT COUNT(*) AS row_count FROM clean_hcahps_patient_survey;