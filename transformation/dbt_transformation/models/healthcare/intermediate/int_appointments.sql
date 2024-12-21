with patients as (
    select * from {{ ref ('stg_patients')}}
),

doctors as (
    select * from {{ ref ('stg_doctors')}}
),

departements as (
    select * from {{ ref ('stg_departement') }}
),
appointments as (
    select
        CONCAT(
            'APP_',
            TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS'), -- Timestamp for uniqueness
            '_',
            SUBSTRING(MD5(RANDOM()::TEXT), 1, 5) -- Random alphanumeric suffix
        ) AS appointment_id,
        
        p.patient_id,
        --p.first_name as patient_first_name,
        --p.last_name as patient_last_name,
        --p.gender as as patient_gender,
        --p.dob as patient_dob,

        d.doctor_id as doctor_id
        d.departement_id as departement_id
        --d.first_name as doctor_first_name,
        --d.last_name as doctor_last_name,

        -- Randomly assign an appointment type
        DATEADD(day, FLOOR(RANDOM() * 365), '2023-01-01') AS appointment_date,

        CASE
            WHEN RANDOM() < 0.15 THEN 'Routine Checkup'
            WHEN RANDOM() < 0.3 THEN 'Follow-up Visit'
            WHEN RANDOM() < 0.45 THEN 'Emergency Visit'
            WHEN RANDOM() < 0.6 THEN 'Specialist Consultation'
            WHEN RANDOM() < 0.75 THEN 'Telemedicine'
            WHEN RANDOM() < 0.9 THEN 'Surgery'
            ELSE 'Vaccination'
        END AS appointment_type,

        -- Randomly assign a diagnosis
        CASE
            WHEN RANDOM() < 0.067 THEN 'Hypertension'
            WHEN RANDOM() < 0.133 THEN 'Diabetes Mellitus'
            WHEN RANDOM() < 0.2 THEN 'Chronic Obstructive Pulmonary Disease (COPD)'
            WHEN RANDOM() < 0.267 THEN 'Asthma'
            WHEN RANDOM() < 0.333 THEN 'Coronary Artery Disease'
            WHEN RANDOM() < 0.4 THEN 'Migraine'
            WHEN RANDOM() < 0.467 THEN 'Anxiety Disorder'
            WHEN RANDOM() < 0.533 THEN 'Depression'
            WHEN RANDOM() < 0.6 THEN 'Osteoarthritis'
            WHEN RANDOM() < 0.667 THEN 'Congestive Heart Failure'
            WHEN RANDOM() < 0.733 THEN 'Pneumonia'
            WHEN RANDOM() < 0.8 THEN 'Fracture of bone'
            WHEN RANDOM() < 0.867 THEN 'Skin Infection'
            WHEN RANDOM() < 0.933 THEN 'Urinary Tract Infection'
            ELSE 'Cerebral Palsy'
        END AS diagnosis

    from patients as p 
    cross join doctors as d 
    join departements as dp 
        on d.departement_id = dp.departement_id
)

SELECT
    appointment_id,
    patient_id,
    doctor_id,
    departement_id,
    appointment_date,
    appointment_type,
    diagnosis,
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at
FROM appointments;