{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='patient_id'
)}}

WITH patients_aggregates as (
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
  from {{ ref ('int_departement') }}
),

patients_aggregates_analysis as  (
    select 
      * 
    from patients_aggregates
    where 1=1
        {% if is_incremental() %}
          AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})
        {% endif %}
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
from patients_aggregates_analysis