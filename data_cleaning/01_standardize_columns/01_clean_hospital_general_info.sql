DROP TABLE IF EXISTS clean_hospital_general_info;

CREATE TABLE clean_hospital_general_info AS
SELECT
    NULLIF(TRIM("Facility ID"),         '')  AS facility_id,
    NULLIF(TRIM("Facility Name"),       '')  AS hospital_name,
    NULLIF(TRIM("Address"),             '')  AS address,
    NULLIF(TRIM("City/Town"),           '')  AS city,
    NULLIF(TRIM("State"),               '')  AS state,
    NULLIF(TRIM("ZIP Code"),            '')  AS zip_code,        
    NULLIF(TRIM("County/Parish"),       '')  AS county,
    NULLIF(TRIM("Hospital Type"),       '')  AS hospital_type,
    NULLIF(TRIM("Hospital Ownership"),  '')  AS ownership,
    CASE 
        WHEN TRIM("Emergency Services") = 'Yes' THEN 1
        WHEN TRIM("Emergency Services") = 'No'  THEN 0
        ELSE NULL
    END                                       AS has_emergency_services
FROM stg_hospital_general_info;

SELECT COUNT(*) AS row_count FROM clean_hospital_general_info;
-- Perfect Table NO unwanted strings 
--Add null standardization, value trimming, and emergency_services boolean to hospital_general_info cleaning