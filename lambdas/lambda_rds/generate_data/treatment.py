from faker import Faker
import random
import pandas as pd
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="TREAT"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id 

#treatments (treatment_id, appointment_id, medication, procedure_code, treatment_date)
def generate_treatments(num_treatments, appointment_ids, procedure_ids, medications_ids):
    treatments = []
    treatment_names = [
        'Surgery', 'Therapy', 'Consultation', 'Imaging'
    ]
    for _ in range(num_treatments):
        treatments.append({
            'treatment_id': generate_concatenated_id(),
            'appointment_id': random.choice(appointment_ids), #random.randint(1, num_visits),
            'treatment_name': random.choice(treatment_names),
            #'medication': f'Medication-{random.randint(1, 50)}',
            'medication_id' : random.choice(medications_ids), #random.randint(1, num_medications), #'test', # will come back to 
            'procedure_code': random.choice(procedure_ids), #f'PRC-{random.randint(100, 999)}',
            'treatment_date': fake.date_between(start_date='-1y', end_date='today'),
            #'cost': round(random.uniform(100, 5000), 2)
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(treatments)