from faker import Faker
import random
import pandas as pd
import string
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="PRESC"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

def generate_medications_prescriptions(num_medications_prescriptions, appointment_ids, medication_codes):
    frequencies = ['daily', 'weekly', 'bi-weekly', 'monthly']
    medications_prescriptions = []
    for _ in range(num_medications_prescriptions):
        medications_prescriptions.append({
            'medication_prescription_id': generate_concatenated_id(),
            'appointment_id': random.choice(appointment_ids),
            'medication_code': random.choice(medication_codes),
            'quantity': random.randint(1, 5),
            'dosage': random.randint(1, 3),  
            'frequency': random.choice(frequencies), 
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(medications_prescriptions)