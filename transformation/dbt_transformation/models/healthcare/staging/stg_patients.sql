WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'patient_id') AS patient_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'first_name') AS first_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'last_name') AS last_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_url') AS _ab_source_file_url
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'gender') AS gender
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'dob') AS dob
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'patient_address') AS patient_address
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'city') AS city
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'country') AS country
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_last_modified') AS _ab_source_file_last_modified
    FROM {{ source ("healthcare", "public_raw__stream_dim_patients") }}
)
SELECT 
        patient_id,
        first_name,
        last_name,
        updated_at,
        _ab_source_file_url,
        gender,
        dob,
        patient_address,
        city,
        country,
        created_at,
        _ab_source_file_last_modified
FROM parsed_data