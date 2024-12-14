{% macro dynamic_model(table_name) %}
{% set json_keys = get_json_keys(table_name) %}
{% set dest = '{{ source ("airbyte_internal", "' ~ table_name ~ '") }}' %}

{% set sql %}
{{ config(materialized='table') }}

WITH parsed_data AS (
    SELECT
        {% for key in json_keys %}
            {% set column_type = get_column_type(table_name, key) %}
            {% if column_type == 'DateTime' %}
                --parseDateTime64BestEffort(JSONExtract(_airbyte_data, '{{ key }}', 'String')) AS {{ key }}
                parseDateTime64BestEffort(JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data),  '{{ key }}')) AS {{ key }}
            {% else %}
                JSON_EXTRACT_PATH_TEXT(JSON_SERIALIZE(_airbyte_data), '{{ key }}') AS {{ key }}
               -- JSONExtract(_airbyte_data, '{{ key }}', '{{column_type}}') AS {{ key }}
            {% endif %}
            {% if not loop.last %},{% endif %}
        {% endfor %}
    FROM {{dest}}
)

SELECT 
    {% for key in json_keys %}
        {{ key }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM parsed_data
{% endset %}

{{ sql }}
{% endmacro %}