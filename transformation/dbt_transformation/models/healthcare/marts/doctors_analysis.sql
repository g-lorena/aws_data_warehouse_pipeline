{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='doctor_id'
)}}

with doctors as (
    select 
        *
    from {{ ref('int_doctors') }}
    where 1=1
    {% if is_incremental() %}
        AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
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
from doctors