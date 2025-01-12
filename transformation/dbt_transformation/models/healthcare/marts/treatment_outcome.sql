WITH treatments as (
    select * from {{ ref('int_treatments') }}
),

treatment_outcome as (
    select 
        t.treatment_type, 
        COUNT(DISTINCT t.treatment_id) AS total_treatments,
        SUM(t.treatment_cost) AS total_cost,
        AVG(t.treatment_cost) AS avg_treatment_cost
    from treatments as t
    group by t.treatment_type
)

SELECT
    treatment_type,
    total_treatments,
    total_cost,
    avg_treatment_cost,
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at
FROM combined_treatment_outcome