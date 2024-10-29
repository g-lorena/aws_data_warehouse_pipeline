from utils.db import push_dataframe_to_rds

        
def insert_patient_data(df_medications, engine):
    
    if not df_medications.empty:
        push_dataframe_to_rds(df_medications, 'medications', engine)
    
