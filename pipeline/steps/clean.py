# pipeline/steps/clean.py
import sqlite3
from pathlib import Path

from pipeline.config import (
    DB_PATH,
    CLEAN_COLS_DIR,
    CLEAN_ROWS_DIR,
    CHECKS_DIR,
    COHORT_DIR,
)
from pipeline.logger import get_logger

log = get_logger(__name__)


def run_sql_folder(folder: Path, con: sqlite3.Connection) -> None:
    """Execute all .sql files in a folder in filename order."""
    sql_files = sorted(folder.glob("*.sql"))
    if not sql_files:
        log.warning(f"No SQL files found in {folder}")
        return
    for sql_file in sql_files:
        log.info(f"  running {sql_file.name}")
        sql = sql_file.read_text(encoding="utf-8")
        con.executescript(sql)
        con.commit()


def run():
    log.info("clean started")
    con = sqlite3.connect(DB_PATH)

    try:
        # 01 — standardize columns
        log.info("Layer 3a - column standardization")
        run_sql_folder(CLEAN_COLS_DIR, con)

        # 02 — standardize rows
        log.info("Layer 3a - row standardization")
        run_sql_folder(CLEAN_ROWS_DIR, con)

        # 03 — checks (category, orphan, range)
        log.info("Layer 3 - checks")
        for subfolder in sorted(CHECKS_DIR.iterdir()):
            if subfolder.is_dir():
                log.info(f"  checks subfolder: {subfolder.name}")
                run_sql_folder(subfolder, con)

        # 04 — cohort
        log.info("Layer 3b - cohort criteria")
        run_sql_folder(COHORT_DIR, con)

    finally:
        con.close()
        log.info("clean complete")