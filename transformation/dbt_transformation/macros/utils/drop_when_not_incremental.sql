{% macro drop_when_not_incremental(table_name, is_incremental) %}
 
  --This macro is used to drop a table if it is not an incremental model.
  --This is useful when you want to ensure that a table is dropped and recreated
  --when the model is not incremental.
{% if is_incremental != True -%}
  DROP TABLE IF EXISTS {{ table_name }};
{% endif %}

{% endmacro %}