{{ config(
        materialized='incremental',
        pre_hook=[
           "{{ drop_when_not_incremental(this, is_incremental()) }}" 
        ],
        post_hook=[
            "ANALYZE {{ this }};" 
        ],
        unique_key='procedure_performed_id'
)}}

WITH procedures  as (
    select 
        procedure_performed_id,
        notes,
        procedure_code,
        duration,
        procedure_description,
        procedure_name,
        procedure_category,
        risk_level,
        created_at,
        updated_at
    from {{ ref ('int_procedure') }}
),

unique_procedure as (
    select 
        *, row_number() over(partition by procedure_performed_id) as row_number
    from procedures
)

select 
    --appointment_id,
    procedure_performed_id,
    notes,
    procedure_code,
    duration,
    procedure_description,
    procedure_name,
    procedure_category,
    risk_level,
    created_at,
    updated_at
from unique_procedure
where row_number = 1
{% if is_incremental() %}
    AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}