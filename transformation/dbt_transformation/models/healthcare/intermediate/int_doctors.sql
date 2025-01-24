WITH doctors as (
    select 
        doctor_id,
        first_name,
        last_name,
        --hire_date,
        updated_at,
        specialization,
        department_id,
        created_at
    from {{ ref('stg_doctors') }}
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
        doctor_id,
        total_treatment_cost 
    from {{ ref ('int_treatment_detail') }}
),

based_doctors as (
    select 
        d.doctor_id,
        d.first_name,
        d.specialization,
        count(a.appointment_id) as total_appointments,
        count(t.treatment_id) as total_treatments,
        count(patient_id) as total_patients,
        SUM(t.total_treatment_cost) AS total_revenue,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    from doctors as d
    left join appointments as a
        on doctors.doctor_id = appointments.doctor_id
    left join treatments as t
        on appointments.appointment_id = treatments.appointment_id
    {{dbt_utils.group_by(n=3)}}
    --GROUP BY d.doctor_id, d.first_name, d.specialization
)

select 
    doctor_id,
    first_name,
    specialization,
    total_appointments,
    total_treatments,
    total_patients,
    total_revenue,
    created_at,
    updated_at
from based_doctors