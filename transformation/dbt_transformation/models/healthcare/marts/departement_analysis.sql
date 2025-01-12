{{ config(
    pre_hook="{{ drop_when_not_incremental(this, is_incremental() )}}",
    post_hook=[
        "OPTIMIZE {{ this }} ZORDER BY (department_id)",
        "ANALYZE TABLE {{ this }} COMPURE STATISTICS FOR ALL COLUMNS"
    ],
    unique_key='department_id'
)}}

WITH departements as (
  select * from {{ ref ('stg_departement') }}
),

appointments as (
  select * from {{ ref('int_appointments') }}
),

treatments as (
  select * from {{ ref('int_treatments') }}
),

department_aggregates AS (
    SELECT
        -- Department details
        dp.department_id,
        dp.department_name,
        dp.department_location,

        -- Metrics for department-level summary
        COUNT(DISTINCT t.treatment_id) AS total_treatments,  -- Total number of treatments
        SUM(t.treatment_cost) AS total_costs,    -- Total revenue from treatments
        AVG(t.treatment_cost) AS average_treatment_cost,  -- Average cost of treatments
        COUNT(DISTINCT a.appointment_id) AS total_appointments,  -- Total number of appointments
        SUM(CASE WHEN t.treatment_type = 'Medication Only' THEN t.treatment_cost ELSE 0 END) AS medication_revenue,
        SUM(CASE WHEN t.treatment_type = 'Procedure Only' THEN t.treatment_cost ELSE 0 END) AS procedure_revenue,
        ROUND(AVG(t.treatment_cost), 2) AS avg_treatment_cost  -- Average cost of treatments per department
    FROM departements as dp
    LEFT JOIN appointments as a
      ON dp.department_id = a.department_id
    LEFT JOIN treatments as t
      ON a.appointment_id = t.appointment_id
    GROUP BY dp.department_id, dp.department_name, department_location
)

SELECT
    department_id,
    department_name,
    department_location,
    total_treatments,
    total_costs,
    average_treatment_cost,
    total_appointments,
    medication_revenue, 
    procedure_revenue,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM department_aggregates