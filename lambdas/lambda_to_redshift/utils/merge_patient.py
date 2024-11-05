

def merge_patient_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE dim_patients
        SET 
            patient_id = stage_dim_patients.patient_id,
            first_name = stage_dim_patients.first_name,
            last_name = stage_dim_patients.last_name,
            gender = stage_dim_patients.gender,
            dob = stage_dim_patients.dob,
            patient_address = stage_dim_patients.patient_address,
            city = stage_dim_patients.city,
            country = stage_dim_patients.country,
            created_at = stage_dim_patients.created_at, 
            updated_at = stage_dim_patients.updated_at
        FROM dim_patients
        WHERE dim_patients.patient_id = stage_dim_patients.patient_id
        AND dim_patients.updated_at < stage_dim_patients.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO dim_patients (patient_id, first_name, last_name, gender, dob, patient_address, city, country, created_at, updated_at)
        SELECT * FROM stage_dim_patients
        WHERE patient_id NOT IN (SELECT patient_id FROM dim_patients)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")
    
    cursor.execute("TRUNCATE TABLE stage_dim_patients;")
    print("Merge completed and staging table cleared.")
    
    
    