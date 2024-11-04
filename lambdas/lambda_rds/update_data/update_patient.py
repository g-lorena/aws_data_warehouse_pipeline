import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text

from faker import Faker

fake = Faker()

def update_generate_patients(update_ids, engine):
    with engine.connect() as connection:
        for patient_id in update_ids:
            updated_patients = {
                'patient_address': fake.address(),
                'updated_at': datetime.now() 
            }
            
            update_query = text("""
            UPDATE patients
            SET patient_address = :patient_address, updated_at = :updated_at
            WHERE patient_id = :patient_id
            """)
            try:
                connection.execute(update_query, {
                    'patient_address': updated_patients['patient_address'],
                    'updated_at': updated_patients['updated_at'],
                    'patient_id': patient_id
                })
                connection.commit()
                print(f"Updated patient_id: {patient_id} with new values.")
            except Exception as e:
                print(f"Error updating patient_id {patient_id}: {e}")
    
def update_patients(engine):
    update_ids = update_records(engine, 'patients', 'patient_id')
    update_generate_patients(update_ids, engine)