SELECT 'hospital_general_info' AS table_name, COUNT(*) AS row_count FROM stg_hospital_general_info
UNION ALL SELECT 'readmissions_and_deaths', COUNT(*) FROM stg_readmissions_and_deaths
UNION ALL SELECT 'medicare_spending',       COUNT(*) FROM stg_medicare_spending
UNION ALL SELECT 'healthcare_infections',   COUNT(*) FROM stg_healthcare_infections
UNION ALL SELECT 'hcahps_patient_survey',   COUNT(*) FROM stg_hcahps_patient_survey
UNION ALL SELECT 'unplanned_visits',        COUNT(*) FROM stg_unplanned_visits
UNION ALL SELECT 'timely_effective_care',   COUNT(*) FROM stg_timely_effective_care;