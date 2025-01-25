WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'patient_id') AS patient_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'first_name') AS first_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'last_name') AS last_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'city') AS city
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'country') AS country
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'gender') AS gender
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'dob') AS dob
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'patient_address') AS patient_address
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
    FROM {{ source ("healthcare", "public_raw__stream_dim_patients") }}
)
SELECT 
        patient_id,
        first_name,
        last_name,
        city,
        country,
        updated_at,
        gender,
        dob,
        patient_address,
        created_at
FROM parsed_data