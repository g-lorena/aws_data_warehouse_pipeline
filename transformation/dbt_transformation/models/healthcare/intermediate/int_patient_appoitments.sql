with appointments as (
    select * from {{ ref ('stg_appointments')}}
),

patients as (
    select * from {{ ref ('stg_patients')}}
),

doctors as (
    select * from {{ ref ('stg_doctors')}}
),

departements as (
    select * from {{ ref ('stg_departement') }}
),

patient_appointments as (
    select 
        pa.appointment_id,
        pa.patient_id,
        pa.appointment_date,
        pa.appointment_type,
        pa.diagnosis,
        p.first_name as patient_first_name,
        p.last_name as patient_last_name,
        p.gender as as patient_gender,
        p.dob as patient_dob,
        d.department_name,
        doc.first_name as doctor_first_name,
        doc.last_name as doctor_last_name
    from appointments as pa 
    left join patients as p 
        on pa.patient_id = p.patient_id
    left join doctors as doc 
        on pa.doctor_id = pa.doctor_id
    left join departements as d 
        on doc.department_id = d.department_id
) , 

select * from patient_appointments