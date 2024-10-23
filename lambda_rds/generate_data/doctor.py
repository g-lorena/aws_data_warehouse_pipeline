from faker import Faker
import random
from .department import generate_departments
import pandas as pd
from datetime import datetime


fake = Faker()
    
#doctors (doctor_id, name, specialty, department, hire_date)
def generate_doctors(num_doctors, num_departement):
    departments = generate_departments(num_departement)
    doctors = []
    for _ in range(num_doctors):
        doctors.append({
            'doctor_id': _ + 1,
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'specialization': random.choice(['Cardiologist', 'Neurologist', 'Pediatrician', 'Orthopedist']),
            'department_id': random.choice(departments['department_id']),
            'hire_date': fake.date_between(start_date='-10y', end_date='today'),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
        
    return pd.DataFrame(doctors)