import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text

from faker import Faker

fake = Faker()

def update_generate_medications(update_ids, engine):
    with engine.connect() as connection:
        for medication_id in update_ids:
            updated_medications = {
                'cost': round(random.uniform(5.0, 500.0), 2),
                'updated_at': datetime.now() 
            }
            
            update_query = text("""
            UPDATE medications
            SET cost = :cost, updated_at = :updated_at
            WHERE medication_id = :medication_id
            """)
            try:
                connection.execute(update_query, {
                    'cost': updated_medications['cost'],
                    'updated_at': updated_medications['updated_at'],
                    'medication_id': medication_id
                })
                connection.commit()
                print(f"Updated doctor_id: {medication_id} with new values.")
            except Exception as e:
                print(f"Error updating doctor_id {medication_id}: {e}")
    
     
def update_medications(engine):
    update_ids = update_records(engine, 'medications', 'medication_id')
    update_generate_medications(update_ids, engine) 