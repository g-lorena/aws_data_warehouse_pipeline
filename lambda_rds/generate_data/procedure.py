from faker import Faker
import random

fake = Faker()

def generate_procedures(num_procedures):
    procedures = []
    for procedure_code in range(1, num_procedures + 1):
        procedures.append({
            'procedure_code': f'PRC-{random.randint(1000, 9999)}',
            'description': fake.catch_phrase(),  # A short description
            'cost': round(random.uniform(100.0, 10000.0), 2),  # Procedure cost between $100 and $10,000
            'created_at': datetime.now(), 
            'update_at': datetime.now() 
        })
    return procedures