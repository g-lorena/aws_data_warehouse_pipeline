with procedures  as (
    select 
        procedure_cost
    from {{ ref ('stg_procedures') }}
),

procedures_performed as (
    select 
        procedure_performed_id, 
        appointment_id,
        duration
    from {{ ref ('stg_procedures_performed') }}
),

based_procedures as (
    select 
        p.procedure_performed_id, 
        p.appointment_id,
       -- p.notes,
       -- p.created_at,
       -- p.procedure_code,
        p.duration,
       -- p.updated_at,
       -- pp.procedure_name,
       -- pp.procedure_category,
       -- pp.risk_level,
        pp.procedure_cost
    from procedures_performed as pp
    join procedures as p
        on pp.procedure_code = p.procedure_code
), 

aggregate_procedures as (
    select
        bp.appointment_id,
        count(bp.procedure_performed_id) as total_procedures,
        sum(bp.duration) as total_duration,
        sum(bp.procedure_cost) as total_procedure_cost
    from based_procedures as bp
    group by bp.appointment_id
),

select 
    appointment_id,
    --patient_id,
    --doctor_id,
    --department_id,
    --appointment_date,
    --appointment_type,
    --diagnosis,
    total_procedures,
    total_duration,
    total_procedure_cost
from app_procedures
    