{% macro generate_models() %}
    {% set target_database = env_var('DBT_DATABASE' ) %}
    {% set execute = env_var('DBT_EXECUTE') %}
    
    {% set get_tables_query %}
        SELECT name
        FROM system.tables
        WHERE database = '{{ target_database }}'
          AND name LIKE 'public_raw__stream_%'
    {% endset %} 
    
    {% set results = run_query(get_tables_query) %}
    {% set all_file_contents = [] %}

    {% if execute %}
        {% for table_data in results %}
            {% for table in table_data %}
                {% set table_name = table %}
                {% set model_parts = table.split('public_raw__stream_') %}
                {% set output_name = model_parts[1] %}  
                {% set model_name = output_name %}
                {% set model_file = 'models/' ~ model_name ~ '.sql' %}
                {% set model_content = dynamic_model(table_name) %}
                {% set file_content = model_file ~ ':\n' ~ model_content %}
                {% do all_file_contents.append(file_content) %}
            {% endfor %}
        {% endfor %}
    {% endif %}
{% endmacro %}