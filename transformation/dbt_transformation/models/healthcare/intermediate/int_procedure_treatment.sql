WITH appointments as (
    select * from {{ ref('int_appointments') }}
),

procedures as (
    select * from {{ ref('stg_procedure') }}
),

base_treatments AS (
    SELECT
        -- Generate a unique treatment ID
        concat('TREAT_', 
                concat(a.appointment_id, 
                concat('_', SUBSTRING(MD5(RANDOM()::TEXT), 1, 5)))) AS treatment_id,


        a.appointment_id,
        a.patient_id,
        a.doctor_id,
        a.department_id,
        a.appointment_date AS treatment_date,
        -- Placeholder fields for treatment specifics
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at
    FROM appointments as a
),

procedures_assigned AS (
    SELECT
        t.treatment_id,
        t.appointment_id,
        pr.procedure_code,
        pr.procedure_description,
        pr.procedure_cost,
        ROW_NUMBER() OVER (PARTITION BY t.treatment_id ORDER BY RANDOM()) as rn
    FROM base_treatments as t
    LEFT JOIN procedures as pr
      ON RANDOM() < 0.8 -- Simulate assigning procedures to treatments (customize as needed)
)

select 
    treatment_id,
    appointment_id,
    procedure_code,
    procedure_description,
    procedure_cost
from procedures_assigned
where rn = 1