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
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at
FROM appointments