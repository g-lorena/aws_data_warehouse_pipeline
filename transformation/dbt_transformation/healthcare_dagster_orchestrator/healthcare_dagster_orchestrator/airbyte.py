from dagster_airbyte import AirbyteCloudWorkspace, build_airbyte_assets_definitions, AirbyteCloudResource, build_airbyte_assets, DagsterAirbyteTranslator, AirbyteConnectionTableProps
import dagster as dg
from dagster import asset, AssetKey, AssetSpec
from dagster import EnvVar
import os

class CustomDagsterAirbyteTranslator(DagsterAirbyteTranslator):
    def get_asset_spec(self, props: AirbyteConnectionTableProps) -> dg.AssetSpec:
        default_spec = super().get_asset_spec(props)

        print(f"Default Asset Spec Key Path: {default_spec.key.path}")

        new_key_path = ["healthcare", f"public_raw__stream_{default_spec.key.path[-1]}"]
        new_key = AssetKey(new_key_path)

        #new_key = AssetKey(["healthcare", f"public_raw__stream_{default_spec.key.path[-1]}"])


        # Debugging output (optional)
        print(f"Transformed Asset Key: {new_key}")

        #return default_spec.merge_attributes(
        #    metadata={"custom": "metadata"},
        #)
        return AssetSpec(
            key=new_key,
            group_name=default_spec.group_name,
            metadata=default_spec.metadata,
        )
        
healthacare_airbyte_workspace = AirbyteCloudWorkspace(
    workspace_id=EnvVar('WORKSPACE_ID').get_value(),
    client_id=EnvVar('CLIENT_ID').get_value(),
    client_secret=EnvVar('CLIENT_SECRET').get_value(),

    
)
'''

destination_tables = ["public_raw__stream_airbyte_healthcare_s3_medication", 
                    "public_raw__stream_airbyte_healthcare_medications_prescriptions",
                    "public_raw__stream_airbyte_healthcare_procedures_performed",
                    "public_raw__stream_airbyte_healthcare_s3_procedure",
                    "public_raw__stream_airbyte_healthcare_appointments",
                    "public_raw__stream_airbyte_healthcare_department",
                    "public_raw__stream_airbyte_healthcare_doctors",
                    "public_raw__stream_airbyte_healthcare_patients"
                    ]
'''
all_airbyte_assets = build_airbyte_assets_definitions(
    workspace=healthacare_airbyte_workspace,
    dagster_airbyte_translator=CustomDagsterAirbyteTranslator())


'''
airbyte_assets = build_airbyte_assets(
    connection_id="bcdba97b-fd12-4885-a9b1-e7887315b6b6",  # Replace with your actual connection ID
    asset_key_prefix=["healthcare"],
    destination_tables=destination_tables,  # Replace with your actual destination tables
)
'''