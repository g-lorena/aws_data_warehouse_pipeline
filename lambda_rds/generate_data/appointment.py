from faker import Faker
import pandas as pd
import random

fake = Faker()

#appointments (appointment_id, patient_id, doctor_id, appointment_date, diagnosis)...appointment_type
def generate_appointments(num_visits, num_patients, num_doctors):
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
    
    for _ in range(num_visits):
        appointments.append({
            'appointment_id': _ + 1,
            'patient_id': random.randint(1, num_patients),
            'doctor_id': random.randint(1, num_doctors),
            'appointment_date': fake.date_between(start_date='-2y', end_date='today'),
            'appointment_type': random.choice(appointment_types),
            'diagnosis': random.choice(diagnoses),
            'created_at': datetime.now(), 
            'update_at': datetime.now() 
        })
    return pd.DataFrame(appointments)
