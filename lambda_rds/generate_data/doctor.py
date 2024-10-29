from faker import Faker
import random
from .department import generate_departments
import pandas as pd
import string
from datetime import datetime


fake = Faker()

def generate_concatenated_id():
    prefix="DOC"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id
    
def generate_doctors(num_doctors, num_departement):
   
    departments = generate_departments(num_departement) # à modifier => recuperer les donn&es deja stockées pas de nouvelles generations
    doctors = []
    for _ in range(num_doctors):
        doctors.append({
            'doctor_id': generate_concatenated_id(),
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'specialization': random.choice(['Cardiologist', 'Neurologist', 'Pediatrician', 'Orthopedist']),
            'department_id': random.choice(departments['department_id']),
            'hire_date': fake.date_between(start_date='-10y', end_date='today'),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
        
    return pd.DataFrame(doctors)