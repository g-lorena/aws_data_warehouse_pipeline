

def merge_doctor_table(cursor):
    '''
    merge_query = """
        MERGE INTO dim_doctors 
        USING stage_dim_doctors 
        ON dim_doctors.doctor_id = stage_dim_doctors.doctor_id
        WHEN MATCHED AND dim_doctors.updated_at < stage_dim_doctors.updated_at THEN
            UPDATE SET 
                first_name = stage_dim_doctors.first_name,
                last_name = stage_dim_doctors.last_name,
                specialization = stage_dim_doctors.specialization,
                department_id = stage_dim_doctors.department_id,
                hire_date = stage_dim_doctors.hire_date,
                created_at = stage_dim_doctors.created_at,
                updated_at = stage_dim_doctors.updated_at 
        WHEN NOT MATCHED THEN
            INSERT (doctor_id, first_name, last_name, specialization, department_id, hire_date, created_at, updated_at)
            VALUES (stage_dim_doctors.doctor_id, stage_dim_doctors.first_name, stage_dim_doctors.last_name, stage_dim_doctors.specialization, stage_dim_doctors.department_id, stage_dim_doctors.hire_date, stage_dim_doctors.created_at, stage_dim_doctors.updated_at);
    """
    cursor.execute(merge_query)
    '''
    cursor.execute("BEGIN;")

    update_query = """
        UPDATE dim_doctors
        SET 
            first_name = stage_dim_doctors.first_name,
            last_name = stage_dim_doctors.last_name,
            specialization = stage_dim_doctors.specialization,
            department_id = stage_dim_doctors.department_id,
            hire_date = stage_dim_doctors.hire_date,
            created_at = stage_dim_doctors.created_at,
            updated_at = stage_dim_doctors.updated_at
        FROM stage_dim_doctors
        WHERE dim_doctors.doctor_id = stage_dim_doctors.doctor_id
        AND dim_doctors.updated_at < stage_dim_doctors.updated_at;
    """
    cursor.execute(update_query)
    cursor.execute("COMMIT;")

    insert_query = """
        INSERT INTO dim_doctors (doctor_id, first_name, last_name, specialization, department_id, hire_date, created_at, updated_at)
        SELECT * FROM stage_dim_doctors
        WHERE doctor_id NOT IN (SELECT doctor_id FROM dim_doctors);
    """
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")

    cursor.execute("TRUNCATE TABLE stage_dim_doctors;")
    print("Merge completed and staging table cleared.")