# pipeline/steps/model.py
import sqlite3
import numpy as np
import pandas as pd
from pathlib import Path
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

from pipeline.config import (
    DB_PATH,
    MODEL_FEATURES_DIR,
    CLUSTER_K,
    CLUSTER_RANDOM_STATE,
    CLUSTER_N_INIT,
)
from pipeline.logger import get_logger

log = get_logger(__name__)


def run_sql_folder(folder, con):
    """Execute all .sql files in a folder in filename order."""
    sql_files = sorted(Path(folder).glob("*.sql"))
    if not sql_files:
        log.warning(f"No SQL files found in {folder}")
        return
    for sql_file in sql_files:
        log.info(f"  running {sql_file.name}")
        sql = sql_file.read_text(encoding="utf-8")
        con.executescript(sql)
        con.commit()


def run():
    log.info("model started")
    con = sqlite3.connect(DB_PATH)

    try:
        # Step 4a: run feature SQL scripts 
        log.info("Layer 4 — building model features")
        run_sql_folder(MODEL_FEATURES_DIR, con)

        # Step 4b: load clean_structural for clustering 
        log.info("Layer 4 — loading clean_structural for clustering")
        df = pd.read_sql("SELECT * FROM clean_structural", con)
        log.info(f"  loaded {len(df)} hospitals × {len(df.columns)} cols")

        # Step 4c: derive features (match notebook exactly) 
        df["log_bed_count"] = np.log(df["bed_count"].fillna(0).replace(0, 1))
        df["is_metro"]      = (df["urbanicity_bucket"] == "metro").astype(int)
        df["is_micro"]      = (df["urbanicity_bucket"] == "micro").astype(int)
        df["is_small_town"] = (df["urbanicity_bucket"] == "small_town").astype(int)
        df["is_rural"]      = (df["urbanicity_bucket"] == "rural").astype(int)

        #  Step 4d: prepare feature matrix
        FEATURE_COLS = [
            "log_bed_count",
            "cmi",
            "is_teaching",
            "safety_net_burden",
            "is_metro",
            "is_micro",
            "is_small_town",
            "is_rural",
        ]

        missing = [c for c in FEATURE_COLS if c not in df.columns]
        if missing:
            raise ValueError(f"Missing feature columns: {missing}")

        X = df[FEATURE_COLS].fillna(0).values
        ccns = df["ccn"].values
        log.info(f"  feature matrix shape: {X.shape}")

        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)

        # Step 4e: fit KMeans (your exact parameters)
        log.info(f"Layer 4 — KMeans k={CLUSTER_K}")
        km = KMeans(
            n_clusters=CLUSTER_K,
            random_state=CLUSTER_RANDOM_STATE,
            n_init=CLUSTER_N_INIT,
        )
        cluster_ids = km.fit_predict(X_scaled)

        #  Step 4f: write model_hospital_clusters to SQLite 
        clusters_df = pd.DataFrame({
            "ccn":        ccns,
            "cluster_id": cluster_ids,
        })
        clusters_df.to_sql(
            "model_hospital_clusters", con,
            if_exists="replace", index=False
        )
        log.info(f"  wrote model_hospital_clusters ({len(clusters_df)} rows)")
        log.info(
            f"  cluster distribution:\n"
            f"{clusters_df['cluster_id'].value_counts().sort_index().to_string()}"
        )

        # Step 4g: run scoring SQL scripts 
        log.info("Layer 4 — running scoring SQL scripts")
        run_sql_folder(MODEL_FEATURES_DIR, con)

    finally:
        con.close()
        log.info("model complete")