import json
import os
import psycopg2
import boto3
from utils.db import connect_to_redshift

REDSHIFT_HOST = os.environ['REDSHIFT_HOST']
REDSHIFT_DB = os.environ['REDSHIFT_DB']
REDSHIFT_USER = os.environ['REDSHIFT_USER']
REDSHIFT_PASSWORD = os.environ['REDSHIFT_PASSWORD']
REDSHIFT_ROLE_ARN = os.environ['REDSHIFT_ROLE_ARN']

DST_BUCKET = os.environ.get("DST_BUCKET")
RAW_FOLDER = os.environ.get("RAW_FOLDER")

#s3://my-redshift-integration-bucket-001/raw_data/department/department_20241030141748.csv
def load_into_staging_area(staging_table, s3_key, cursor):
    copy_command = f"""
        COPY {staging_table}
        FROM 's3://{DST_BUCKET}/{RAW_FOLDER}/{s3_key}'
        IAM_ROLE '{REDSHIFT_ROLE_ARN}'
        CSV
        IGNOREHEADER 1
        TIMEFORMAT 'auto'
        EMPTYASNULL
        BLANKSASNULL;
    """
    cursor.execute(copy_command)
    print(f"Data loaded into staging table '{staging_table}' from S3.")
    
def merge_patient_table(cursor):
    merge_query = """
        MERGE INTO dim_patients AS main
        USING stage_dim_patients AS stage
        ON main.patient_id = stage.patient_id
        WHEN MATCHED AND main.updated_at < stage.updated_at THEN
            UPDATE SET 
                first_name = stage.first_name,
                last_name = stage.last_name,
                gender = stage.gender,
                dob = stage.dob,
                patient_address = stage.patient_address,
                city = stage.city,
                country = stage.country,
                updated_at = stage.updated_at
        WHEN NOT MATCHED THEN
            INSERT (patient_id, first_name, last_name, gender, dob, patient_address, city, country, created_at, updated_at)
            VALUES (stage.patient_id, stage.first_name, stage.last_name, stage.gender, stage.dob, stage.patient_address, stage.city, stage.country, stage.created_at, stage.updated_at);
    """
    cursor.execute(merge_query)
    cursor.execute("TRUNCATE TABLE stage_dim_patients;")
    print("Merge completed and staging table cleared.")
    
    
    
def lambda_handler(event, context):
    try:
        conn = connect_to_redshift(REDSHIFT_DB, REDSHIFT_USER, REDSHIFT_PASSWORD, REDSHIFT_HOST)
        cursor = conn.cursor()
        
        staging_s3_mapping = {
            "stage_dim_patients" : "departement"
            "stage_dim_doctors"  : "doctors"
            "stage_dim_medication" : "medications"
            "stage_dim_departement" : "departement"
            "stage_dim_procedure" : "procedure"
                
        } 
        # load data into 
        for staging_table, s3_key in  staging_s3_mapping.items():
            load_into_staging_area(staging_table, s3_key, cursor)
            
        merge_patient_table(cursor)
        
       # staging_tables = ['stage_dim_patients', 'stage_dim_doctors', 'stage_dim_medication', 'stage_dim_departement', 'stage_dim_procedure']
       
       
        

