WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_code') AS procedure_code
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_description') AS procedure_description
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_cost') AS procedure_cost
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_url') AS _ab_source_file_url
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_name') AS procedure_name
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_category') AS procedure_category
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'risk_level') AS risk_level
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '_ab_source_file_last_modified') AS _ab_source_file_last_modified
    FROM {{ source ("healthcare", "public_raw__stream_dim_procedure_data_streams") }}
)
SELECT 
        procedure_code,
        procedure_description,
        procedure_cost,
        updated_at,
        _ab_source_file_url,
        procedure_name,
        procedure_category,
        risk_level,
        created_at,
        _ab_source_file_last_modified
FROM parsed_data