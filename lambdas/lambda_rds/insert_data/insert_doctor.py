from utils.db import push_dataframe_to_rds, get_departement_ids
from generate_data.doctor import generate_doctors
        
def insert_doctors_data(engine):
    departements_ids = get_departement_ids(engine)
    if not departements_ids:
        print("No departments found. Please insert departments first.")
        return
    
    df_doctors = generate_doctors(20, departements_ids)
    if not df_doctors.empty:
        push_dataframe_to_rds(df_doctors, 'doctors', engine)
    else:
        print("No doctor data generated for insertion.")
    
