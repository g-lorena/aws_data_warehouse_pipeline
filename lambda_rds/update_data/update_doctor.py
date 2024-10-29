import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text, inspector


def update_generate_doctors(update_ids, engine):
    with engine.connect() as connection:
        for doctor_id in update_ids:
            updated_doctor = {
                'last_name': fake.last_name(),
                'updated_at': datetime.now() 
            }
            
            update_query = text("""
            UPDATE doctors
            SET last_name = :last_name, updated_at = :updated_at
            WHERE doctor_id = :doctor_id
            """)
            try:
                connection.execute(update_query, {
                    'last_name': updated_doctor['last_name'],
                    'updated_at': updated_doctor['updated_at'],
                    'doctor_id': doctor_id
                })
                connection.commit()
                print(f"Updated doctor_id: {doctor_id} with new values.")
            except Exception as e:
                print(f"Error updating doctor_id {doctor_id}: {e}")

    
def update_doctors(engine):
    update_ids = update_records(engine, 'doctors', 'doctor_id')
    update_generate_doctors(update_ids, engine)
    
      
    