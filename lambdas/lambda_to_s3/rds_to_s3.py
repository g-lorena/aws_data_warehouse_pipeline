import os
import boto3
from utils.db import connect_to_postgres, fetch_and_upload_to_s3

DST_BUCKET = os.environ.get("DST_BUCKET")
RAW_FOLDER = os.environ.get("RAW_FOLDER")

DynamoDB_NAME = os.environ.get("DynamoDB_NAME")
DB_USERNAME = os.environ.get("DB_USERNAME")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_NAME = os.environ.get("DB_NAME")
DB_HOST = os.environ.get("DB_HOST")
DB_PORT = '5432'

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client("s3")
dynamo_table = dynamodb.Table(DynamoDB_NAME)


def lambda_handler(event, context):
    try:
        
        engine = connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME)
        if engine is None:
            print("No database connection available.")
            return
    
        tables = ['patients', 'doctors', 'medications', 'department', 'procedure']

        for table in tables: 
            fetch_and_upload_to_s3(table, dynamo_table, engine, DST_BUCKET, RAW_FOLDER,s3)
            
        return {
            "statusCode": 200, 
            "body": "Data extraction to s3 completed for all tables."
        }
    
    except Exception as e:
        # Handle any exceptions that occur during processing
        print(f"Error during data extraction: {e}")
        return {
            "statusCode": 500,
            "body": f"Data extraction failed: {str(e)}"
        }
    finally:
        engine.dispose()
            
    

    
    
    
        