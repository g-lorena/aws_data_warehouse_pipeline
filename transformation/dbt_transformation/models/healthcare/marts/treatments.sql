{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='treatment_id'
)}}

WITH treatments as (
    select 
    *
    from {{ ref('int_treatments') }}
    where 1=1
    {% if is_incremental() %}
        AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
)

select 
    treatment_id,
    appointment_id,
    patient_id,
    doctor_id,
    --department_id,
    treatment_date,
    treatment_type,
    diagnosis,
    total_procedures,
    total_duration,
    total_procedure_cost,
    total_medications,
    total_quantity,
    total_medication_cost,
    total_treatment_cost,
    created_at,
    updated_at
from treatments