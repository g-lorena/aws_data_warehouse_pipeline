from utils.db import push_dataframe_to_rds
from generate_data.doctor import generate_doctors
        
def insert_doctors_data(engine):
    df_doctors = generate_doctors(20, 5)
    if not df_doctors.empty:
        push_dataframe_to_rds(df_doctors, 'doctors', engine)
    
