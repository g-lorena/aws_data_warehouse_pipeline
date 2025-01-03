from dagster import Definitions
from dagster_dbt import DbtCliResource
from .assets import dbt_transformation_dbt_assets
from .project import dbt_transformation_project
from .schedules import schedules
from .airbyte import build_airbyte_assets, AirbyteCloudResource, airbyte_instance

defs = Definitions(
    assets=[dbt_transformation_dbt_assets, airbyte_assets],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=dbt_transformation_project),
        "airbyte": airbyte_instance
    },
)