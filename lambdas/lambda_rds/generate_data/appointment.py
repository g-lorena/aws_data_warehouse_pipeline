from faker import Faker
import pandas as pd
import random
from datetime import datetime
import string


fake = Faker()

def generate_concatenated_id():
    prefix="APP"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

def generate_weekday_date():
    date = fake.date_between(start_date='-2y', end_date='today')
    while date.weekday() in (5, 6):  # Skip Saturday and Sunday
        date = fake.date_between(start_date='-2y', end_date='today')
    return date

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

    appointment_type_diagnosis_map = {
        # General Medicine
        'Routine Checkup': [
            'Hypertension', 'Diabetes Mellitus', 'Asthma', 'Hyperlipidemia',
            'Anemia', 'Hypothyroidism', 'Seasonal Allergies', 'Vitamin D Deficiency'
        ],

        # Cardiology
        'Specialist Consultation': [
            'Coronary Artery Disease', 'Heart Arrhythmias', 'Congestive Heart Failure',
            'Hypertensive Heart Disease', 'Atrial Fibrillation', 'Pericarditis'
        ],

        # Emergency Medicine
        'Emergency Visit': [
            'Fracture of bone', 'Skin Infection', 'Pneumothorax', 'Sepsis', 'Appendicitis',
            'Acute Kidney Injury', 'Myocardial Infarction', 'Stroke', 'Severe Allergic Reaction'
        ],

        # Orthopedics
        'Surgery': [
            'Osteoarthritis', 'Spinal Disc Herniation', 'Rotator Cuff Tear',
            'Meniscus Tear', 'Hip Fracture', 'Carpal Tunnel Syndrome'
        ],

        # Neurology
        'Neurological Assessment': [
            'Migraine', 'Epilepsy', 'Multiple Sclerosis', 'Parkinson’s Disease',
            'Alzheimer’s Disease', 'Trigeminal Neuralgia'
        ],

        # Psychiatry
        'Mental Health Evaluation': [
            'Anxiety Disorder', 'Depression', 'Obsessive-Compulsive Disorder (OCD)',
            'Post-Traumatic Stress Disorder (PTSD)', 'Schizophrenia', 'Bipolar Disorder'
        ],
    # Pediatrics
        'Pediatric Consultation': [
            'Chickenpox', 'Measles', 'Bronchiolitis', 'Croup', 'Ear Infection',
            'Strep Throat', 'Eczema', 'Asthma'
        ],

        # Dermatology
        'Skin Consultation': [
            'Psoriasis', 'Eczema', 'Acne Vulgaris', 'Melanoma', 'Warts',
            'Seborrheic Dermatitis', 'Contact Dermatitis'
        ],

        # Obstetrics and Gynecology
        'Prenatal Visit': [
            'Gestational Diabetes', 'Preeclampsia', 'Placenta Previa',
            'Anemia in Pregnancy', 'Hyperemesis Gravidarum'
        ],

        # Infectious Diseases
        'Vaccination': [
            'Influenza', 'COVID-19', 'Hepatitis B', 'Measles', 'Rubella',
            'Mumps', 'Polio', 'Tetanus'
        ],
        # Telemedicine
        'Telemedicine': [
            'Mild COVID-19 Symptoms', 'Seasonal Allergies', 'Mild Anxiety',
            'Mild Depression', 'Medication Refill Requests', 'Follow-up for Stable Conditions'
        ],

        # Follow-Up
        'Follow-up Visit': [
            'Hypertension', 'Type 2 Diabetes', 'Post-Surgery Recovery',
            'Chronic Obstructive Pulmonary Disease (COPD)', 'Hyperthyroidism', 
            'Chronic Back Pain', 'Rheumatoid Arthritis'
        ]
    }

    selected_type = random.choices(list(appointment_type_diagnosis_map.keys()), k=1, weights=[0.25, 0.1, 0.15, 0.1, 0.05, 0.05, 0.1, 0.05, 0.05, 0.05, 0.05, 0.05])[0] # k= num_appointments
    #selected_type = random.choice(list(appointment_type_diagnosis_map.keys()))
    diagnoses = appointment_type_diagnosis_map[selected_type]
    for _ in range(num_appointments):
        appointments.append({
            'appointment_id': generate_concatenated_id(),
            'patient_id': random.choice(patients_ids), 
            'doctor_id': random.choice(doctors_ids),
            'appointment_date': generate_weekday_date(), #=> skip weekends
            'appointment_type': selected_type, #random.choice(appointment_types),
            'diagnosis': random.choice(appointment_type_diagnosis_map[selected_type]), #random.choice(diagnoses),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(appointments)
