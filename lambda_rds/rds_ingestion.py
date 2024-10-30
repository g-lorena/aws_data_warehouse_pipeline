from sqlalchemy import create_engine, text
import os
import boto3
from datetime import datetime
import random

from utils.db import connect_to_postgres

from insert_data.insert_departement import insert_departement_data
from insert_data.insert_doctor import insert_doctors_data
from insert_data.insert_patient import insert_patient_data
from insert_data.insert_procedure import insert_procedure_data
from insert_data.insert_medication import insert_medications_data
# connect to 

from update_data.update_departement import update_departement
from update_data.update_doctor import update_doctors
from update_data.update_medication import update_medications
from update_data.update_patient import update_patients
from update_data.update_procedure import update_procedures

from delete_data.delete_departement import delete_departement
from delete_data.delete_doctor import delete_doctors
from delete_data.delete_medication import delete_medications
from delete_data.delete_patient import delete_patients
from delete_data.delete_procedure import delete_procedures


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

def lambda_handler(event, context):
    engine = connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME)

    if engine is None:
        # Return early if engine couldn't connect
        print("Database connection failed.")
        return {'statusCode': 500, 'body': 'Database connection failed.'}
    
    operation_choice = random.choice(['insert', 'update', 'delete'])
    
    try:
        if operation_choice == 'insert':
            try: 
                insert_medications_data(engine)
                insert_procedure_data(engine)
                insert_patient_data(engine)
                insert_departement_data(engine)
                insert_doctors_data(engine)
                return {'statusCode': 200, 'body': 'Insert operation completed.'}
            except Exception as e:
                print(f"Error during insert operation: {e}")
                return {
                    'statusCode': 500,
                    'body': f'Insert operation failed: {str(e)}'
                }
        
        if operation_choice == 'update':
            try:
                update_medications(engine)
                update_procedures(engine)
                update_patients(engine)
                update_departement(engine)
                update_doctors(engine)
                return {'statusCode': 200, 'body': 'Update operation completed.'}
            except Exception as e:
                print(f"Error during update operation: {e}")
                return {
                    'statusCode': 500,
                    'body': f'Update operation failed: {str(e)}'
                }
        if operation_choice == 'delete':
            try:
                delete_medications(engine)
                delete_procedures(engine)
                delete_patients(engine)
                #delete_departement(engine)
                delete_doctors(engine)
                return {'statusCode': 200, 'body': 'delete operation completed.'}
            except Exception as e:
                print(f"Error during update operation: {e}")
                return {
                    'statusCode': 500,
                    'body': f'Update operation failed: {str(e)}'
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
    
    