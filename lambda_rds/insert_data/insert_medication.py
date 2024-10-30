from utils.db import push_dataframe_to_rds
from generate_data.medication import generate_medications 

        
def insert_medications_data(engine):
    df_medications = generate_medications(10)
    if not df_medications.empty:
        push_dataframe_to_rds(df_medications, 'medications', engine)
    
