DROP TABLE IF EXISTS clean_healthcare_infections;

CREATE TABLE clean_healthcare_infections AS
SELECT
    -- CCN: already TEXT and 6 digits, just trim/null defensively
    NULLIF(TRIM("Facility ID"), '')                AS facility_id,
    
    -- Categorical text columns
    NULLIF(TRIM("Measure ID"),            '')                       AS measure_id,
    NULLIF(TRIM("Measure Name"),          '')                       AS measure_name,
    NULLIF(NULLIF(TRIM("Compared to National"), ''), 'Not Available') AS compared_to_national,
    NULLIF(TRIM("Footnote"),              '')                       AS footnote,
    
    -- Score: null-safe CAST to REAL
    CASE 
        WHEN TRIM("Score") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Score" AS REAL)
    END                                            AS score,
    
    -- Dates: convert MM/DD/YYYY → YYYY-MM-DD
    CASE
        WHEN "Start Date" IS NULL OR TRIM("Start Date") = '' THEN NULL
        ELSE substr("Start Date", 7, 4) || '-' || substr("Start Date", 1, 2) || '-' || substr("Start Date", 4, 2)
    END                                            AS start_date,
    
    CASE
        WHEN "End Date" IS NULL OR TRIM("End Date") = '' THEN NULL
        ELSE substr("End Date", 7, 4) || '-' || substr("End Date", 1, 2) || '-' || substr("End Date", 4, 2)
    END                                            AS end_date
FROM stg_healthcare_infections;

SELECT COUNT(*) AS row_count FROM clean_healthcare_infections;