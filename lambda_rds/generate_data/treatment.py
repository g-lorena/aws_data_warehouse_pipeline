from faker import Faker
import random
import pandas as pd
from datetime import datetime

fake = Faker()

#treatments (treatment_id, appointment_id, medication, procedure_code, treatment_date)
def generate_treatments(num_treatments, num_visits, num_medications):
    treatments = []
    for _ in range(num_treatments):
        treatments.append({
            'treatment_id': _ + 1,
            'appointment_id': random.randint(1, num_visits),
            'treatment_name': random.choice(['Surgery', 'Therapy', 'Consultation', 'Imaging']),
            #'medication': f'Medication-{random.randint(1, 50)}',
            'medication_id' : random.randint(1, num_medications), #'test', # will come back to 
            'procedure_code': f'PRC-{random.randint(100, 999)}',
            'treatment_date': fake.date_between(start_date='-1y', end_date='today'),
            #'cost': round(random.uniform(100, 5000), 2)
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(treatments)