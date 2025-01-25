WITH departement as (
    select * from {{ ref('stg_departement') }}
),

unique_departement as (
    select *, row_number() over(partition by department_id) as row_number
    from departement
)

select 
    department_id,
    department_name,
    department_location,
    created_at,
    updated_at
from unique_departement
where row_number = 1