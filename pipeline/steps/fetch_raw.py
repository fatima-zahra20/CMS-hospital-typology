# pipeline/steps/fetch_raw.py
import time
import requests
import pandas as pd
from datetime import date

from pipeline.config import RAW_DIR, CMS_METASTORE, CMS_DATASETS
from pipeline.logger import get_logger

log = get_logger(__name__)


def get_csv_url(dataset_id: str) -> str:
    """Look up the latest CSV download URL from the dataset's metadata."""
    r = requests.get(f"{CMS_METASTORE}/{dataset_id}", timeout=30)
    r.raise_for_status()
    meta = r.json()
    for dist in meta.get("distribution", []):
        url = dist.get("downloadURL", "")
        if url.lower().endswith(".csv"):
            return url
    raise ValueError(f"No CSV distribution found for {dataset_id}")


def fetch_dataset(dataset_id: str, max_retries: int = 3) -> pd.DataFrame:
    """Fetch a CMS dataset by downloading its published CSV directly."""
    csv_url = get_csv_url(dataset_id)
    for attempt in range(max_retries):
        try:
            return pd.read_csv(csv_url, low_memory=False)
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            wait = 2 ** attempt
            log.warning(f"  attempt {attempt+1} failed ({e}), retrying in {wait}s...")
            time.sleep(wait)


def run():
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    snapshot = date.today().strftime("%Y%m%d")
    log.info(f"fetch_raw started — snapshot {snapshot}")

    results = {}
    for name, dataset_id in CMS_DATASETS.items():
        out_path = RAW_DIR / f"{name}_{snapshot}.csv"

        if out_path.exists():
            log.info(f"{name:<28} already pulled today - skipping")
            results[name] = "skipped"
            continue

        log.info(f"{name:<28} ({dataset_id})  fetching...")
        try:
            df = fetch_dataset(dataset_id)
            df.to_csv(out_path, index=False)
            log.info(f"{name:<28} {len(df):>7,} rows → {out_path.name}")
            results[name] = len(df)
        except Exception as e:
            log.error(f"{name:<28} FAILED: {e}")
            results[name] = f"error: {e}"
            raise  # halt pipeline on fetch failure

    log.info("fetch_raw complete")
    return results