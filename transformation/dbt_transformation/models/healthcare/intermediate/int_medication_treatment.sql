WITH medication as (
    select * from {{ ref ('stg_medication')}}
),
appointments as (
    select * from {{ ref('int_appointments') }}
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

medications_assigned AS (
    SELECT
        t.treatment_id,
        t.appointment_id,
        m.medication_id,
        m.medication_name,
        m.cost AS medication_cost,
        ROW_NUMBER() OVER (PARTITION BY t.treatment_id ORDER BY RANDOM()) as rn
    FROM base_treatments as t
    LEFT JOIN medication as m
      ON RANDOM() < 0.8 -- Simulate assigning medications to treatments (customize as needed)
)

select 
    treatment_id,
    appointment_id,
    medication_id,
    medication_name,
    medication_cost
from medications_assigned
where rn = 1
