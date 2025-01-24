WITH departement as (
    select * from {{ ref('stg_departement') }}
)

select 
    department_id,
    department_name,
    department_location,
    created_at,
    updated_at
from departement