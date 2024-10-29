from utils.db import push_dataframe_to_rds

        
def insert_patient_data(df_doctors, engine):
    
    if not df_doctors.empty:
        push_dataframe_to_rds(df_doctors, 'doctors', engine)
    
