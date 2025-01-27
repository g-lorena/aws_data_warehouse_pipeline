from dagster import Definitions, ScheduleDefinition, define_asset_job
from dagster_dbt import DbtCliResource
from .assets import dbt_transformation_dbt_assets
from .project import dbt_transformation_project
from .schedules import schedules
from .airbyte import all_airbyte_assets, healthacare_airbyte_workspace
from dagster import EnvVar

defs = Definitions(
    assets=[dbt_transformation_dbt_assets, *all_airbyte_assets],
    resources={
        "dbt": DbtCliResource(project_dir=dbt_transformation_project),
        "airbyte": healthacare_airbyte_workspace,
        #"REDSHIFT_DATABASE": EnvVar('REDSHIFT_DATABASE'),
        #"REDSHIFT_PWD":EnvVar('REDSHIFT_PWD')
    },
    schedules=[
        ScheduleDefinition(
            job=define_asset_job("all_assets", selection="*"),
            cron_schedule="0 0 * * *",  # Runs at midnight daily
        ),
    ]
)