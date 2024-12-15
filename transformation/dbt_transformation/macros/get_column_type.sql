-- automatically detect data types
{% macro get_column_type(table_name, column_name) %}
{% set schema_name = 'airbyte_internal' %}
    {% set sample_query %}
    SELECT _airbyte_data.{{ column_name }} as sample_value
    FROM {{ schema_name }}.{{ table_name }}
    WHERE _airbyte_data.{{ column_name }} IS NOT NULL
    LIMIT 1
    {% endset %}
    
    {% set results = run_query(sample_query) %}
    
    {% if execute %}
        {% set sample_value = results.columns[0].values()[0] %}
        {# Try to parse as timestamp #}
        {% set timestamp_pattern = '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z)$' %}
        {% if modules.re.match(timestamp_pattern, sample_value | string) %}
            {% do return('DateTime') %}
        {% endif %}
        
        {# Check for JSON object #}
        {% if sample_value.startswith('{') and sample_value.endswith('}') %}
            {% do return('JSON') %}
        {% endif %}
        
        {# Check for array #}
        {% if sample_value.startswith('[') and sample_value.endswith(']') %}
            {% set array_type = infer_array_type(sample_value) %}
            {% do return(array_type) %}
        {% endif %}
        
        {# Check for numeric types (integer or float) #}
        {% set int_pattern = '^-?\d+$' %}
        {% set float_pattern = '^-?\d+\.\d+$' %}

        {% if modules.re.match(int_pattern, sample_value | string) %}
            {% do return('Integer') %}
        {% elif modules.re.match(float_pattern, sample_value | string) %}
            {% do return('Float') %}
        {% endif %}

        {# Default to String if no other type matched #}
        {% do return('String') %}
    {% endif %}
{% endmacro %}