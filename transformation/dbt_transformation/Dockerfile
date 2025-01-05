FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y git

# Install dbt and its dependencies
RUN pip install --upgrade pip
RUN pip install dbt-core dbt-redshift

# Set working directory
WORKDIR /app/dbt

# Copy DBT project and scripts
COPY models models
COPY tests tests
COPY snapshots snapshots
COPY macros macros
COPY dbt_project.yml dbt_project.yml
COPY profiles.yml profiles.yml
COPY main.py main.py
COPY packages.yml packages.yml

# Set default command (optional, overridden by Airflow tasks)
CMD ["dbt", "--version"]
