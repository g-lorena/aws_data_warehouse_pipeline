WITH parsed_data AS (
    SELECT
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'medication_prescription_id') AS medication_prescription_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'quantity') AS quantity
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'dosage') AS dosage
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'frequency') AS frequency
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'updated_at') AS updated_at
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'appointment_id') AS appointment_id
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'medication_code') AS medication_code
            ,
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), 'created_at') AS created_at
    FROM {{ source ("healthcare", "public_raw__stream_dim_medications_prescriptions") }}
)
SELECT 
        medication_prescription_id,
        quantity,
        dosage,
        frequency,
        updated_at,
        appointment_id,
        medication_code,
        created_at
FROM parsed_data