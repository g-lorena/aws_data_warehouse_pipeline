from sqlalchemy import create_engine, text
import os
import boto3
from datetime import datetime
import random

from generate_data.patient import generate_patients
from generate_data.doctor import generate_doctors
from generate_data.appointment import generate_appointments
from generate_data.treatment import generate_treatments 
from generate_data.procedure import generate_procedures
from generate_data.medication import generate_medications
from generate_data.department import generate_departments
from update_data.departement_update import update_generate_departments
# connect to 

DB_USERNAME = os.environ.get("DB_USERNAME")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_NAME = os.environ.get("DB_NAME")
DB_HOST = os.environ.get("DB_HOST")
#REGION = os.environ.get("REGION")

DB_PORT = '5432'

'''
DynamoDB_NAME = os.environ.get("DynamoDB_NAME")
dynamodb = boto3.resource('dynamodb')
dynamo_table = dynamodb.Table(DynamoDB_NAME)

def update_last_extraction_time(table_name):
    dynamo_table.put_item(
        Item={
            "table_name":table_name,
            "last_extraction": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    )
'''
def connect_to_postgres():
    try:
        conn_str = f'postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
        engine = create_engine(conn_str)
        print("connection to PostgreSQL data successful !")
        return engine

    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")

    
def push_dataframe_to_rds(df, table_name, engine):
    try:
        # Load the DataFrame into the specified table
        df.to_sql(table_name, engine, if_exists='append', index=False)
        print(f"Data successfully loaded into '{table_name}' table.")
    except Exception as e:
        print(f"Error loading data into '{table_name}': {e}")
    
def do_insert(engine):
    df_departement = generate_departments(5)
    existing_ids_df = pd.read_sql("SELECT department_id FROM department", engine)
    
    existing_ids = set(existing_ids_df['department_id'])
    new_departments_df = df_departement[~df_departement['department_id'].isin(existing_ids)]
    
    if not new_departments_df.empty:
        push_dataframe_to_rds(new_departments_df, 'department', engine)

    
def do_update(engine):
    existing_ids_df = pd.read_sql("SELECT department_id FROM department", engine)
    dept_ids = existing_ids_df['department_id'].tolist() # liste des departements à update
    
    num_updates = random.randint(1, min(5, len(dept_ids)))
    
    if not dept_ids:
            print("No existing departments to update.")
            return
        
    if len(existing_ids) < num_updates:
        print("No ")
        return 
    
    
    update_ids = random.sample(dept_ids, num_updates)
    
    update_generate_departments(update_ids, engine)

    '''
    with engine.connect() as conn:
        dept_ids = [row[0] for row in conn.execute("SELECT department_id FROM department").fetchall()]
        
        if not dept_ids:
            print("No existing departments to update.")
            return
        else:
        # Choose a random number of updates (e.g., 1 to 5 updates)
            num_updates = random.randint(1, min(5, len(dept_ids)))  # Update at least 1 but no more than available IDs
            update_ids = random.sample(dept_ids, num_updates)  # Randomly select IDs to update
        
            update_generate_departments(update_ids, engine)
    '''
        #valid_ids = departments_df['department_id'].tolist()
        #update_ids = random.sample(valid_ids, num_updates)
    

def lambda_handler(event, context):
    try:
        engine = connect_to_postgres()
        
        operation_choice = random.choice(['insert', 'update'])
        
        if operation_choice == 'insert':
            do_insert(engine)
            return {'statusCode': 200, 'body': 'Insert operation completed.'}
        
        if operation_choice == 'update':
            do_update(engine)
            return {'statusCode': 200, 'body': 'Update operation completed.'}
        
    except Exception as e:
        print(f"Error in lambda_handler: {e}")
        return {
            'statusCode': 500,
            'body': f'Error occurred: {str(e)}'
        }
        
    finally:
        engine.dispose()
        
    """
        df_departement = generate_departments(5)
        '''
        df_medication = generate_medications(10)
        df_doctors = generate_doctors(20, 5)
        df_patients = generate_patients(100)
        df_treatment = generate_treatments(300, 200, 10)
        df_appointment = generate_appointments(200, 100, 20)
        '''
        '''
        push_dataframe_to_rds(df_patients, 'patients', engine)
        push_dataframe_to_rds(df_treatment, 'treatments', engine)
        push_dataframe_to_rds(df_doctors, 'doctors', engine)
        push_dataframe_to_rds(df_appointment, 'appointment', engine)
        push_dataframe_to_rds(df_medication, 'medication', engine)
        '''
        push_dataframe_to_rds(df_departement, 'department', engine)
        
        '''
        # Update last extraction time for each table
        update_last_extraction_time("patients")
        update_last_extraction_time("treatments")
        update_last_extraction_time("doctors")
        update_last_extraction_time("appointment")
        update_last_extraction_time("medication")
        '''
        update_last_extraction_time("department")

        return {
            'statusCode': 200,
            'body': 'Data successfully generated and loaded into RDS.'
        }
    except Exception as e:
        print(f"Error in lambda_handler: {e}")
        return {
            'statusCode': 500,
            'body': f'Error occurred: {str(e)}'
        }
        
    finally:
        engine.dispose()
    
   """ 
    
    