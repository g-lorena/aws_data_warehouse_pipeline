from faker import Faker
import random
import pandas as pd
import string
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="PRC_PERF"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

def generate_procedures_performed(num_procedures, procedure_codes, appointment_ids):
    procedures = []
    for _ in range(num_procedures):
        procedures.append({
            'procedure_performed_id': generate_concatenated_id(),
            'appointment_id': random.choice(appointment_ids),
            'procedure_code': random.choice(procedure_codes),
            'duration': random.randint(15, 180),
            'notes': fake.sentence(),
            #'procedure_name': random.choice(healthcare_procedures),
            #'procedure_description': f"{random.choice(healthcare_procedures)} performed to {faker.text(max_nb_chars=50).lower().rstrip('.')}", #fake.catch_phrase(),  # A short description
            #'procedure_category':get_category(),
            #'procedure_cost': round(random.uniform(100.0, 10000.0), 2),  # Procedure cost between $100 and $10,000
            #'risk_level':get_risk_level(),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(procedures)