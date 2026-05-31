-- Direction lookup for every (measure_dataset, measure_id) pair in the
-- score tables. Lets dashboards consistently display percentile such that
-- "top of cluster" = "best performer" regardless of underlying direction.
--
-- direction = 'lower_better':  lower measure_value is better; rank 1 = best
-- direction = 'higher_better': higher measure_value is better; rank N = best
--
-- For higher-better measures, downstream display layer flips the percentile:
--   display_pct = CASE WHEN direction='higher_better' THEN 100 - cluster_pct
--                                                    ELSE cluster_pct END
-- so a "1st percentile" displayed value always means top performer.

DROP TABLE IF EXISTS model_measure_lookup;
CREATE TABLE model_measure_lookup (
    measure_dataset TEXT NOT NULL,
    measure_id      TEXT NOT NULL,
    direction       TEXT NOT NULL CHECK(direction IN ('lower_better', 'higher_better')),
    display_name    TEXT,
    PRIMARY KEY (measure_dataset, measure_id)
);

-- ============================================================
-- readmissions_and_deaths (20 measures, all lower-better)
-- PSIs are adverse event rates; MORT_* are 30-day mortality rates;
-- COMP_HIP_KNEE is complication rate; Hybrid_HWM is hospital-wide mortality.
-- ============================================================
INSERT INTO model_measure_lookup VALUES
    ('readmissions_and_deaths', 'COMP_HIP_KNEE', 'lower_better', 'Hip/Knee Complication Rate'),
    ('readmissions_and_deaths', 'Hybrid_HWM',    'lower_better', 'Hospital-Wide All-Cause Mortality (Hybrid)'),
    ('readmissions_and_deaths', 'MORT_30_AMI',   'lower_better', '30-day Mortality, AMI'),
    ('readmissions_and_deaths', 'MORT_30_CABG',  'lower_better', '30-day Mortality, CABG'),
    ('readmissions_and_deaths', 'MORT_30_COPD',  'lower_better', '30-day Mortality, COPD'),
    ('readmissions_and_deaths', 'MORT_30_HF',    'lower_better', '30-day Mortality, Heart Failure'),
    ('readmissions_and_deaths', 'MORT_30_PN',    'lower_better', '30-day Mortality, Pneumonia'),
    ('readmissions_and_deaths', 'MORT_30_STK',   'lower_better', '30-day Mortality, Stroke'),
    ('readmissions_and_deaths', 'PSI_03',        'lower_better', 'PSI 03 - Pressure Ulcer Rate'),
    ('readmissions_and_deaths', 'PSI_04',        'lower_better', 'PSI 04 - Death Rate Among Surgical Inpatients'),
    ('readmissions_and_deaths', 'PSI_06',        'lower_better', 'PSI 06 - Iatrogenic Pneumothorax Rate'),
    ('readmissions_and_deaths', 'PSI_08',        'lower_better', 'PSI 08 - In-Hospital Fall with Hip Fracture'),
    ('readmissions_and_deaths', 'PSI_09',        'lower_better', 'PSI 09 - Perioperative Hemorrhage/Hematoma'),
    ('readmissions_and_deaths', 'PSI_10',        'lower_better', 'PSI 10 - Postoperative Acute Kidney Injury'),
    ('readmissions_and_deaths', 'PSI_11',        'lower_better', 'PSI 11 - Postoperative Respiratory Failure'),
    ('readmissions_and_deaths', 'PSI_12',        'lower_better', 'PSI 12 - Perioperative PE/DVT'),
    ('readmissions_and_deaths', 'PSI_13',        'lower_better', 'PSI 13 - Postoperative Sepsis'),
    ('readmissions_and_deaths', 'PSI_14',        'lower_better', 'PSI 14 - Postoperative Wound Dehiscence'),
    ('readmissions_and_deaths', 'PSI_15',        'lower_better', 'PSI 15 - Abdominopelvic Accidental Puncture'),
    ('readmissions_and_deaths', 'PSI_90',        'lower_better', 'PSI 90 - Patient Safety/Adverse Events Composite');

