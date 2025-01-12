WITH medication as (
    select * from {{ ref ('stg_medication')}}
),
appointments as (
    select * from {{ ref('int_appointments') }}
)

procedures as (
    select * from {{ ref('stg_procedure') }}
)

base_treatments AS (
    SELECT
        -- Generate a unique treatment ID
        CONCAT('TREAT_', MD5(CONCAT(a.appointment_id, '_', RANDOM()::TEXT))) AS treatment_id,
        a.appointment_id,
        a.patient_id,
        a.doctor_id,
        a.appointment_date AS treatment_date,
        -- Placeholder fields for treatment specifics
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at
    FROM appointments as a
),
medications_assigned AS (
    SELECT
        t.treatment_id,
        m.medication_id,
        m.medication_name,
        m.cost AS medication_cost
    FROM base_treatments as t
    LEFT JOIN medication as m
      ON RANDOM() < 0.5 -- Simulate assigning medications to treatments (customize as needed)
),
procedures_assigned AS (
    SELECT
        t.treatment_id,
        pr.procedure_code,
        pr.procedure_description,
        pr.procedure_cost
    FROM base_treatments as t
    LEFT JOIN procedures as pr
      ON RANDOM() < 0.5 -- Simulate assigning procedures to treatments (customize as needed)
),
combined_treatments AS (
    SELECT
        t.treatment_id,
        t.appointment_id,
        t.departement_id,
        t.patient_id,
        t.doctor_id,
        t.treatment_date,
        COALESCE(m.medication_name, 'No Medication') AS medication_name,
        COALESCE(pr.procedure_description, 'No Procedure') AS procedure_description,
        (COALESCE(m.medication_cost, 0) + COALESCE(pr.procedure_cost, 0)) AS treatment_cost,
        CASE
            WHEN m.medication_id IS NOT NULL AND pr.procedure_code IS NOT NULL THEN 'Medication and Procedure'
            WHEN m.medication_id IS NOT NULL THEN 'Medication Only'
            WHEN pr.procedure_code IS NOT NULL THEN 'Procedure Only'
            ELSE 'No Treatment'
        END AS treatment_type,
        t.created_at,
        t.updated_at
    FROM base_treatments t
    LEFT JOIN medications_assigned m
      ON t.treatment_id = m.treatment_id
    LEFT JOIN procedures_assigned pr
      ON t.treatment_id = pr.treatment_id
)
SELECT
    treatment_id,
    appointment_id,
    departement_id,
    patient_id,
    doctor_id,
    treatment_date,
    treatment_type,
    medication_name,
    procedure_description,
    treatment_cost,
    created_at,
    updated_at
FROM combined_treatments
