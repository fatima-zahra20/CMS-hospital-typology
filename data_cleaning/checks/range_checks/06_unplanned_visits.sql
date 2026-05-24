-- Full range check including CI bounds, with EDAC carve-out
SELECT COUNT(*) AS unusual_count
FROM clean_unplanned_visits
WHERE (denominator                 IS NOT NULL AND denominator                 < 0)
   OR (number_of_patients          IS NOT NULL AND number_of_patients          < 0)
   OR (number_of_patients_returned IS NOT NULL AND number_of_patients_returned < 0)
   OR (score                       IS NOT NULL 
       AND score                   < 0 
       AND measure_id NOT IN ('EDAC_30_PN', 'EDAC_30_HF', 'EDAC_30_AMI'))
   OR (lower_estimate              IS NOT NULL 
       AND lower_estimate          < 0 
       AND measure_id NOT IN ('EDAC_30_PN', 'EDAC_30_HF', 'EDAC_30_AMI'))
   OR (higher_estimate             IS NOT NULL 
       AND higher_estimate         < 0 
       AND measure_id NOT IN ('EDAC_30_PN', 'EDAC_30_HF', 'EDAC_30_AMI'));