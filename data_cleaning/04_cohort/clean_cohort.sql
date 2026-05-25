DROP TABLE IF EXISTS clean_cohort;
CREATE TABLE clean_cohort AS
SELECT 
    facility_id,
    hospital_name,
    state,
    zip_code,
    hospital_type,
    ownership,
    CASE WHEN hospital_type = 'Acute Care Hospitals' THEN 1 ELSE 0 END AS included,
    CASE
        WHEN hospital_type = 'Critical Access Hospitals'             THEN 'CAH'
        WHEN hospital_type = 'Childrens'                             THEN 'Pediatric specialty'
        WHEN hospital_type = 'Psychiatric'                           THEN 'Psychiatric specialty'
        WHEN hospital_type = 'Acute Care - Department of Defense'    THEN 'DoD facility'
        WHEN hospital_type = 'Acute Care - Veterans Administration'  THEN 'VA facility'
        WHEN hospital_type = 'Rural Emergency Hospital'              THEN 'Outpatient-only REH'
        WHEN hospital_type = 'Long-term'                             THEN 'LTCH'
        ELSE NULL
    END AS exclusion_reason
FROM clean_hospital_general_info;