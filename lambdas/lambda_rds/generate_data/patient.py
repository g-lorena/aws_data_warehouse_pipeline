from faker import Faker
import random
import pandas as pd
import string
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="PAT"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

#patients (patient_id, name, age, gender, address)...
def generate_patients(num_patients=100):
    patients = []
    for _ in range(num_patients):
        patients.append({
            'patient_id': generate_concatenated_id(),
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'gender': random.choice(['Male', 'Female']),
            'dob': fake.date_of_birth(minimum_age=1, maximum_age=90),
            'patient_address': fake.address(),
            'city': fake.city(),
            'country': fake.country(),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(patients)