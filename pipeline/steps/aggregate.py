# pipeline/steps/aggregate.py
import sqlite3
import pandas as pd
from pathlib import Path

from pipeline.config import DB_PATH, AGG_OUTPUT_DIR, AGG_SQL_DIR
from pipeline.logger import get_logger

log = get_logger(__name__)


def run_sql_file(sql_file: Path, con: sqlite3.Connection) -> None:
    """Execute a single SQL file."""
    log.info(f"  running {sql_file.name}")
    sql = sql_file.read_text(encoding="utf-8")
    con.executescript(sql)
    con.commit()


def export_to_csv(table_name: str, con: sqlite3.Connection) -> None:
    """Export a SQLite table to agg_output/ as a CSV file."""
    out_path = AGG_OUTPUT_DIR / f"{table_name}.csv"
    df = pd.read_sql(f"SELECT * FROM {table_name}", con)
    df.to_csv(out_path, index=False)
    log.info(f"  exported {table_name} → {out_path.name} ({len(df):,} rows)")


def run():
    log.info("aggregate started")
    AGG_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(DB_PATH)

    # Layer 5 output tables in build order
    AGG_TABLES = [
        "agg_hospital_scorecard",
        "agg_cluster_summary",
        "agg_measure_summary",
        "agg_geo_rollup",
    ]

    try:
        #  Run each Layer 5 SQL file 
        log.info("Layer 5 - building output tables")
        sql_files = sorted(AGG_SQL_DIR.glob("*.sql"))
        if not sql_files:
            log.warning(f"No SQL files found in {AGG_SQL_DIR}")
        for sql_file in sql_files:
            run_sql_file(sql_file, con)

        #  Export each table to CSV 
        log.info("Layer 5 - exporting to CSV")
        for table in AGG_TABLES:
            try:
                export_to_csv(table, con)
            except Exception as e:
                log.error(f"  failed to export {table}: {e}")
                raise

    finally:
        con.close()
        log.info(f"aggregate complete — outputs in {AGG_OUTPUT_DIR}")