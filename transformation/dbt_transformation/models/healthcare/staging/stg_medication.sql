WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'category') AS category
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_url') AS _ab_source_file_url
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'medication_code') AS medication_code
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'cost') AS cost
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_last_modified') AS _ab_source_file_last_modified
    FROM {{ source ("healthcare", "public_raw__stream_dim_medication") }}
)
SELECT 
        category,
        updated_at,
        _ab_source_file_url,
        medication_code,
        cost,
        created_at,
        _ab_source_file_last_modified
FROM parsed_data