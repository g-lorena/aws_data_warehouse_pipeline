from faker import Faker
import random
import pandas as pd
from datetime import datetime
import string

fake = Faker()

healthcare_procedures = [
    "Knee Replacement Surgery",
    "Appendectomy",
    "MRI Scan",
    "CT Scan",
    "Blood Transfusion",
    "Physical Therapy Session",
    "Cataract Surgery",
    "Colonoscopy",
    "Dental Filling",
    "Heart Bypass Surgery",
    "Hernia Repair",
    "Liver Biopsy",
    "Skin Graft",
    "Vaccination Administration",
    "Endoscopy",
    "Dialysis Session",
    "Fracture Repair",
    "Cesarean Section",
    "Joint Aspiration",
    "Pacemaker Implantation"
]

def generate_concatenated_id():
    prefix="PRC"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5)) # Random string of length 5
    unique_id = f"{prefix}_{timestamp}_{random_suffix}"
    return unique_id

def get_risk_level():
    return random.choice(["Low", "Medium", "High"])

def get_category():
    return random.choice(["Surgical", "Diagnostic", "Therapeutic", "Preventative"])

def generate_procedures(num_procedures):
    procedures = []
    for procedure_code in range(1, num_procedures + 1):
        procedures.append({
            'procedure_code': generate_concatenated_id(),
            'procedure_name': random.choice(healthcare_procedures),
            'procedure_description': f"{procedure_name} performed to {faker.text(max_nb_chars=50).lower().rstrip('.')}" #fake.catch_phrase(),  # A short description
            'procedure_category':get_category(),
            'procedure_cost': round(random.uniform(100.0, 10000.0), 2),  # Procedure cost between $100 and $10,000
            'risk_level':get_risk_level(),
            'created_at': datetime.now(), 
            'updated_at': datetime.now() 
        })
    return pd.DataFrame(procedures)