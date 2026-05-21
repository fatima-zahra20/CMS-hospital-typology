DROP TABLE IF EXISTS clean_hospital_general_info;

CREATE TABLE clean_hospital_general_info AS
SELECT
    "Facility ID"            AS facility_id,
    "Facility Name"          AS hospital_name,
    "Address"                AS address,
    "City/Town"              AS city,
    "State"                  AS state,
    "ZIP Code"               AS zip_code,
    "County/Parish"          AS county,
    "Hospital Type"          AS hospital_type,
    "Hospital Ownership"     AS ownership,
    "Emergency Services"     AS has_emergency_services
FROM stg_hospital_general_info;

SELECT COUNT(*) AS row_count FROM clean_hospital_general_info;