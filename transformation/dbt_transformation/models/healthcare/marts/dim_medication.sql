{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='medication_prescription_id'
)}}


WITH medication as (
    select 
        medication_prescription_id,
        medication_code,
        frequency,
        dosage,
        category,
        created_at,
        updated_at
    from {{ ref ('int_medication') }}
), 

unique_medication as (
    select *, row_number() over(partition by medication_prescription_id) as row_number
    from medication
)

select 
    --appointment_id,
    medication_prescription_id, 
    medication_code,
    --quantity,
    frequency,
    dosage,
    category,
    --,
    --cost
    created_at,
    updated_at
from unique_medication
where row_number = 1
{% if is_incremental() %}
    AND updated_at > (SELECT MAX(updated_at) FROM {{ this }}) -- Only process new or updated rows
{% endif %}