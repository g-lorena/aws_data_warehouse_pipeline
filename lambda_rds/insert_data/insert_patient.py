from utils.db import push_dataframe_to_rds
from generate_data.patient import generate_patients
        
def insert_patient_data(engine):
    df_patients = generate_patients(100)
    if not df_patients.empty:
        push_dataframe_to_rds(df_patients, 'patients', engine)
    
