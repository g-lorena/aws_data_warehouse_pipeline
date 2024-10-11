from faker import Faker
import random
import pandas as pd

fake = Faker()

def generate_departments(num_departement):
    departments = []
    for _ in range(num_departements):
        departments.append({
            'department_id': _ + 1,
            'department_name': fake.job(),
            'location': random.choice(['Building A', 'Building B', 'Building C', 'Building D', 'Building E'])
        })
        
    return pd.DataFrame(departments)
    
    