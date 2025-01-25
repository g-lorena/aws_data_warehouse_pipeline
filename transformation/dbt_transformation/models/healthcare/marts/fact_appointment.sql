{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='appointment_id'
)}}

with appointments as (
    select
        appointment_id, 
        patient_id,
        doctor_id,
        diagnosis,
        appointment_date,
        appointment_type, 
        created_at,
        updated_at
    from {{ ref ('stg_appointments') }}
),

int_appointment_medication as (
    select 
        appointment_id,
        total_medications,
        total_medication_cost
    from {{ ref ('int_appointment_medication') }}
), 

int_appointment_procedure as (
    select 
        appointment_id,
        total_procedures,
        total_duration,
        total_procedure_cost
    from {{ ref ('int_appointment_procedure') }}
), 

based_appointments as (
    select 
        appt.appointment_id,
        appt.patient_id,
        appt.doctor_id,
        appt.appointment_date, 
        appt.appointment_type,
        appt.diagnosis,

        COALESCE(med.total_medications, 0) as medication_count, 
        COALESCE(med.total_medication_cost, 0) as total_medication_cost,
        COALESCE(proce.total_procedures, 0) as procedure_count, 
        COALESCE(proce.total_procedure_cost, 0) as total_procedure_cost,

        (COALESCE(med.total_medication_cost, 0)+COALESCE(proce.total_procedure_cost, 0)) as total_revenue

    from appointments as appt 
    left join int_appointment_medication as med 
        on appt.appointment_id = med.appointment_id
    left join int_appointment_procedure as proce 
        on appt.appointment_id = proce.appointment_id

),

unique_based_appointments as (
    select *, row_number() over(partition by appointment_id) as row_number
    from based_appointments
    where medication_count > 0 
       or procedure_count > 0
),

based_appointments_data as (
    select 
        appointment_id,
        patient_id,
        doctor_id,
        appointment_date,
        appointment_type, 
        medication_count, 
        total_medication_cost,
        procedure_count,
        total_procedure_cost,
        total_revenue
    from unique_based_appointments
    where row_number=1
    {% if is_incremental() %}
       AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})

    {% endif %} 
)


select 
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date,
    appointment_type, 
    medication_count, 
    total_medication_cost,
    procedure_count,
    total_procedure_cost,
    total_revenue
from based_appointments_data