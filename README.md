# CMS-hospital-typology
production-quality pipeline:

- Reproducible API ingestion with snapshot-dated raw files
- Staging layer with type-safe loading
- 7 cleaned tables, fully normalized (no duplicated identity)
- Null-safe casting throughout (no silent "Not Available" : 0.0 bugs)
- Properly handled date formats, percentage symbols, leading zeros
- Defensive coding patterns (NULLIF chains, mutual-exclusion checks)
- Comprehensive post-cleaning diagnostics