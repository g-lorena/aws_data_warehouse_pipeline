WITH medications as (
    select 
        medication_code,
        category,
        cost
    from {{ ref ('stg_medication') }}
),

medications_prescribed as (
    select 
        medication_prescription_id, 
        appointment_id,
        medication_code,
        quantity,
        frequency,
        dosage,
        created_at,
        updated_at
    from {{ ref ('stg_medications_prescriptions') }}
), 

medication as (
    select 
        --mp.appointment_id,
        mp.medication_prescription_id, 
        mp.medication_code,
        --mp.quantity,
        mp.frequency,
        mp.dosage,
        m.category,
        --m.cost, 
        mp.created_at,
        mp.updated_at
    from medications_prescribed as mp
    join medications as m
        on mp.medication_code = m.medication_code
)

select 
    --appointment_id,
    medication_prescription_id, 
    medication_code,
    --quantity,
    frequency,
    dosage,
    category,
    --cost,
    created_at,
    updated_at
from medication