-- ============================================================
-- medicare_spending (22 measures, all lower-better)
-- Less Medicare spending per episode = more efficient.
-- measure_id is already descriptive (period | claim_type); display_name kept simple.
-- ============================================================
INSERT INTO model_measure_lookup
SELECT DISTINCT
    'medicare_spending' AS measure_dataset,
    measure_id,
    'lower_better' AS direction,
    'MSPB: ' || measure_id AS display_name
FROM model_scores_medicare_spending;

-- ============================================================
-- healthcare_infections (6 measures, all lower-better)
-- SIRs lower than 1.0 = fewer infections than expected.
-- ============================================================
INSERT INTO model_measure_lookup VALUES
    ('healthcare_infections', 'HAI_1_SIR', 'lower_better', 'CLABSI - Central Line Bloodstream Infection'),
    ('healthcare_infections', 'HAI_2_SIR', 'lower_better', 'CAUTI - Catheter-Associated UTI'),
    ('healthcare_infections', 'HAI_3_SIR', 'lower_better', 'SSI - Colon Surgery'),
    ('healthcare_infections', 'HAI_4_SIR', 'lower_better', 'SSI - Abdominal Hysterectomy'),
    ('healthcare_infections', 'HAI_5_SIR', 'lower_better', 'MRSA Bacteremia'),
    ('healthcare_infections', 'HAI_6_SIR', 'lower_better', 'C. difficile Infection');

-- ============================================================
-- hcahps_patient_survey (8 measures, all higher-better)
-- Linear-mean composite scores; higher = better satisfaction.
-- ============================================================
INSERT INTO model_measure_lookup VALUES
    ('hcahps_patient_survey', 'H_CLEAN_LINEAR_SCORE',      'higher_better', 'Cleanliness of Hospital Environment'),
    ('hcahps_patient_survey', 'H_COMP_1_LINEAR_SCORE',     'higher_better', 'Communication with Nurses'),
    ('hcahps_patient_survey', 'H_COMP_2_LINEAR_SCORE',     'higher_better', 'Communication with Doctors'),
    ('hcahps_patient_survey', 'H_COMP_5_LINEAR_SCORE',     'higher_better', 'Communication about Medicines'),
    ('hcahps_patient_survey', 'H_COMP_6_LINEAR_SCORE',     'higher_better', 'Discharge Information'),
    ('hcahps_patient_survey', 'H_HSP_RATING_LINEAR_SCORE', 'higher_better', 'Overall Hospital Rating'),
    ('hcahps_patient_survey', 'H_QUIET_LINEAR_SCORE',      'higher_better', 'Quietness of Hospital Environment'),
    ('hcahps_patient_survey', 'H_RECMND_LINEAR_SCORE',     'higher_better', 'Willingness to Recommend Hospital');

-- ============================================================
-- unplanned_visits (14 measures, all lower-better)
-- EDAC = excess days in acute care; READM_30_* = readmission rates;
-- OP_3*/Hybrid_HWR = post-procedure visit rates.
-- ============================================================
INSERT INTO model_measure_lookup VALUES
    ('unplanned_visits', 'EDAC_30_AMI',       'lower_better', 'Excess Days in Acute Care, AMI'),
    ('unplanned_visits', 'EDAC_30_HF',        'lower_better', 'Excess Days in Acute Care, Heart Failure'),
    ('unplanned_visits', 'EDAC_30_PN',        'lower_better', 'Excess Days in Acute Care, Pneumonia'),
    ('unplanned_visits', 'Hybrid_HWR',        'lower_better', 'Hospital-Wide All-Cause Readmission (Hybrid)'),
    ('unplanned_visits', 'OP_32',             'lower_better', 'Unplanned Visits After Outpatient Colonoscopy'),
    ('unplanned_visits', 'OP_35_ADM',         'lower_better', 'Hospital Admissions After Outpatient Chemotherapy'),
    ('unplanned_visits', 'OP_35_ED',          'lower_better', 'ED Visits After Outpatient Chemotherapy'),
    ('unplanned_visits', 'OP_36',             'lower_better', 'Hospital Visits After Outpatient Surgery'),
    ('unplanned_visits', 'READM_30_AMI',      'lower_better', '30-day Readmission, AMI'),
    ('unplanned_visits', 'READM_30_CABG',     'lower_better', '30-day Readmission, CABG'),
    ('unplanned_visits', 'READM_30_COPD',     'lower_better', '30-day Readmission, COPD'),
    ('unplanned_visits', 'READM_30_HF',       'lower_better', '30-day Readmission, Heart Failure'),
    ('unplanned_visits', 'READM_30_HIP_KNEE', 'lower_better', '30-day Readmission, Hip/Knee'),
    ('unplanned_visits', 'READM_30_PN',       'lower_better', '30-day Readmission, Pneumonia');

