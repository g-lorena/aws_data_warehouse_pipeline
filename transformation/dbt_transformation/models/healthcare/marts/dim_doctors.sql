WITH doctors as (
    select * from {{ ref('stg_doctors') }}
),

unique_doctors as (
    select *, row_number() over(partition by doctor_id) as row_number
    from doctors
)

select 
    doctor_id,
    first_name,
    last_name,
    hire_date,
    updated_at,
    specialization,
   -- department_id,
    created_at
from unique_doctors
where row_number = 1