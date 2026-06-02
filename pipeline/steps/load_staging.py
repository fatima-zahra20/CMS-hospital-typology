# pipeline/steps/load_staging.py
import sqlite3
import pandas as pd
from pathlib import Path

from pipeline.config import RAW_DIR, DB_PATH, IPPS_FILE, RUCA_FILE, DATASETS
from pipeline.logger import get_logger

log = get_logger(__name__)


def latest_snapshot(name: str) -> str | None:
    """Find the most recent snapshot date for a given dataset."""
    files = sorted(RAW_DIR.glob(f"{name}_*.csv"))
    if not files:
        return None
    return files[-1].stem.split("_")[-1]


def run():
    log.info("load_staging started")
    con = sqlite3.connect(DB_PATH)

    try:
        # CMS datasets 
        for name in DATASETS:
            snapshot = latest_snapshot(name)
            if snapshot is None:
                log.warning(f"  No file found for {name} — skipping")
                continue
            csv_path = RAW_DIR / f"{name}_{snapshot}.csv"
            table    = f"stg_{name}"
            df = pd.read_csv(csv_path, low_memory=False, dtype={"Facility ID": str})
            df.to_sql(table, con, if_exists="replace", index=False)
            log.info(f"{table:<38} {len(df):>7,} rows × {len(df.columns)} cols  ({snapshot})")

        # IPPS Impact File 
        cols_to_keep = {
            "Provider Number":       "ccn",
            "Beds":                  "bed_count",
            "TACMIV43":              "cmi",
            "Resident to Bed Ratio": "resident_to_bed_ratio",
            "DSHPCT":                "dsh_pct",
            "URGEO":                 "urban_rural_geo",
        }
        df_ipps = None
        for encoding in ["utf-8", "cp1252", "latin-1"]:
            try:
                df_ipps = pd.read_csv(
                    IPPS_FILE, sep="\t", encoding=encoding, skiprows=1
                )
                log.info(f"IPPS loaded with encoding='{encoding}': {df_ipps.shape}")
                break
            except UnicodeDecodeError:
                continue
        if df_ipps is None:
            raise ValueError("Could not decode IPPS file with any known encoding")

        stg_ipps = df_ipps[list(cols_to_keep)].rename(columns=cols_to_keep)
        stg_ipps.to_sql("stg_ipps", con, if_exists="replace", index=False)
        log.info(f"stg_ipps{'':<30} {len(stg_ipps):>7,} rows")

        # RUCA codes 
        cols_ruca = {
            "ZIPCode":     "zip_code",
            "State":       "state",
            "ZIPCodeType": "zip_code_type",
            "PrimaryRUCA": "primary_ruca",
        }
        df_ruca = None
        for encoding in ["utf-8", "cp1252", "latin-1"]:
            try:
                df_ruca = pd.read_csv(RUCA_FILE, encoding=encoding)
                log.info(f"RUCA loaded with encoding='{encoding}': {df_ruca.shape}")
                break
            except UnicodeDecodeError:
                continue
        if df_ruca is None:
            raise ValueError("Could not decode RUCA file with any known encoding")

        stg_ruca = df_ruca[list(cols_ruca)].rename(columns=cols_ruca)
        stg_ruca.to_sql("stg_ruca", con, if_exists="replace", index=False)
        log.info(f"stg_ruca{'':<30} {len(stg_ruca):>7,} rows")

    finally:
        con.close()
        log.info(f"load_staging complete — database: {DB_PATH}")