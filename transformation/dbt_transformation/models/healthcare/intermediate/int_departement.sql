with departement as (
    select
        department_id,
        department_name,
        department_location,
    from {{ ref('staging_departement') }}
),

appointments as (
    select
        appointment_id,
        doctor_id
    from {{ ref('staging_appointments') }}
),

treatments as (
    select
        treatment_id,
        appointment_id,
        total_treatment_cost
    from {{ ref('intermediate_treatment_detail') }}
),

based_departements as (
    select
        d.department_id,
        d.department_name,
        d.department_location,
        count(a.appointment_id) as total_appointments,
        count(t.treatment_id) as total_treatments,
        SUM(t.total_treatment_cost) AS total_revenue,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    from departement as d
    left join appointments as  a
        on departement.department_id = appointment_id.department_id
    left join treatments as t
        on appointment_id.appointment_id = treatments.appointment_id
    {{dbt_utils.group_by(n=3)}}
    --GROUP BY d.department_id, d.department_name, d.department_location
)

select 
    department_id,
    department_name,
    department_location,
    total_appointments,
    total_treatments,
    total_revenue,
    created_at,
    updated_at
from based_departements