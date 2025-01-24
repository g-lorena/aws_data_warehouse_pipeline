WITH procedures  as (
    select 
        procedure_code,
        procedure_description,
        procedure_cost,
        procedure_name,
        procedure_category,
        risk_level
    from {{ ref ('stg_procedures') }}
),

procedures_performed as (
    select 
        procedure_performed_id, 
        appointment_id,
        notes,
        procedure_code,
        duration
    from {{ ref ('stg_procedures_performed') }}
),

based_procedures as (
    select 
        appointment_id,
        procedure_performed_id,
        notes,
        procedure_code,
        duration,
        procedure_description,
        procedure_cost,
        procedure_name,
        procedure_category,
        risk_level
    from procedures_performed as pp
    join procedures as p
        on pp.procedure_code = p.procedure_code
)

select 
    appointment_id,
    procedure_performed_id,
    notes,
    procedure_code,
    duration,
    procedure_description,
    --procedure_cost,
    procedure_name,
    procedure_category,
    risk_level
from based_procedures