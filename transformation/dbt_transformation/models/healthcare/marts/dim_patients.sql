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

with patients as (
    select
        patient_id,
        first_name,
        last_name,
        city,
        country,
        gender,
        dob,
        patient_address,
        created_at,
        updated_at
    from {{ ref('stg_patients') }}
), 

unique_patients as (
    select *, row_number() over(partition by patient_id) as row_number
    from patients
)

select 
    patient_id,
    first_name,
    last_name,
    city,
    country,
    gender,
    dob,
    patient_address,
    created_at,
    updated_at
from unique_patients
where row_number = 1
{% if is_incremental() %}
    AND updated_at > (SELECT MAX(updated_at) FROM {{ this }}) -- Only process new or updated rows
{% endif %}