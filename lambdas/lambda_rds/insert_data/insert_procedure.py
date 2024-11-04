from utils.db import push_dataframe_to_rds
from generate_data.procedure import generate_procedures
        
def insert_procedure_data(engine):
    df_procedures = generate_procedures(10)
    if not df_procedures.empty:
        push_dataframe_to_rds(df_procedures, 'procedure', engine)
    
