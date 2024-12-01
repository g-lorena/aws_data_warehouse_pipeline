import os
import random
from datetime import datetime

import boto3
from delete_data.delete_departement import delete_departement
from delete_data.delete_doctor import delete_doctors
#from delete_data.delete_medication import delete_medications
from delete_data.delete_patient import delete_patients
#from delete_data.delete_procedure import delete_procedures
from insert_data.insert_appointment import insert_appointments_data
from insert_data.insert_departement import insert_departement_data
from insert_data.insert_doctor import insert_doctors_data
#from insert_data.insert_medication import insert_medications_data
from insert_data.insert_patient import insert_patient_data
#from insert_data.insert_procedure import insert_procedure_data
from insert_data.insert_treatment import insert_treatment_data
from sqlalchemy import create_engine, text
from update_data.update_appointement import update_appointments
from update_data.update_departement import update_departement
from update_data.update_doctor import update_doctors
#from update_data.update_medication import update_medications
from update_data.update_patient import update_patients
#from update_data.update_procedure import update_procedures
from update_data.update_treatment import update_treatments
from utils.db import connect_to_postgres, update_last_extraction_time

# connect to 




DB_USERNAME = os.environ.get("DB_USERNAME")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_NAME = os.environ.get("DB_NAME")
DB_HOST = os.environ.get("DB_HOST")
#REGION = os.environ.get("REGION")

DB_PORT = '5432'


#DynamoDB_NAME = os.environ.get("DynamoDB_NAME")
#dynamodb = boto3.resource('dynamodb')
#dynamo_table = dynamodb.Table(DynamoDB_NAME)


def lambda_handler(event, context):
    engine = connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME)

    if engine is None:
        # Return early if engine couldn't connect
        print("Database connection failed.")
        return {'statusCode': 500, 'body': 'Database connection failed.'}
    
    operation_choice = random.choice(['insert', 'update'])
    
    try:
        if operation_choice == 'insert':
            try: 
                #insert_medications_data(engine)
                #update_last_extraction_time("medications", dynamo_table)
                
                #insert_procedure_data(engine)
                #update_last_extraction_time("procedure", dynamo_table)

                insert_patient_data(engine)
                #update_last_extraction_time("patients", dynamo_table)
                
                insert_departement_data(engine)
                #update_last_extraction_time("department", dynamo_table)
                
                insert_doctors_data(engine)
                #update_last_extraction_time("doctors", dynamo_table)
                
                insert_appointments_data(engine)
                #update_last_extraction_time("appointments", dynamo_table)
                
                insert_treatment_data(engine)
                #update_last_extraction_time("treatement", dynamo_table)

                return {'statusCode': 200, 'body': 'Insert operation completed.'}
            except Exception as e:
                print(f"Error during insert operation: {e}")
                return {
                    'statusCode': 500,
                    'body': f'Insert operation failed: {str(e)}'
                }
        
        if operation_choice == 'update':
            try:
                #update_medications(engine)
                #update_last_extraction_time("medications", dynamo_table)

                #update_procedures(engine)
                #update_last_extraction_time("procedure", dynamo_table)
                
                update_patients(engine)
                #update_last_extraction_time("patients", dynamo_table)
                
                update_departement(engine)
                #update_last_extraction_time("department", dynamo_table)
                
                update_doctors(engine)
                #update_last_extraction_time("doctors", dynamo_table)
                
                update_appointments(engine)
                #update_last_extraction_time("appointments", dynamo_table)
                
                update_treatments(engine)
                #update_last_extraction_time("treatement", dynamo_table)
                
                return {'statusCode': 200, 'body': 'Update operation completed.'}
            except Exception as e:
                print(f"Error during update operation: {e}")
                return {
                    'statusCode': 500,
                    'body': f'Update operation failed: {str(e)}'
                }
        
        if operation_choice == 'delete':
            try:
                #delete_medications(engine)
                #update_last_extraction_time("medications", dynamo_table)
                
                #delete_procedures(engine)
                #update_last_extraction_time("procedure", dynamo_table)
                
                delete_patients(engine)
                #update_last_extraction_time("patients", dynamo_table)
                
                #delete_departement(engine)
                delete_doctors(engine)
                #update_last_extraction_time("doctors", dynamo_table)
                
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
        
    
    