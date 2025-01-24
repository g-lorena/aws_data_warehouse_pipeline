WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_performed_id') AS procedure_performed_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'appointment_id') AS appointment_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'notes') AS notes
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'procedure_code') AS procedure_code
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'duration') AS duration
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
    FROM {{ source ("healthcare", "public_raw__stream_dim_procedures_performed") }}
)
SELECT 
        procedure_performed_id,
        appointment_id,
        notes,
        created_at,
        procedure_code,
        duration,
        updated_at
FROM parsed_data