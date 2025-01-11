WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'doctor_id') AS doctor_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'first_name') AS first_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'last_name') AS last_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_url') AS _ab_source_file_url
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'specialization') AS specialization
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'department_id') AS department_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'hire_date') AS hire_date
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_last_modified') AS _ab_source_file_last_modified
    FROM {{ source ("healthcare", "public_raw__stream_dim_doctors") }}
)
SELECT 
        doctor_id,
        first_name,
        last_name,
        updated_at,
        _ab_source_file_url,
        specialization,
        department_id,
        hire_date,
        created_at,
        _ab_source_file_last_modified
FROM parsed_data