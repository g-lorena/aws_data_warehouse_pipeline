from utils.db import push_dataframe_to_rds

        
def insert_patient_data(df_patients, engine):
    
    if not df_patients.empty:
        push_dataframe_to_rds(df_patients, 'patients', engine)
    
