--SELECT * FROM clean_hcahps_patient_survey limit 6
SELECT COUNT(*) AS unusual_count 
FROM clean_hcahps_patient_survey
WHERE patient_survey_star_rating IS NOT NULL AND patient_survey_star_rating NOT BETWEEN 1 AND 5
OR hcahps_answer_percent IS NOT NULL AND hcahps_answer_percent NOT BETWEEN 0 AND 100
OR hcahps_linear_mean_value IS NOT NULL AND hcahps_linear_mean_value NOT BETWEEN 0 AND 100
OR number_of_completed_surveys IS NOT NULL AND number_of_completed_surveys < 0
OR survey_response_rate_percent IS NOT NULL AND survey_response_rate_percent NOT BETWEEN 0 AND 100