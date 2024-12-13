import os
import subprocess

def run_dbt_macro():
    """Run the dbt macro and capture the output."""
    try:
        # Run the dbt command to execute the macro
        result = subprocess.run(
            ['dbt', 'run-operation', 'generate_models'],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Capture the output
        output = result.stdout

        lines = output.splitlines()
        

        models = populate(lines)

        for model in models:
            model_name = model['model_name']
            sql_content = model['sql_content']
            write_sql_to_file(model_name, sql_content.strip())
    
    except subprocess.CalledProcessError as e:
        print(f"Error running dbt command: {e}")
        print(f"Stdout: {e.stdout}")
        print(f"Stderr: {e.stderr}")

def populate(lines):
    model_name = None
    sql_content = ""
    models = []
    for line in lines:
        if line.endswith('.sql:'):
            model_name = line.split(": ")[-1].strip().split('/')[-1].replace('.sql', '').replace(':','')
            sql_content = ""
            print(model_name)
        
        elif model_name and line.strip() and line.startswith("WITH"):
            sql_content += line + "\n"
            print("Capturing SQL content starting with WITH.")

        elif model_name and line.strip() and sql_content is not None:
            sql_content += line + "\n"

    
    if model_name and sql_content:
        models.append({
            'model_name': model_name,
            'sql_content':sql_content.strip()
        })

            # Reset for next model
        model_name = None
        sql_content = ""
    return models
    #return model_name, sql_content

def write_sql_to_file(model_name, sql_content):
    """Write the SQL content to a file."""
    model_file_path = f'models/example/{model_name}.sql'
    
    # Ensure the models directory exists
    os.makedirs(os.path.dirname(model_file_path), exist_ok=True)
    cleaned_content = '\n'.join(line for line in sql_content.splitlines() if line.strip())

    with open(model_file_path, 'w') as f:
        f.write(cleaned_content)
    
    print(f"Wrote SQL content to {model_file_path}")

def update_sources_yml(new_tables):
    with open('dbt_project.yml', 'r') as file:
        content = file.read()

    # Parse YAML while preserving comments and format
    yaml_data = yaml.safe_load(content)

    # Find the raw_data source
    for source in yaml_data['sources']:
        if source['name'] == 'airbyte_internal':
            # Filter out tables that are not in new_tables
            source['tables'] = [table for table in source.get('tables', []) if table['name'] in new_tables]
            
            # Get existing table names
            existing_tables = [table['name'] for table in source['tables']]
            
            # Add new tables, avoiding duplicates
            for table in new_tables:
                if table not in existing_tables:
                    source['tables'].append({
                        'name': table,
                        'identifier': table
                    })

    # Convert updated YAML back to string
    updated_yaml = yaml.dump(yaml_data, sort_keys=False)

    # Preserve the original formatting for database and schema
    original_db_line = re.search(f'database:.*', content).group(0)
    original_schema_line = re.search(f'schema:.*', content).group(0)
    
    updated_yaml = re.sub(f'database:.*', original_db_line, updated_yaml)
    updated_yaml = re.sub(f'schema:.*', original_schema_line, updated_yaml)

    with open('dbt_project.yml', 'w') as file:
        file.write(updated_yaml)


run_dbt_macro()
