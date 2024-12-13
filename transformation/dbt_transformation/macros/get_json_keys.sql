{% macro get_json_keys(table_name) %}
{% set schema_name = 'airbyte_internal' %}
    {% if execute %}
        {% set query %}
            SELECT DISTINCT key AS key_name
            FROM {{ schema_name }}.{{ table_name }} AS t, unpivot t._airbyte_data AS value at key
        {% endset %}

        {% set result = run_query(query) %}

        {% if result and result.rows %}
            {% set keys = result.columns['key_name'] %}
        {% else %}
            {% set keys = [] %}
        {% endif %}
        {{ return(keys) }}
    {% else %}
        {{ return([]) }}
    {% endif %}
{% endmacro %}