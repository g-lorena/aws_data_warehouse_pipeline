from faker import Faker
import random
import pandas as pd
from datetime import datetime

fake = Faker()

# Generate medications data
def generate_medications(num_medications):
    medication_categories = ['Antibiotic', 'Antiviral', 'Painkiller', 'Antifungal', 'Steroid']
    medications = []
    for _ in range(num_medications):
        medications.append({
            'medication_id': _ + 1,
            #'name': fake.unique.word().capitalize(),  # Generate a unique medication name
            'name': f'Medication-{_ + 1}',
            'category': random.choice(medication_categories),  # Choose a category
            'cost': round(random.uniform(5.0, 500.0), 2),  # Medication cost between $5 and $500
            'created_at': datetime.now(), 
            'update_at': datetime.now() 
        })
    return medications
