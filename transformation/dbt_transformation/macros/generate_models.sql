{% macro generate_models() %}
    {{ log("Generate models is running!", info=True) }}
    {% set target_database = env_var('REDSHIFT_DATABASE' ) %}
    {{ log("REDSHIFT_DATABASE: " ~ target_database, info=True) }}
    {% set execute = env_var('DBT_EXECUTE') %}
    {{ log("DBT_EXECUTE: " ~ execute, info=True) }}
    {% set schema_name = 'airbyte_internal' %}
    
    {% set get_tables_query %}
        SELECT table_name
        FROM information_schema.tables 
        WHERE table_schema = '{{ schema_name }}' 
                AND table_name LIKE 'public_raw__stream_%'
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

    --{# Return the generated SQL files for logging or debugging #}
    --{% if all_file_contents %}
    --    {% set result_string = all_file_contents | join('\n') %}
    --    {{ log("Generated models:\n" ~ result_string, info=True) }}
    --    {% do return(result_string) %}
    --{% else %}
    --    {% do return("No models generated.") %}
    --{% endif %}
    {{ log("all_file_contents: " ~ all_file_contents, info=True) }}
    {% do return(all_file_contents) %}
{% endmacro %}