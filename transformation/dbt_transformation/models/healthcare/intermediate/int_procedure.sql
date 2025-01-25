WITH procedures  as (
    select 
        procedure_code,
        procedure_description,
        procedure_cost,
        procedure_name,
        procedure_category,
        risk_level
    from {{ ref ('stg_procedure') }}
),

procedures_performed as (
    select 
        procedure_performed_id, 
        appointment_id,
        notes,
        procedure_code,
        duration,
        created_at,
        updated_at
    from {{ ref ('stg_procedures_performed') }}
),

based_procedures as (
    select 
        --pp.appointment_id,
        pp.procedure_performed_id,
        pp.notes,
        pp.procedure_code,
        pp.duration,
        p.procedure_description,
        --procedure_cost,
        p.procedure_name,
        p.procedure_category,
        p.risk_level,
        pp.created_at,
        pp.updated_at
    from procedures_performed as pp
    join procedures as p
        on pp.procedure_code = p.procedure_code
)

select 
    --appointment_id,
    procedure_performed_id,
    notes,
    procedure_code,
    duration,
    procedure_description,
    --procedure_cost,
    procedure_name,
    procedure_category,
    risk_level,
    created_at,
    updated_at
from based_procedures