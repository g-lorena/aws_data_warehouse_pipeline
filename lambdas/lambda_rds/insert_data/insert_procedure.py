from utils.db import push_dataframe_to_rds
from generate_data.procedures_performed import generate_procedures_performed
        
def insert_procedure_data(engine, procedure_codes):
    appointments_ids = get_tables_ids(engine, 'appointment_id', 'appointments')
    if not appointments_ids:
        print("No appointment_id found. Please insert appointments first.")
        return
    
    df_procedures = generate_procedures_performed(100000, procedure_codes, appointments_ids)
    if not df_procedures.empty:
        push_dataframe_to_rds(df_procedures, 'procedure', engine)
    
