# pipeline/checks/cleaned_checks.py
import sqlite3

from pipeline.config import DB_PATH, CLEANED_ROW_BOUNDS, COHORT_EXPECTED
from pipeline.logger import get_logger

log = get_logger(__name__)


def run():
    log.info("cleaned_checks started")
    con = sqlite3.connect(DB_PATH)
    failures = []

    try:
        #  Row count bounds 
        for table, (min_rows, max_rows) in CLEANED_ROW_BOUNDS.items():
            count = con.execute(
                f"SELECT COUNT(*) FROM {table}"
            ).fetchone()[0]

            if count < min_rows or count > max_rows:
                msg = (
                    f"{table}: {count:,} rows — "
                    f"expected between {min_rows:,} and {max_rows:,}"
                )
                log.error(f"  FAIL {msg}")
                failures.append(msg)
            else:
                log.info(f"  OK   {table}: {count:,} rows")

        #  Cohort count drift alert (> 5% from known good) 
        cohort_count = con.execute(
            "SELECT COUNT(*) FROM clean_cohort WHERE included = 1"
        ).fetchone()[0]
        drift = abs(cohort_count - COHORT_EXPECTED) / COHORT_EXPECTED
        if drift > 0.05:
            msg = (
                f"clean_cohort: {cohort_count:,} included hospitals — "
                f"drifted {drift:.1%} from expected {COHORT_EXPECTED:,}"
            )
            log.error(f"  FAIL {msg}")
            failures.append(msg)
        else:
            log.info(
                f"  OK   clean_cohort: {cohort_count:,} included "
                f"(drift {drift:.1%} from expected)"
            )

        # No NULL ccn in clean_structural
        null_ccn = con.execute(
            "SELECT COUNT(*) FROM clean_structural WHERE ccn IS NULL"
        ).fetchone()[0]
        if null_ccn > 0:
            msg = f"clean_structural: {null_ccn:,} NULL ccn values"
            log.error(f"  FAIL {msg}")
            failures.append(msg)
        else:
            log.info("  OK   clean_structural: no NULL ccns")

        #  urbanicity_bucket only contains valid values 
        invalid_urban = con.execute("""
            SELECT COUNT(*) FROM clean_structural
            WHERE urbanicity_bucket NOT IN ('metro','micro','small_town','rural')
            AND urbanicity_bucket IS NOT NULL
        """).fetchone()[0]
        if invalid_urban > 0:
            msg = f"clean_structural: {invalid_urban:,} invalid urbanicity_bucket values"
            log.error(f"  FAIL {msg}")
            failures.append(msg)
        else:
            log.info("  OK   clean_structural: urbanicity_bucket values valid")

        #  safety_net_burden within [0, 1]
        out_of_range = con.execute("""
            SELECT COUNT(*) FROM clean_structural
            WHERE safety_net_burden < 0 OR safety_net_burden > 1.2
        """).fetchone()[0]
        if out_of_range > 0:
            msg = f"clean_structural: {out_of_range:,} safety_net_burden values outside [0,1]"
            log.error(f"  FAIL {msg}")
            failures.append(msg)
        else:
            log.info("  OK   clean_structural: safety_net_burden in range")

    finally:
        con.close()

    if failures:
        raise AssertionError(
            f"cleaned_checks failed with {len(failures)} issue(s):\n" +
            "\n".join(f"  - {f}" for f in failures)
        )

    log.info("cleaned_checks passed")