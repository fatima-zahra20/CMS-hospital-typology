# pipeline/run_pipeline.py
from pipeline import notifier
import sys
from datetime import datetime
from pathlib import Path

from pipeline.logger import get_logger
from pipeline.config import LOGS_DIR

from pipeline.steps  import fetch_raw, load_staging, clean, model, aggregate
from pipeline.checks import staging_checks, cleaned_checks

log = get_logger(__name__)


def write_status(status: str, message: str = "") -> None:
    """Write last_run_status.txt so you can check if the pipeline succeeded."""
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    status_file = Path(__file__).resolve().parent.parent / "last_run_status.txt"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    status_file.write_text(
        f"status:    {status}\n"
        f"timestamp: {timestamp}\n"
        f"message:   {message}\n"
    )


def run():
    log.info("=" * 60)
    log.info("CMS Hospital Typology Pipeline - run started")
    log.info("=" * 60)

    steps = [
        ("fetch_raw",        fetch_raw.run),
        ("staging_checks",   staging_checks.run),
        ("load_staging",     load_staging.run),
        ("cleaned_checks",   cleaned_checks.run),
        ("clean",            clean.run),
        ("model",            model.run),
        ("aggregate",        aggregate.run),
    ]

    for step_name, step_fn in steps:
        log.info(f"── {step_name} starting")
        try:
            step_fn()
            log.info(f"── {step_name} done")
        except Exception as e:
            log.error(f"── {step_name} FAILED: {e}", exc_info=True)
            write_status("FAILED", f"step={step_name} error={e}")
            notifier.send_failure(step_name, str(e))
            sys.exit(1)

    write_status("SUCCESS")
    notifier.send_success()
    log.info("=" * 60)
    log.info("Pipeline complete - all steps passed")
    log.info("=" * 60)


if __name__ == "__main__":
    run()