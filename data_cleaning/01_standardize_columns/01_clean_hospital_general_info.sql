DROP TABLE IF EXISTS clean_hospital_general_info;
CREATE TABLE clean_hospital_general_info AS
SELECT
    -- Identifiers & location
    NULLIF(TRIM("Facility ID"),         '')  AS facility_id,
    NULLIF(TRIM("Facility Name"),       '')  AS hospital_name,
    NULLIF(TRIM("Address"),             '')  AS address,
    NULLIF(TRIM("City/Town"),           '')  AS city,
    NULLIF(TRIM("State"),               '')  AS state,
    NULLIF(TRIM("ZIP Code"),            '')  AS zip_code,        
    NULLIF(TRIM("County/Parish"),       '')  AS county,

    -- Hospital characteristics
    NULLIF(TRIM("Hospital Type"),       '')  AS hospital_type,
    NULLIF(TRIM("Hospital Ownership"),  '')  AS ownership,
    CASE 
        WHEN TRIM("Emergency Services") = 'Yes' THEN 1
        WHEN TRIM("Emergency Services") = 'No'  THEN 0
        ELSE NULL
    END AS has_emergency_services,

    -- Overall quality score (CMS composite, 1-5 stars)
    -- Note: integer cast needs double NULLIF to prevent 'Not Available' → 0 in SQLite
    CAST(NULLIF(NULLIF(TRIM("Hospital overall rating"), ''), 'Not Available') AS INTEGER) 
        AS hospital_overall_rating,
    NULLIF(TRIM("Hospital overall rating footnote"), '') 
        AS hospital_overall_rating_footnote,

    -- Mortality group (reporting capacity + per-domain performance signal)
    CAST(NULLIF(NULLIF(TRIM("MORT Group Measure Count"), ''), 'Not Available') AS INTEGER) 
        AS mort_group_measure_count,
    CAST(NULLIF(NULLIF(TRIM("Count of Facility MORT Measures"), ''), 'Not Available') AS INTEGER) 
        AS count_facility_mort_measures,
    CAST(NULLIF(NULLIF(TRIM("Count of MORT Measures Better"), ''), 'Not Available') AS INTEGER) 
        AS count_mort_measures_better,
    CAST(NULLIF(NULLIF(TRIM("Count of MORT Measures No Different"), ''), 'Not Available') AS INTEGER) 
        AS count_mort_measures_no_different,
    CAST(NULLIF(NULLIF(TRIM("Count of MORT Measures Worse"), ''), 'Not Available') AS INTEGER) 
        AS count_mort_measures_worse,
    NULLIF(TRIM("MORT Group Footnote"), '') AS mort_group_footnote,

    -- Safety group
    CAST(NULLIF(NULLIF(TRIM("Safety Group Measure Count"), ''), 'Not Available') AS INTEGER) 
        AS safety_group_measure_count,
    CAST(NULLIF(NULLIF(TRIM("Count of Facility Safety Measures"), ''), 'Not Available') AS INTEGER) 
        AS count_facility_safety_measures,
    CAST(NULLIF(NULLIF(TRIM("Count of Safety Measures Better"), ''), 'Not Available') AS INTEGER) 
        AS count_safety_measures_better,
    CAST(NULLIF(NULLIF(TRIM("Count of Safety Measures No Different"), ''), 'Not Available') AS INTEGER) 
        AS count_safety_measures_no_different,
    CAST(NULLIF(NULLIF(TRIM("Count of Safety Measures Worse"), ''), 'Not Available') AS INTEGER) 
        AS count_safety_measures_worse,
    NULLIF(TRIM("Safety Group Footnote"), '') AS safety_group_footnote,

    -- Readmission group
    CAST(NULLIF(NULLIF(TRIM("READM Group Measure Count"), ''), 'Not Available') AS INTEGER) 
        AS readm_group_measure_count,
    CAST(NULLIF(NULLIF(TRIM("Count of Facility READM Measures"), ''), 'Not Available') AS INTEGER) 
        AS count_facility_readm_measures,
    CAST(NULLIF(NULLIF(TRIM("Count of READM Measures Better"), ''), 'Not Available') AS INTEGER) 
        AS count_readm_measures_better,
    CAST(NULLIF(NULLIF(TRIM("Count of READM Measures No Different"), ''), 'Not Available') AS INTEGER) 
        AS count_readm_measures_no_different,
    CAST(NULLIF(NULLIF(TRIM("Count of READM Measures Worse"), ''), 'Not Available') AS INTEGER) 
        AS count_readm_measures_worse,
    NULLIF(TRIM("READM Group Footnote"), '') AS readm_group_footnote,

    -- Patient experience group
    CAST(NULLIF(NULLIF(TRIM("Pt Exp Group Measure Count"), ''), 'Not Available') AS INTEGER) 
        AS pt_exp_group_measure_count,
    CAST(NULLIF(NULLIF(TRIM("Count of Facility Pt Exp Measures"), ''), 'Not Available') AS INTEGER) 
        AS count_facility_pt_exp_measures,
    NULLIF(TRIM("Pt Exp Group Footnote"), '') AS pt_exp_group_footnote,

    -- Timely & Effective care group
    CAST(NULLIF(NULLIF(TRIM("TE Group Measure Count"), ''), 'Not Available') AS INTEGER) 
        AS te_group_measure_count,
    CAST(NULLIF(NULLIF(TRIM("Count of Facility TE Measures"), ''), 'Not Available') AS INTEGER) 
        AS count_facility_te_measures,
    NULLIF(TRIM("TE Group Footnote"), '') AS te_group_footnote
FROM stg_hospital_general_info;

SELECT COUNT(*) AS row_count FROM clean_hospital_general_info;