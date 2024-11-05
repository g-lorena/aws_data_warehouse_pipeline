import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text
from faker import Faker

fake = Faker()

diagnoses = [
        'Hypertension', 'Diabetes Mellitus', 'Chronic Obstructive Pulmonary Disease (COPD)',
        'Asthma', 'Coronary Artery Disease', 'Migraine', 'Anxiety Disorder', 'Depression',
        'Osteoarthritis', 'Congestive Heart Failure', 'Pneumonia', 'Fracture of bone', 
        'Skin Infection', 'Urinary Tract Infection', 'Cerebral Palsy'
    ]
    
appointment_types = [
    'Routine Checkup', 'Follow-up Visit', 'Emergency Visit', 'Specialist Consultation', 
    'Telemedicine', 'Surgery', 'Vaccination'
]

def update_generate_appointments(update_ids, engine):
    with engine.connect() as connection:
        for appointment_id in update_ids:
            updated_appointment = {
                'appointment_type': random.choice(appointment_types),
                'diagnosis' : random.choice(diagnoses), 
                'updated_at': datetime.now()
            }
            
            update_query = text("""
            UPDATE appointments   
            SET appointment_type = :appointment_type, diagnosis =: diagnosis, updated_at = :updated_at
            WHERE appointment_id = :appointment_id
            """)
            
            try:
                connection.execute(update_query, {
                    'appointment_type': updated_appointment['appointment_type'],
                    'diagnosis' : updated_appointment['diagnosis'],
                    'updated_at' : updated_appointment['updated_at'],
                    'appointment_id' : updated_appointment['appointment_id']
                })
                connection.commit()
                print(f"Updated appointment_id: {appointment_id} with new values.")
            except Exception as e:
                print(f"Error updating appointment_id {appointment_id}: {e}")
                
def update_appointments(engine):
    update_ids = update_records(engine, 'appointments', 'appointment_id')
    update_generate_appointments(update_ids, engine)
