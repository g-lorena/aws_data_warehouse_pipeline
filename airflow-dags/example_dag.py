from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.models import Variable
from datetime import datetime

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 1, 1),
    'retries': 1,
}

# Retrieve values from Airflow Variables
redshift_database = Variable.get("REDSHIFT_DATABASE")
redshift_password = Variable.get("REDSHIFT_PWD")

# Define the DAG
dag = DAG(
    'dbt_project_ecr_dag',  # Name of your DAG
    default_args=default_args,
    schedule_interval='@daily',  # Schedule to run daily, change if needed
    catchup=False,
)

'''
# Task 1: run dbt deps
install_dbt_deps = DockerOperator(
    task_id="install_dbt_deps",  # Running DBT deps
    image="623838372493.dkr.ecr.eu-west-3.amazonaws.com/healthcare-dbt-project:latest",  # Your Docker image
    command="dbt deps --profiles-dir /app/dbt/profiles.yml",  # Run DBT with the correct profiles dir
    docker_url="unix://var/run/docker.sock",  # Use the default Docker socket
    network_mode="bridge",  # Use bridge networking
    #volumes=["/path/to/local/profiles:/app/dbt/profiles"],  # Mount your profiles directory
    #environment={
    #    "DBT_PROFILES_DIR": "/app/dbt/profiles",  # Ensure DBT uses the correct profile directory
    #},
    environment={
        "REDSHIFT_DATABASE": redshift_database,
        "REDSHIFT_PWD": redshift_password
    },
    dag=dag,
)
'''

'''
# Task 2: Run main.py in Docker (for any pre-dbt processing)
run_main_py = DockerOperator(
    task_id="run_main_py",  # Running your main.py script
    image="623838372493.dkr.ecr.eu-west-3.amazonaws.com/healthcare-dbt-project:1.0.0",  # Your Docker image
    command="python /app/dbt/main.py",  # Run your main.py file that prepares data or sets up models, python /app/dbt/main.py
    docker_url="unix://var/run/docker.sock",  # Use the default Docker socket
    network_mode="bridge",  # Use bridge networking
    #volumes=["/path/to/local/profiles:/app/dbt/profiles"],  # Mount your profiles directory
    #environment={
    #    "DBT_PROFILES_DIR": "/app/dbt/profiles",  # Ensure DBT uses the correct profile directory
    #},
    environment={
        "DBT_PROFILES_DIR": "/app/dbt",
        "REDSHIFT_DATABASE": redshift_database,
        "REDSHIFT_PWD": redshift_password
    },
    force_pull=True,
    dag=dag,
)
'''
# Task 3: Run DBT models in Docker
run_dbt = DockerOperator(
    task_id="run_dbt_project",  # Running DBT models
    image="623838372493.dkr.ecr.eu-west-3.amazonaws.com/healthcare-dbt-project:1.0.0",  # Your Docker image
    command="dbt run --profiles-dir /app/dbt/profiles.yml",  # Run DBT with the correct profiles dir
    docker_url="unix://var/run/docker.sock",  # Use the default Docker socket
    network_mode="bridge",  # Use bridge networking
    #volumes=["/path/to/local/profiles:/app/dbt/profiles"],  # Mount your profiles directory
    #environment={
    #    "DBT_PROFILES_DIR": "/app/dbt/profiles",  # Ensure DBT uses the correct profile directory
    #},
    environment={
        "DBT_PROFILES_DIR": "/app/dbt",
        "REDSHIFT_DATABASE": redshift_database,
        "REDSHIFT_PWD": redshift_password
    },
    force_pull=True,
    dag=dag,
)

# Set task dependencies
#authenticate_docker >> 
#install_dbt_deps >> 
run_dbt  # Ensure main.py runs before DBT models

