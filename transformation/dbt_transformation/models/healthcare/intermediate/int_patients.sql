with patients as (
    select
        patient_id,
        --first_name,
        --last_name,
        --dob,
        gender
    from {{ ref('staging_patients') }}
),

appointments as (
    select 
        appointment_id,
        doctor_id,
        patient_id
    from {{ ref ('stg_appointments') }}
),

treatments as (
    select 
        treatment_id,
        appointment_id,
        patient_id,
        total_procedure_cost,
        total_medication_cost,
        total_treatment_cost 
    from {{ ref ('int_treatment_detail') }}
),

based_patients as (
    select 
        p.patient_id,
        p.gender,
        count(a.appointment_id) as total_appointments,
        count(t.treatment_id) as total_treatments,
        SUM(t.total_procedure_cost) as total_spent_on_procedures, 
        SUM(t.total_medication_cost) as total_spent_on_medications,
        SUM(t.total_treatment_cost) AS total_spent_on_treatments,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    from patients as p 
    left join appointments as a 
        on p.patient_id = a.patient_id
    left join treatments as t 
        on a.appointment_id = t.appointment_id
    {{dbt_utils.group_by(n=2)}}
    --GROUP BY p.patient_id, p.gender
)

select 
    patient_id,
    gender,
    total_appointments,
    total_treatments,
    total_spent_on_procedures,
    total_spent_on_medications,
    total_spent_on_treatments,
    created_at,
    updated_at
from based_patients
