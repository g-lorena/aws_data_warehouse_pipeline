from faker import Faker
import random
import pandas as pd
import string
from datetime import datetime

fake = Faker()

def generate_concatenated_id():
    prefix="DEP"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id
    

department_names = [
    "Internal Medicine", "Pediatrics", "Surgery", "Cardiology", "Neurology",
    "Oncology", "Radiology", "Pathology", "Emergency Medicine", "Administration",
    "Finance", "Human Resources", "Marketing", "IT", "Legal"
]

def generate_departments(num_departement):
    departments = []
    for _ in range(num_departement):
        departments.append({
            'department_id': generate_concatenated_id(),
            'department_name': random.choice(department_names),
            'department_location': random.choice(['Building A', 'Building B', 'Building C', 'Building D', 'Building E']),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })

    return pd.DataFrame(departments)

    