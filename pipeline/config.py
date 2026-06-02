# pipeline/config.py
from pathlib import Path

# Project root
ROOT = Path(__file__).resolve().parent.parent

# Database
DB_PATH = ROOT / "data" / "hospital_typology.db"

# Raw data
RAW_DIR   = ROOT / "data" / "raw"
IPPS_DIR  = RAW_DIR / "fy_2026_ipps_final_rule_impact_file"
IPPS_FILE = IPPS_DIR / "FY 2026 IPPS Final Rule Impact File.txt"
RUCA_FILE = RAW_DIR / "RUCA-codes-2020-zipcode.csv"

# Output
AGG_OUTPUT_DIR = ROOT / "agg_output"

# SQL script folders
CLEAN_COLS_DIR     = ROOT / "data_cleaning" / "01_standardize_columns"
CLEAN_ROWS_DIR     = ROOT / "data_cleaning" / "02_standardize_t_rows"
CHECKS_DIR         = ROOT / "data_cleaning" / "03_checks"
COHORT_DIR         = ROOT / "data_cleaning" / "04_cohort"
MODEL_FEATURES_DIR = ROOT / "data_processing" / "model_features"
AGG_SQL_DIR    = ROOT / "agg_output" / "sql"
AGG_OUTPUT_DIR = ROOT / "agg_output" / "csv_output"

# Logs
LOGS_DIR = ROOT / "logs"

# CMS API
CMS_METASTORE = "https://data.cms.gov/provider-data/api/1/metastore/schemas/dataset/items"
CMS_DATASETS = {
    "hospital_general_info":   "xubh-q36u",
    "readmissions_and_deaths": "ynj2-r877",
    "medicare_spending":       "nrth-mfg3",
    "healthcare_infections":   "77hc-ibv8",
    "hcahps_patient_survey":   "dgck-syfz",
    "unplanned_visits":        "632h-zaca",
    "timely_effective_care":   "yv7e-xc69",
}

# Ordered list for staging loop
DATASETS = list(CMS_DATASETS.keys())

# Clustering
CLUSTER_K            = 7
CLUSTER_RANDOM_STATE = 42
CLUSTER_N_INIT       = 10

# Data quality thresholds
STAGING_ROW_BOUNDS = {
    "stg_hospital_general_info":   (5_000,  6_000),    # 5,432 
    "stg_readmissions_and_deaths": (90_000, 100_000),  # 95,840
    "stg_medicare_spending":       (60_000,  70_000),  # 63,646
    "stg_healthcare_infections":   (160_000, 185_000), # 172,512
    "stg_hcahps_patient_survey":   (300_000, 350_000), # 325,856
    "stg_unplanned_visits":        (60_000,  75_000),  # 67,088
    "stg_timely_effective_care":   (130_000, 145_000), # 138,173
}

CLEANED_ROW_BOUNDS = {
    "clean_cohort":     (5_000, 6_000),  # full table including excluded hospitals ( clean_cohort has 3,115 included + 2,317 excluded )
    "clean_structural": (3_000, 3_200),  
}

COHORT_EXPECTED = 3_115