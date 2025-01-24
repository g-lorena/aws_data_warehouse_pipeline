WITH medications as (
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

medication as (
    select 
        appointment_id,
        medication_prescription_id, 
        medication_code,
        quantity,
        frequency,
        dosage,
        category,
        cost
    from medications_prescribed as mp
    join medications as m
        on mp.medication_code = m.medication_code
)

select 
    appointment_id,
    medication_prescription_id, 
    medication_code,
    quantity,
    frequency,
    dosage,
    category,
    cost
from medication
