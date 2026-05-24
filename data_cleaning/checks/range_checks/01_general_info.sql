-- File: data_cleaning/checks/check_ranges_hospital_general_info.sql
-- Grain: one row per hospital
-- Each query should return 0 in a healthy state

-- 1. Hospital overall rating should be in [1, 5]
SELECT COUNT(*) AS bad_overall_rating
FROM clean_hospital_general_info
WHERE hospital_overall_rating IS NOT NULL
  AND hospital_overall_rating NOT BETWEEN 1 AND 5;

-- 2. All measure-group counts should be non-negative
SELECT COUNT(*) AS bad_counts
FROM clean_hospital_general_info
WHERE mort_group_measure_count          < 0
   OR count_facility_mort_measures      < 0
   OR count_mort_measures_better        < 0
   OR count_mort_measures_no_different  < 0
   OR count_mort_measures_worse         < 0
   OR safety_group_measure_count        < 0
   OR count_facility_safety_measures    < 0
   OR count_safety_measures_better      < 0
   OR count_safety_measures_no_different< 0
   OR count_safety_measures_worse       < 0
   OR readm_group_measure_count         < 0
   OR count_facility_readm_measures     < 0
   OR count_readm_measures_better       < 0
   OR count_readm_measures_no_different < 0
   OR count_readm_measures_worse        < 0
   OR pt_exp_group_measure_count        < 0
   OR count_facility_pt_exp_measures    < 0
   OR te_group_measure_count            < 0
   OR count_facility_te_measures        < 0;