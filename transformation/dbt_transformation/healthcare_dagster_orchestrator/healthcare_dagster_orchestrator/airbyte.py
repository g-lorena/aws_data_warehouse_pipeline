from dagster_airbyte import build_airbyte_assets, AirbyteCloudResource

from dagster import Definitions, EnvVar

airbyte_instance = AirbyteCloudResource(
    client_id="e3ddee95-6c83-47c9-b7fd-511379605db9", #EnvVar("AIRBYTE_CLIENT_ID"),
    client_secret="W3GgCkZ3LKmZwCNZ21LJdcA08ryH7phe", #EnvVar("AIRBYTE_CLIENT_SECRET"),
)
airbyte_assets = build_airbyte_assets(
    connection_id="f11a7fa9-15fc-4f25-9b2c-57ce6515977b",
    destination_tables=["public_raw__stream_dim_medication_data_stream", "public_raw__stream_dim_procedure_data_streams"],
)

#defs = Definitions(assets=airbyte_assets, resources={"airbyte": airbyte_instance})
