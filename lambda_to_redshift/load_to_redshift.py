import json
import os
import boto3
from utils.db import connect_to_redshift
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

    
def merge_doctor_table(cursor):
    '''
    merge_query = """
        MERGE INTO dim_doctors 
        USING stage_dim_doctors 
        ON dim_doctors.doctor_id = stage_dim_doctors.doctor_id
        WHEN MATCHED AND dim_doctors.updated_at < stage_dim_doctors.updated_at THEN
            UPDATE SET 
                first_name = stage_dim_doctors.first_name,
                last_name = stage_dim_doctors.last_name,
                specialization = stage_dim_doctors.specialization,
                department_id = stage_dim_doctors.department_id,
                hire_date = stage_dim_doctors.hire_date,
                created_at = stage_dim_doctors.created_at,
                updated_at = stage_dim_doctors.updated_at 
        WHEN NOT MATCHED THEN
            INSERT (doctor_id, first_name, last_name, specialization, department_id, hire_date, created_at, updated_at)
            VALUES (stage_dim_doctors.doctor_id, stage_dim_doctors.first_name, stage_dim_doctors.last_name, stage_dim_doctors.specialization, stage_dim_doctors.department_id, stage_dim_doctors.hire_date, stage_dim_doctors.created_at, stage_dim_doctors.updated_at);
    """
    cursor.execute(merge_query)
    '''
    cursor.execute("BEGIN;")

    update_query = """
        UPDATE dim_doctors
        SET 
            first_name = stage_dim_doctors.first_name,
            last_name = stage_dim_doctors.last_name,
            specialization = stage_dim_doctors.specialization,
            department_id = stage_dim_doctors.department_id,
            hire_date = stage_dim_doctors.hire_date,
            created_at = stage_dim_doctors.created_at,
            updated_at = stage_dim_doctors.updated_at
        FROM stage_dim_doctors
        WHERE dim_doctors.doctor_id = stage_dim_doctors.doctor_id
        AND dim_doctors.updated_at < stage_dim_doctors.updated_at;
    """
    cursor.execute(update_query)
    cursor.execute("COMMIT;")

    insert_query = """
        INSERT INTO dim_doctors (doctor_id, first_name, last_name, specialization, department_id, hire_date, created_at, updated_at)
        SELECT * FROM stage_dim_doctors
        WHERE doctor_id NOT IN (SELECT doctor_id FROM dim_doctors);
    """
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")

    cursor.execute("TRUNCATE TABLE stage_dim_doctors;")
    print("Merge completed and staging table cleared.")
    
def get_last_extraction_time(table_name):
    response = dynamo_table.get_item(Key={"table_name": table_name})
    if 'Item' in response:
        return response['Item'].get('last_extraction_time')
    else: 
        return None
    
def lambda_handler(event, context):
    try:
        conn = connect_to_redshift(REDSHIFT_DB, REDSHIFT_USER, REDSHIFT_PASSWORD, REDSHIFT_HOST)
        cursor = conn.cursor()
        
        staging_s3_mapping = {
            #"stage_dim_patients" : "patients",
            "stage_dim_doctors"  : "doctors" #,
            #"stage_dim_medication" : "medications",
            #"stage_dim_departement" : "departement",
            #"stage_dim_procedure" : "procedure"
                
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
            
        merge_doctor_table(cursor)
        
       # staging_tables = ['stage_dim_patients', 'stage_dim_doctors', 'stage_dim_medication', 'stage_dim_departement', 'stage_dim_procedure']
    except Exception as e:
        
        print(f"Error {e}")
       
        

