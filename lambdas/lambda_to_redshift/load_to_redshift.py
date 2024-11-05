import json
import os
import boto3
from utils.db import connect_to_redshift, get_last_extraction_time
from utils.merge_appointement import merge_appointement_table
from utils.merge_departement import merge_departement_table
from utils.merge_doctor import merge_doctor_table
from utils.merge_patient import merge_patient_table
from utils.merge_procedure import merge_procedure_table
from utils.merge_treatment import merge_treatment_table
from utils.merge_medication import merge_medication_table
from datetime import datetime


REDSHIFT_HOST = os.environ['REDSHIFT_HOST']
REDSHIFT_DB = os.environ['REDSHIFT_DB']
REDSHIFT_USER = os.environ['REDSHIFT_USER']
REDSHIFT_PASSWORD = os.environ['REDSHIFT_PASSWORD']
REDSHIFT_ROLE_ARN = os.environ['REDSHIFT_ROLE_ARN']

s3 = boto3.client("s3")
DST_BUCKET = os.environ.get("DST_BUCKET")
RAW_FOLDER = os.environ.get("RAW_FOLDER")

DynamoDB_NAME = os.environ.get("DynamoDB_NAME")
dynamodb = boto3.resource('dynamodb')
dynamo_table = dynamodb.Table(DynamoDB_NAME)

#s3://my-redshift-integration-bucket-001/raw_data/department/department_20241030141748.csv
def load_into_staging_area(staging_table, s3_key, cursor):
    try:
        cursor.execute("BEGIN;")

        copy_command = f"""
            COPY {staging_table}
            FROM 's3://{DST_BUCKET}/{s3_key}'
            IAM_ROLE '{REDSHIFT_ROLE_ARN}'
            CSV
            IGNOREHEADER 1
            TIMEFORMAT 'auto'
            EMPTYASNULL
            BLANKSASNULL;
        """
        print(f"Executing COPY command: {copy_command}")
        
        cursor.execute(copy_command)
        cursor.execute("COMMIT;")

        print(f"Data loaded into staging table '{staging_table}' from S3.")
    except Exception as e:
        print(f"Error loading data into staging area: {e}")

        
def lambda_handler(event, context):
    try:
        conn = connect_to_redshift(REDSHIFT_DB, REDSHIFT_USER, REDSHIFT_PASSWORD, REDSHIFT_HOST)
        cursor = conn.cursor()
        
        staging_s3_mapping = {
            "stage_dim_patients" : "patients",
            "stage_dim_doctors"  : "doctors" ,
            "stage_dim_medication" : "medications",
            "stage_dim_departement" : "departement",
            "stage_dim_procedure" : "procedure",
            "stage_fact_treatment" :  "treatment", 
            "stage_fact_appointment" : "appointment" 
        } 
        
        DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

        # load data into 
        for staging_table, s3_key in  staging_s3_mapping.items():
            last_extraction_time_str = get_last_extraction_time(s3_key) # recuperer la derniere data d'extraction
            last_extraction_time = datetime.strptime(last_extraction_time_str, DATETIME_FORMAT)
            response = s3.list_objects_v2(Bucket=DST_BUCKET, Prefix=f"{RAW_FOLDER}/{s3_key}/")
            #print(response)
            new_files = []
            for obj in response['Contents']:
                file_last_modified = obj['LastModified']
                file_last_modified_n = file_last_modified.replace(tzinfo=None)
                if file_last_modified_n > last_extraction_time and obj['Key'].endswith('.csv'):
                    new_files.append(obj['Key'])
                    
            for file_key in new_files:
                #print(file_key)
                load_into_staging_area(staging_table, file_key, cursor)
            
        merge_patient_table(cursor)
        merge_doctor_table(cursor)
        merge_medication_table(cursor)
        merge_departement_table(cursor)
        merge_procedure_table(cursor)
        merge_treatment_table(cursor)
        merge_appointement_table(cursor)
        
       # staging_tables = ['stage_dim_patients', 'stage_dim_doctors', 'stage_dim_medication', 'stage_dim_departement', 'stage_dim_procedure']
    except Exception as e:
        
        print(f"Error {e}")
       
        

