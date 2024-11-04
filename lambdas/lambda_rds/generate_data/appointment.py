from faker import Faker
import pandas as pd
import random
from datetime import datetime


fake = Faker()

def generate_concatenated_id():
    prefix="APP"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

#appointments (appointment_id, patient_id, doctor_id, appointment_date, diagnosis)...appointment_type
def generate_appointments(num_appointments, doctors_ids, patients_ids):
    appointments = []
    
    diagnoses = [
        'Hypertension', 'Diabetes Mellitus', 'Chronic Obstructive Pulmonary Disease (COPD)',
        'Asthma', 'Coronary Artery Disease', 'Migraine', 'Anxiety Disorder', 'Depression',
        'Osteoarthritis', 'Congestive Heart Failure', 'Pneumonia', 'Fracture of bone', 
        'Skin Infection', 'Urinary Tract Infection', 'Cerebral Palsy'
    ]
    
    appointment_types = [
        'Routine Checkup', 'Follow-up Visit', 'Emergency Visit', 'Specialist Consultation', 
        'Telemedicine', 'Surgery', 'Vaccination'
    ]
    
    for _ in range(num_appointments):
        appointments.append({
            'appointment_id': generate_concatenated_id(),
            'patient_id': random.choice(patients_ids), 
            'doctor_id': random.choice(doctors_ids),
            'appointment_date': fake.date_between(start_date='-2y', end_date='today'),
            'appointment_type': random.choice(appointment_types),
            'diagnosis': random.choice(diagnoses),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(appointments)
