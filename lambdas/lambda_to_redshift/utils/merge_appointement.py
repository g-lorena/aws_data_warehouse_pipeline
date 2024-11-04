

def merge_appointement_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE fact_appointment
        SET 
            appointment_id = stage_fact_appointment.appointment_id,
            patient_id = stage_fact_appointment.patient_id,
            doctor_id = stage_fact_appointment.doctor_id,
            appointment_date = stage_fact_appointment.appointment_date,
            appointment_type = stage_fact_appointment.appointment_type,
            diagnosis = stage_fact_appointment.diagnosis,
            created_at = stage_fact_appointment.created_at, 
            updated_at = stage_fact_appointment.updated_at
        FROM stage_fact_appointment
        WHERE fact_appointment.procedure_code = stage_fact_appointment.procedure_code
        AND fact_appointment.updated_at < stage_fact_appointment.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO fact_appointment (appointment_id, patient_id, doctor_id, appointment_date, appointment_type, appointment_type, diagnosis, created_at, updated_at)
        SELECT * FROM stage_fact_appointment
        WHERE appointment_id NOT IN (SELECT appointment_id FROM fact_appointment)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")

    cursor.execute("TRUNCATE TABLE stage_fact_appointment;")
    print("Merge completed and staging table cleared.")
    
    
