WITH treatments as (
  select * from {{ ref ('int_treatments') }}
),

medication as (
    select * from {{ ref ('stg_medication_data_stream') }}
),

medication_usage as (
    select 
        m.medication_name,
        COUNT(DISTINCT t.treatment_id) AS total_treatments_with_medication,
        SUM(t.treatment_cost) AS total_medication_cost,
        AVG(t.treatment_cost) AS avg_treatment_cost_with_medication
    from treatments as t 
    left join medication as m 
        on t.medication_name = m.medication_name
)

SELECT
    medication_name,
    total_treatments_with_medication,
    total_medication_cost,
    avg_treatment_cost_with_medication,
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at
FROM medication_usage;