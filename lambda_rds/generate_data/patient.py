from faker import Faker
import random
from pandas import pd
fake = Faker()

#patients (patient_id, name, age, gender, address)...
def generate_patients(num_patients=100):
    patients = []
    for _ in range(num_patients):
        patients.append({
            'patient_id': _ + 1,
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'gender': random.choice(['Male', 'Female']),
            'dob': fake.date_of_birth(minimum_age=1, maximum_age=90),
            'address': fake.address(),
            'city': fake.city(),
            'country': fake.country(),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(patients)