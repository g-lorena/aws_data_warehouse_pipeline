with patients as (
    select
        patient_id,
        first_name,
        last_name,
        city,
        country,
        updated_at,
        gender,
        dob,
        patient_address,
        created_at,
        updated_at
    from {{ ref('staging_patients') }}
),

select 
    patient_id,
    first_name,
    last_name,
    city,
    country,
    updated_at,
    gender,
    dob,
    patient_address,
    created_at,
    updated_at
from patients