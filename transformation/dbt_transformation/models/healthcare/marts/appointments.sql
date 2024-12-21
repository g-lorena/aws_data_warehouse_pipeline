WITH appointments as (
    select * from {{ ref('int_appointments') }}
)