{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "276491b0-82da-485d-a83c-aa250a040f3c",
   "metadata": {},
   "source": [
    "## Data Pipeline Architecture\n",
    "\n",
    "The project uses a layered data architecture (also known as a medallion architecture) to keep raw data, transformations, and analytical outputs cleanly separated. Each layer is reproducible from the previous one — when CMS publishes new data or methodology decisions change, only the affected layer needs to be rebuilt, and downstream layers regenerate from it.\n",
    "\n",
    "\n",
    "### Layer 1 — Raw\n",
    "\n",
    "Direct pulls from the CMS Provider Data API. Files are saved with snapshot dates in their filenames (e.g., `hospital_general_info_20260520.csv`) so historical pulls remain alongside new ones; nothing is overwritten. This layer is the source of truth and is never edited by hand. Lives in `data/raw/`.\n",
    "\n",
    "\n",
    "### Layer 2 — Staging\n",
    "\n",
    "Programmatic standardization with no analytical decisions: column renaming for consistency, type corrections, null standardization. The goal is to make the raw data usable, not to clean it. Lives in SQLite as `stg_*` tables.\n",
    "\n",
    "\n",
    "### Layer 3 — Cleaned\n",
    "\n",
    "Analytical cleaning: outlier handling, hospital inclusion and exclusion criteria, derivation of structural variables (urbanicity from ZIP via RUCA codes, hospital size buckets, and so on). Every transformation in this layer is documented in both code comments and this methodology document. Lives in SQLite as `clean_*` tables.\n",
    "\n",
    "\n",
    "### Layer 4 — Modeled\n",
    "\n",
    "Cluster assignments and within-cluster scores. Hospitals receive a cluster ID based on structural variables (Python, scikit-learn); within each cluster, performance metrics are calculated relative to peer hospitals (SQL window functions). Lives in SQLite as `model_*` tables.\n",
    "\n",
    "### Layer 5 — Output\n",
    "\n",
    "\n",
    "Power BI-ready aggregated tables and summary CSVs for the report. Generated from SQL on top of the modeled layer. Lives in `agg_output/`.\n",
    "\n",
    "### Design principles\n",
    "\n",
    "\n",
    "Three principles hold the architecture together. First, layer separation: each layer has one responsibility, and mixing concerns across layers creates technical debt and undermines reproducibility. Second, reproducibility: each layer is fully regenerable from the previous one, which means methodology changes never require starting over. Third, snapshot dating: raw files include the pull date in their filename so historical CMS snapshots remain alongside new ones — the filename itself is the version control for the data layer.\n",
    "\n",
    "### Note on prior work\n",
    "\n",
    "Cleaned CSV files from the original `U.S.-Hospital-Quality-Spending-Readmission-Risk-Analyzer` project are kept as reference only. They were produced by an earlier cleaning pipeline whose methodology decisions predate the typology framework. They are useful for sanity-checking new outputs (row counts, distributions) but are never loaded into the typology pipeline."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "cb115146-6ad4-4124-9e41-319a1db582eb",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python [conda env:base] *",
   "language": "python",
   "name": "conda-base-py"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.13.9"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
