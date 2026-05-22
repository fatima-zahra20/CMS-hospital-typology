DROP TABLE IF EXISTS clean_timely_effective_care;

CREATE TABLE clean_timely_effective_care AS
SELECT
    NULLIF(TRIM("Facility ID"), '')                                  AS facility_id,
    NULLIF(TRIM("Condition"),    '')                                 AS condition,
    NULLIF(TRIM("Measure ID"),   '')                                 AS measure_id,
    NULLIF(TRIM("Measure Name"), '')                                 AS measure_name,
    NULLIF(TRIM("Footnote"),     '')                                 AS footnote,
    
    -- Score numeric: only set when score looks numeric
    CASE 
        WHEN TRIM("Score") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        WHEN LOWER(TRIM("Score")) IN ('low', 'medium', 'high', 'very low', 'very high') THEN NULL
        ELSE CAST("Score" AS REAL)
    END                                                               AS score,
    
    -- Score tier: only set when CMS reported a tier
    CASE 
        WHEN LOWER(TRIM("Score")) IN ('low', 'medium', 'high', 'very low', 'very high') 
        THEN LOWER(TRIM("Score"))
        ELSE NULL
    END                                                               AS score_tier,
    
    -- Sample: null-safe CAST to INTEGER
    CASE 
        WHEN TRIM("Sample") IN ('', 'Not Available', 'Not Applicable') THEN NULL
        ELSE CAST("Sample" AS INTEGER)
    END                                                               AS sample,
    
    -- Dates: MM/DD/YYYY → YYYY-MM-DD
    CASE
        WHEN "Start Date" IS NULL OR TRIM("Start Date") = '' THEN NULL
        ELSE substr("Start Date", 7, 4) || '-' || substr("Start Date", 1, 2) || '-' || substr("Start Date", 4, 2)
    END                                                               AS start_date,
    
    CASE
        WHEN "End Date" IS NULL OR TRIM("End Date") = '' THEN NULL
        ELSE substr("End Date", 7, 4) || '-' || substr("End Date", 1, 2) || '-' || substr("End Date", 4, 2)
    END                                                               AS end_date
    
FROM stg_timely_effective_care;

SELECT COUNT(*) AS row_count FROM clean_timely_effective_care;