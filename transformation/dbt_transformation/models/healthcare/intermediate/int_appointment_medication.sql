with medications as (
    select 
        medication_code,
        category,
        cost
    from {{ ref ('stg_medications') }}
),

medications_prescribed as (
    select 
        medication_prescription_id, 
        appointment_id,
        medication_code,
        quantity,
        frequency,
        dosage
    from {{ ref ('stg_medications_prescribed') }}
),

based_medications as (
    select 
        mp.medication_prescription_id, 
        mp.appointment_id,
        mp.medication_code,
        mp.quantity,
        --mp.frequency,
        --mp.dosage,
        --m.category,
        m.cost
    from medications_prescribed as mp
    join medications as m
        on mp.medication_code = m.medication_code
),

aggregate_medications as (
    select
        bm.appointment_id,
        count(bm.medication_prescription_id) as total_medications,
        sum(bm.cost * bm.quantity) as total_medication_cost
        --sum(bm.quantity) as total_quantity,
        --sum(bm.cost) as total_medication_cost
    from based_medications as bm
    group by bm.appointment_id
),

select 
    appointment_id,
    --patient_id,
    --doctor_id,
    --department_id,
    --appointment_date,
    --appointment_type,
    --diagnosis,
    total_medications,
    --total_quantity,
    total_medication_cost
from app_medications