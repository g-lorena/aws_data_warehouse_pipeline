-- automatically detect data types
{% macro get_column_type(table_name, column_name) %}
    {% set sample_query %}
    SELECT JSONExtract(_airbyte_data, '{{ column_name }}', 'String') as sample_value
    FROM {{ table_name }}
    WHERE JSONExtract(_airbyte_data, '{{ column_name }}', 'String') IS NOT NULL
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
        
        {# Check for numeric types #}
        [... numeric type detection logic ...]
    {% endif %}
{% endmacro %}