-- ============================================================
-- timely_effective_care (24 measures, MIXED direction)
-- Most are compliance % (higher better); HH_*, OP_18*, OP_22 are
-- adverse-rate or time measures (lower better);
-- SAFE_USE_OF_OPIOIDS measures unsafe concurrent prescribing (lower better).
-- ============================================================
INSERT INTO model_measure_lookup VALUES
    -- Hospital Harm measures: adverse-event rates, lower-better
    ('timely_effective_care', 'HH_HYPER',            'lower_better',  'Hospital Harm - Severe Hyperglycemia'),
    ('timely_effective_care', 'HH_HYPO',             'lower_better',  'Hospital Harm - Severe Hypoglycemia'),
    ('timely_effective_care', 'HH_ORAE',             'lower_better',  'Hospital Harm - Opioid-Related Adverse Events'),
    -- ED throughput times (minutes), lower-better
    ('timely_effective_care', 'OP_18a',              'lower_better',  'ED Median Time, Subgroup a'),
    ('timely_effective_care', 'OP_18b',              'lower_better',  'ED Median Time, Subgroup b'),
    ('timely_effective_care', 'OP_18c',              'lower_better',  'ED Median Time, Subgroup c'),
    ('timely_effective_care', 'OP_18d',              'lower_better',  'ED Median Time, Subgroup d'),
    -- ED quality: patients leaving without being seen, lower-better
    ('timely_effective_care', 'OP_22',               'lower_better',  'ED Patients Who Left Without Being Seen'),
    -- Safe Use of Opioids: measures UNSAFE concurrent prescribing rate, lower-better
    ('timely_effective_care', 'SAFE_USE_OF_OPIOIDS', 'lower_better',  'Unsafe Concurrent Opioid Prescribing Rate'),
    -- Compliance % measures, higher-better
    ('timely_effective_care', 'IMM_3',               'higher_better', 'Healthcare Personnel Influenza Vaccination'),
    ('timely_effective_care', 'OP_23',               'higher_better', 'Stroke Imaging Within 45 Min of ED Arrival'),
    ('timely_effective_care', 'OP_29',               'higher_better', 'Appropriate Follow-up for Polyp Surveillance'),
    ('timely_effective_care', 'OP_31',               'higher_better', 'Cataract Surgery: Improvement in Visual Function'),
    ('timely_effective_care', 'OP_40',               'higher_better', 'Outpatient Compliance Measure (OP_40)'),
    ('timely_effective_care', 'SEP_1',               'higher_better', 'Severe Sepsis and Septic Shock Management Bundle'),
    ('timely_effective_care', 'SEP_SH_3HR',          'higher_better', 'Septic Shock 3-Hour Bundle'),
    ('timely_effective_care', 'SEP_SH_6HR',          'higher_better', 'Septic Shock 6-Hour Bundle'),
    ('timely_effective_care', 'SEV_SEP_3HR',         'higher_better', 'Severe Sepsis 3-Hour Bundle'),
    ('timely_effective_care', 'SEV_SEP_6HR',         'higher_better', 'Severe Sepsis 6-Hour Bundle'),
    ('timely_effective_care', 'STK_02',              'higher_better', 'Stroke: Discharged on Antithrombotic Therapy'),
    ('timely_effective_care', 'STK_03',              'higher_better', 'Stroke: Anticoagulation for Afib/Flutter'),
    ('timely_effective_care', 'STK_05',              'higher_better', 'Stroke: Antithrombotic by End of Hospital Day 2'),
    ('timely_effective_care', 'VTE_1',               'higher_better', 'VTE Prophylaxis'),
    ('timely_effective_care', 'VTE_2',               'higher_better', 'ICU VTE Prophylaxis');