-- File: data_cleaning/checks/check_categorical_all_tables.sql
-- Detects case/whitespace variants across all categorical columns of interest
-- Should return 0 rows in a healthy state

SELECT 'clean_hospital_general_info' AS source_table, 'hospital_type' AS column_name,
       LOWER(TRIM(hospital_type)) AS normalized,
       COUNT(DISTINCT hospital_type) AS variants,
       GROUP_CONCAT(DISTINCT hospital_type) AS actual_values
FROM clean_hospital_general_info WHERE hospital_type IS NOT NULL
GROUP BY LOWER(TRIM(hospital_type)) HAVING COUNT(DISTINCT hospital_type) > 1

UNION ALL
SELECT 'clean_hospital_general_info', 'ownership',
       LOWER(TRIM(ownership)), COUNT(DISTINCT ownership), GROUP_CONCAT(DISTINCT ownership)
FROM clean_hospital_general_info WHERE ownership IS NOT NULL
GROUP BY LOWER(TRIM(ownership)) HAVING COUNT(DISTINCT ownership) > 1

UNION ALL
SELECT 'clean_hospital_general_info', 'state',
       LOWER(TRIM(state)), COUNT(DISTINCT state), GROUP_CONCAT(DISTINCT state)
FROM clean_hospital_general_info WHERE state IS NOT NULL
GROUP BY LOWER(TRIM(state)) HAVING COUNT(DISTINCT state) > 1

UNION ALL
SELECT 'clean_readmissions_and_deaths', 'compared_to_national',
       LOWER(TRIM(compared_to_national)), COUNT(DISTINCT compared_to_national), GROUP_CONCAT(DISTINCT compared_to_national)
FROM clean_readmissions_and_deaths WHERE compared_to_national IS NOT NULL
GROUP BY LOWER(TRIM(compared_to_national)) HAVING COUNT(DISTINCT compared_to_national) > 1

UNION ALL
SELECT 'clean_medicare_spending', 'period',
       LOWER(TRIM(period)), COUNT(DISTINCT period), GROUP_CONCAT(DISTINCT period)
FROM clean_medicare_spending WHERE period IS NOT NULL
GROUP BY LOWER(TRIM(period)) HAVING COUNT(DISTINCT period) > 1

UNION ALL
SELECT 'clean_medicare_spending', 'claim_type',
       LOWER(TRIM(claim_type)), COUNT(DISTINCT claim_type), GROUP_CONCAT(DISTINCT claim_type)
FROM clean_medicare_spending WHERE claim_type IS NOT NULL
GROUP BY LOWER(TRIM(claim_type)) HAVING COUNT(DISTINCT claim_type) > 1

UNION ALL
SELECT 'clean_healthcare_infections', 'compared_to_national',
       LOWER(TRIM(compared_to_national)), COUNT(DISTINCT compared_to_national), GROUP_CONCAT(DISTINCT compared_to_national)
FROM clean_healthcare_infections WHERE compared_to_national IS NOT NULL
GROUP BY LOWER(TRIM(compared_to_national)) HAVING COUNT(DISTINCT compared_to_national) > 1

UNION ALL
SELECT 'clean_hcahps_patient_survey', 'hcahps_answer_description',
       LOWER(TRIM(hcahps_answer_description)), COUNT(DISTINCT hcahps_answer_description), GROUP_CONCAT(DISTINCT hcahps_answer_description)
FROM clean_hcahps_patient_survey WHERE hcahps_answer_description IS NOT NULL
GROUP BY LOWER(TRIM(hcahps_answer_description)) HAVING COUNT(DISTINCT hcahps_answer_description) > 1

UNION ALL
SELECT 'clean_unplanned_visits', 'compared_to_national',
       LOWER(TRIM(compared_to_national)), COUNT(DISTINCT compared_to_national), GROUP_CONCAT(DISTINCT compared_to_national)
FROM clean_unplanned_visits WHERE compared_to_national IS NOT NULL
GROUP BY LOWER(TRIM(compared_to_national)) HAVING COUNT(DISTINCT compared_to_national) > 1

UNION ALL
SELECT 'clean_timely_effective_care', 'condition',
       LOWER(TRIM(condition)), COUNT(DISTINCT condition), GROUP_CONCAT(DISTINCT condition)
FROM clean_timely_effective_care WHERE condition IS NOT NULL
GROUP BY LOWER(TRIM(condition)) HAVING COUNT(DISTINCT condition) > 1

UNION ALL
SELECT 'clean_timely_effective_care', 'score_tier',
       LOWER(TRIM(score_tier)), COUNT(DISTINCT score_tier), GROUP_CONCAT(DISTINCT score_tier)
FROM clean_timely_effective_care WHERE score_tier IS NOT NULL
GROUP BY LOWER(TRIM(score_tier)) HAVING COUNT(DISTINCT score_tier) > 1;