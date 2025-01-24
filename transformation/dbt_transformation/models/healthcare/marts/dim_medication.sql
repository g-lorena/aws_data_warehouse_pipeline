WITH medication as (
    select * from {{ ref ('int_medication') }}
)

select 
    appointment_id,
    medication_prescription_id, 
    medication_code,
    --quantity,
    frequency,
    dosage,
    category
    --,
    --cost
from medication