from utils.db import push_dataframe_to_rds
from generate_data.medication_prescriptions import generate_medications_prescriptions 

        
def insert_medications_data(engine, medication_codes):
    appointments_ids = get_tables_ids(engine, 'appointment_id', 'appointments')
    if not appointments_ids:
        print("No appointment_id found. Please insert appointments first.")
        return
    
    df_medications = generate_medications_prescriptions(100000, appointments_ids, medication_codes)
    if not df_medications.empty:
        push_dataframe_to_rds(df_medications, 'medications_prescriptions', engine)
    
