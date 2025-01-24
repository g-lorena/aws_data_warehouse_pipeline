WITH appointment_procedure as (
    select 
        appointment_id,
        patient_id,
        doctor_id,
        --department_id,
        appointment_date,
        appointment_type,
        diagnosis,
        total_procedures,
        total_duration,
        total_procedure_cost
    from {{ ref('int_appointment_procedure') }} 
),

appointment_medication as (
    select 
        appointment_id,
        patient_id,
        doctor_id,
        --department_id,
        appointment_date,
        appointment_type,
        diagnosis,
        total_medications,
        total_quantity,
        total_medication_cost
    from {{ ref('int_appointment_medication') }} 
),

based_treatment as (
    SELECT 
    {{ dbt_utils.generate_surrogate_key(
        ['appointment_id', 'patient_id', 'doctor_id'])
    }} AS treatment_id,
    ap.appointment_id,
    ap.patient_id,
    ap.doctor_id,
    --ap.department_id,
    ap.appointment_date,
    ap.appointment_type,
    ap.diagnosis,
    COALESCE(ap.total_procedures, 0) as total_procedures,
    COALESCE(ap.total_duration, 0) as total_duration,
    COALESCE(ap.total_procedure_cost, 0) as total_procedure_cost,
    COALESCE(am.total_medications, 0) as total_medications,
    COALESCE(am.total_quantity, 0) as total_quantity,
    COALESCE(am.total_medication_cost, 0) as total_medication_cost,
    (COALESCE(ap.total_procedure_cost, 0) + COALESCE(am.total_medication_cost, 0)) AS total_treatment_cost,
    CURRENT_TIMESTAMP() as created_at,
    CURRENT_TIMESTAMP() as updated_at
FROM appointment_procedure as ap
LEFT JOIN appointment_medication as am
    ON ap.appointment_id = am.appointment_id
)

select 
    treatment_id,
    appointment_id,
    patient_id,
    doctor_id,
    --department_id,
    appointment_date as treatment_date,
    appointment_type as treatment_type,
    diagnosis,
    total_procedures,
    total_duration,
    total_procedure_cost,
    total_medications,
    total_quantity,
    total_medication_cost,
    created_at,
    updated_at
from based_treatment

