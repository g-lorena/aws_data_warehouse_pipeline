{{ config(
    pre_hook="{{ drop_when_not_incremental(this, is_incremental() )}}",
    post_hook=[
        "OPTIMIZE {{ this }} ZORDER BY (appointment_id)",
        "ANALYZE TABLE {{ this }} COMPURE STATISTICS FOR ALL COLUMNS"
    ],
    unique_key='appointment_id'
)}}

WITH appointments as (
    select * from {{ ref('int_appointments') }}
)

SELECT
    appointment_id,
    patient_id,
    doctor_id,
    department_id,
    appointment_date,
    appointment_type,
    diagnosis,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM appointments