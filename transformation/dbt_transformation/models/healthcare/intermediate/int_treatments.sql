WITH medication as (
    select * from {{ ref ('stg_medication')}}
),
appointments as (
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
),

procedures_assigned AS (
    SELECT
        t.treatment_id,
        pr.procedure_code,
        pr.procedure_description,
        pr.procedure_cost,
        ROW_NUMBER() OVER (PARTITION BY t.treatment_id ORDER BY RANDOM()) as rn
    FROM base_treatments as t
    LEFT JOIN procedures as pr
      ON RANDOM() < 0.8 -- Simulate assigning procedures to treatments (customize as needed)
),

combined_treatments AS (
    SELECT
        t.treatment_id,
        t.appointment_id,
        t.department_id,
        t.patient_id,
        t.doctor_id,
        t.treatment_date,
        COALESCE(m.medication_name, 'No Medication') AS medication_name,
        COALESCE(pr.procedure_description, 'No Procedure') AS procedure_description,
        (COALESCE(CAST(m.medication_cost AS FLOAT), 0) + COALESCE(CAST(pr.procedure_cost AS FLOAT), 0)) AS treatment_cost,
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
      ON t.treatment_id = m.treatment_id and m.rn = 1
    LEFT JOIN procedures_assigned pr
      ON t.treatment_id = pr.treatment_id and pr.rn = 1
),

-- Step 2: Randomly assign a treatment type
treatments_with_assignments AS (
    SELECT
        bt.treatment_id,
        bt.appointment_id,
        bt.patient_id,
        bt.doctor_id,
        bt.department_id,
        bt.treatment_date,
        -- Randomly decide treatment type
        CASE
            WHEN RANDOM() < 0.4 THEN 'Medication Only'
            WHEN RANDOM() < 0.8 THEN 'Procedure Only'
            ELSE 'Medication and Procedure'
        END AS treatment_type,
        -- Assign medication and procedure with ROW_NUMBER to ensure one match per treatment
        m.medication_name,
        CAST(m.cost AS FLOAT) AS medication_cost,
        p.procedure_description,
        CAST(p.procedure_cost AS FLOAT),
        ROW_NUMBER() OVER (PARTITION BY bt.treatment_id ORDER BY RANDOM()) AS rn
    FROM base_treatments AS bt
    LEFT JOIN medication AS m ON RANDOM() < 0.8
    LEFT JOIN procedures AS p ON RANDOM() < 0.8
),

-- Step 3: Filter to ensure one random medication and procedure per treatment
filtered_treatments AS (
    SELECT *
    FROM treatments_with_assignments
    WHERE rn = 1
),

-- Step 4: Finalize treatment table
final_treatments AS (
    SELECT
        ft.treatment_id,
        ft.appointment_id,
        ft.department_id,
        ft.patient_id,
        ft.doctor_id,
        ft.treatment_date,
        ft.treatment_type,
        -- Populate fields based on treatment_type
        CASE
            WHEN ft.treatment_type = 'Medication Only' THEN ft.medication_name
            WHEN ft.treatment_type = 'Medication and Procedure' THEN ft.medication_name
            ELSE NULL
        END AS medication_name,
        CASE
            WHEN ft.treatment_type = 'Procedure Only' THEN ft.procedure_description
            WHEN ft.treatment_type = 'Medication and Procedure' THEN ft.procedure_description
            ELSE NULL
        END AS procedure_description,
        -- Calculate treatment cost
        CASE
            WHEN ft.treatment_type = 'Medication Only' THEN ft.medication_cost
            WHEN ft.treatment_type = 'Procedure Only' THEN ft.procedure_cost
            WHEN ft.treatment_type = 'Medication and Procedure' THEN COALESCE(ft.medication_cost, 0) + COALESCE(ft.procedure_cost, 0)
            ELSE 0
        END AS treatment_cost,
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at
    FROM filtered_treatments AS ft
)

-- Step 5: Output the final treatments table
SELECT *
FROM final_treatments
WHERE treatment_type != 'No Treatment'