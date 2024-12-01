import os

import boto3

from utils.medications import generate_medications
from utils.procedure import generate_procedures
from utils.db import upload_to_s3

DST_BUCKET = os.environ.get("DST_BUCKET")
RAW_FOLDER = os.environ.get("RAW_FOLDER")


def lambda_handler(event, context):
    try:
        medications_df = generate_medications(10000)
        upload_to_s3(medications_df, DST_BUCKET, RAW_FOLDER, 'medications')

        procedure_df = generate_procedures(5000)
        upload_to_s3(procedure_df,DST_BUCKET, RAW_FOLDER, "procedures")
    except Exception as e:
        # Handle any exceptions that occur during processing
        #print(f"Error during data extraction: {e}")
        return {
            "statusCode": 500,
            "body": f"Data extraction failed: {str(e)}"
        }