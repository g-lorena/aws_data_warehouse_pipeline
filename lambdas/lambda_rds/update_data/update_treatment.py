import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text
from faker import Faker

fake = Faker()

treatment_names = [
        'Surgery', 'Therapy', 'Consultation', 'Imaging'
    ]

def update_generate_treatments(update_ids, engine):
    with engine.connect() as connection:
        for treatment_id in update_ids:
            updated_treatment = {
                'treatment_name' : random.choice(treatment_names),
                'updated_at': datetime.now()
            }
            
            update_query = text("""
            UPDATE treatement
            SET treatment_name =: treatment_name, updated_at =: updated_at
            WHERE treatment_id = :treatment_id
            """)
            
            try:
                connection.execute(update_query, {
                    'treatment_name': updated_treatment['treatment_name'],
                    'updated_at': updated_treatment['updated_at'],
                    'treatment_id': updated_treatment['treatment_id']
                })
                connection.commit()
                print(f"Updated treatment_id: {treatment_id} with new values.")
            except Exception as e:
                print(f"Error updating treatment_id {treatment_id}: {e}")
                
def update_treatments(engine):
    update_ids = update_records(engine, 'treatement', 'treatment_id')
    update_generate_treatments(update_ids, engine)

                
                