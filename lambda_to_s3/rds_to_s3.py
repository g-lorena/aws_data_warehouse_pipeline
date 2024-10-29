import os
import boto3
import psycopg2
import pandas as pd
import io
from datetime import datetime
from sqlalchemy import create_engine 


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

    
def get_last_extraction_time(table_name):
    response = dynamo_table.get_item(Key={"table_name": table_name})
    if 'Item' in response:
        return response['Item'].get('last_extraction')
    else: 
        return None
    
def update_last_extraction_time(table_name):
    dynamo_table.put_item(
        Item={
            "table_name":table_name,
            "last_extraction": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    )
    
def connect_to_postgres():
    try:
        conn_str = f'postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
        engine = create_engine(conn_str)
        print("connection to PostgreSQL data successful !")
        return engine

    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")
    
    
def fetch_and_upload_to_s3(table_name, engine):
    last_extraction_time = get_last_extraction_time(table_name)
    
    query = f"""
        SELECT * FROM {table_name} 
        WHERE created_at > '{last_extraction_time}'
           OR updated_at > '{last_extraction_time}'
    """
    with engine.connect() as conn:
        df = pd.read_sql(query, conn)
        
        if df.empty:
            print(f"No new data to extract for table '{table_name}'.")
            
        else:
            csv_buffer = io.StringIO()
            df.to_csv(csv_buffer, index=False)
            s3.put_object(
                Bucket=DST_BUCKET,
                Key=f"{RAW_FOLDER}/{table_name}/{table_name}_{datetime.now().strftime('%Y%m%d%H%M%S')}.csv",
                Body=csv_buffer.getvalue()
            )
        
    print(f"New data successfully extracted for table '{table_name}' and uploaded to S3.")
    

def lambda_handler(event, context):
    engine = connect_to_postgres()
    tables = ['patients', 'treatments', 'doctors', 'appointment', 'medication', 'department']

    for table in tables: 
        fetch_and_upload_to_s3(table, engine)
        
    engine.dispose()
    return {
            "statusCode": 200, 
            "body": "Data extraction completed for all tables."
            }

    
    
    
        