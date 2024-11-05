from utils.db import push_dataframe_to_rds, get_tables_ids
from generate_data.treatment import generate_treatments

def insert_treatment_data(engine):
    appointment_ids = get_tables_ids(engine, 'appointment_id', 'appointments')
    procedure_ids = get_tables_ids(engine, 'procedure_code', 'procedure')
    medications_ids = get_tables_ids(engine, 'medication_id', 'medications')
    
    if not appointment_ids:
        print("No appointment_id found. Please insert appointments first.")
        return
    if not procedure_ids:
        print("No procedure_code found. Please insert procedure first.")
        return
    if not medications_ids:
        print("No medication_id found. Please insert medications first.")
        return
    
    df_treatement = generate_treatments(20, appointment_ids, procedure_ids, medications_ids)
    
    if not df_treatement.empty:
        push_dataframe_to_rds(df_treatement, 'treatement', engine)
    else:
        print("No appointment data generated for insertion.")
