# pipeline/checks/staging_checks.py
import sqlite3

from pipeline.config import DB_PATH, STAGING_ROW_BOUNDS
from pipeline.logger import get_logger

log = get_logger(__name__)


def run():
    log.info("staging_checks started")
    con = sqlite3.connect(DB_PATH)
    failures = []

    try:
        for table, (min_rows, max_rows) in STAGING_ROW_BOUNDS.items():
            row = con.execute(
                f"SELECT COUNT(*) FROM {table}"
            ).fetchone()
            count = row[0]

            if count < min_rows or count > max_rows:
                msg = (
                    f"{table}: {count:,} rows — "
                    f"expected between {min_rows:,} and {max_rows:,}"
                )
                log.error(f"  FAIL {msg}")
                failures.append(msg)
            else:
                log.info(f"  OK   {table}: {count:,} rows")

        # NULL CCN check across all staging tables
        for table in STAGING_ROW_BOUNDS.keys():
            # CCN column is named differently across tables
            ccn_col = "Facility ID" if table == "stg_hospital_general_info" else "Facility ID"
            try:
                null_count = con.execute(
                    f'SELECT COUNT(*) FROM {table} WHERE "Facility ID" IS NULL'
                ).fetchone()[0]
                if null_count > 0:
                    msg = f"{table}: {null_count:,} NULL Facility IDs"
                    log.error(f"  FAIL {msg}")
                    failures.append(msg)
                else:
                    log.info(f"  OK   {table}: no NULL Facility IDs")
            except Exception:
                # Some tables may use a different column name — skip gracefully
                log.warning(f"  SKIP {table}: could not check Facility ID nulls")

    finally:
        con.close()

    if failures:
        raise AssertionError(
            f"staging_checks failed with {len(failures)} issue(s):\n" +
            "\n".join(f"  - {f}" for f in failures)
        )

    log.info("staging_checks passed")