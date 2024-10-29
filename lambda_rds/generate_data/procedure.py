from faker import Faker
import random
import pandas as pd
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="PRC"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

def generate_procedures(num_procedures):
    procedures = []
    for procedure_code in range(1, num_procedures + 1):
        procedures.append({
            'procedure_code': generate_concatenated_id(),
            'procedure_description': fake.catch_phrase(),  # A short description
            'procedure_cost': round(random.uniform(100.0, 10000.0), 2),  # Procedure cost between $100 and $10,000
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return procedures