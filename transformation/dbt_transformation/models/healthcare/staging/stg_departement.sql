WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'department_id') AS department_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'department_name') AS department_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'department_location') AS department_location
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_url') AS _ab_source_file_url
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_last_modified') AS _ab_source_file_last_modified
    FROM {{ source ("healthcare", "public_raw__stream_dim_department") }}
)
SELECT 
    department_id,
    department_name,
    department_location,
    updated_at,
    _ab_source_file_url,
    created_at,
    _ab_source_file_last_modified
FROM parsed_data