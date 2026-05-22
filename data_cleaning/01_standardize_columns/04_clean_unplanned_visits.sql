DROP TABLE IF EXISTS clean_unplanned_visits;

CREATE TABLE clean_unplanned_visits AS
SELECT
    -- CCN: already TEXT and 6 digits, just trim/null defensively
    NULLIF(TRIM("Facility ID"), '')                AS facility_id,
    
    -- Categorical text columns: trim + empty-string → NULL
    NULLIF(TRIM("Measure ID"),            '')      AS measure_id,
    NULLIF(TRIM("Measure Name"),          '')      AS measure_name,
    NULLIF(NULLIF(TRIM("Compared to National"), ''), 'Not Available')   AS compared_to_national,
    NULLIF(TRIM("Footnote"),              '')      AS footnote,
    
    -- Numeric columns with suppressed strings: null-safe CAST to REAL
    CASE 
        WHEN TRIM("Denominator") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Denominator" AS INTEGER)
    END                                            AS denominator,
    
    CASE 
        WHEN TRIM("Score") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Score" AS REAL)
    END                                            AS score,
    
    CASE 
        WHEN TRIM("Lower Estimate") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Lower Estimate" AS REAL)
    END                                            AS lower_estimate,
    
    CASE 
        WHEN TRIM("Higher Estimate") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Higher Estimate" AS REAL)
    END                                            AS higher_estimate,
    
    -- Dates: convert MM/DD/YYYY → YYYY-MM-DD (ISO format for proper sorting)
    CASE
        WHEN "Start Date" IS NULL OR TRIM("Start Date") = '' THEN NULL
        ELSE substr("Start Date", 7, 4) || '-' || substr("Start Date", 1, 2) || '-' || substr("Start Date", 4, 2)
    END                                            AS start_date,
    
    CASE
        WHEN "End Date" IS NULL OR TRIM("End Date") = '' THEN NULL
        ELSE substr("End Date", 7, 4) || '-' || substr("End Date", 1, 2) || '-' || substr("End Date", 4, 2)
    END                                            AS end_date

FROM stg_unplanned_visits;

SELECT COUNT(*) AS row_count FROM clean_unplanned_visits;