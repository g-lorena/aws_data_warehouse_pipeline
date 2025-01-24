WITH doctors as (
    select * from {{ ref('stg_doctors') }}
)

select 
    doctor_id,
    first_name,
    last_name,
    hire_date,
    updated_at,
    specialization,
    department_id,
    created_at
from doctors