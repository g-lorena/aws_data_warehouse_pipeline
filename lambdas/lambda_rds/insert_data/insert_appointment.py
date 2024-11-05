from utils.db import push_dataframe_to_rds, get_tables_ids
from generate_data.appointment import generate_appointments

def insert_appointments_data(engine):
    doctor_ids = get_tables_ids(engine, 'doctor_id', 'doctors')
    patient_ids = get_tables_ids(engine, 'patient_id', 'patients')
    if not doctor_ids:
        print("No doctor_id found. Please insert doctors first.")
        return
    if not patient_ids:
        print("No patient_id found. Please insert patients first.")
        return

    df_appointments = generate_appointments(30, doctor_ids, patient_ids)

    if not df_appointments.empty:
        push_dataframe_to_rds(df_appointments, 'appointments', engine)
    else:
        print("No appointment data generated for insertion.")

