from faker import Faker
import random
import pandas as pd
import string
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="MED"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

# Generate medications data
def generate_medications(num_medications):
    medication_categories = ['Antibiotic', 'Antiviral', 'Painkiller', 'Antifungal', 'Steroid']
    medications = []
    for _ in range(num_medications):
        medications.append({
            'medication_id': generate_concatenated_id(),
            #'name': fake.unique.word().capitalize(),  # Generate a unique medication name
            'medication_name': f'Medication-{_ + 1}',
            'category': random.choice(medication_categories),  # Choose a category
            'cost': round(random.uniform(5.0, 500.0), 2),  # Medication cost between $5 and $500
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(medications) 
