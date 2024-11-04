

def merge_departement_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE dim_departement
        SET
           department_id = stage_dim_departement.department_id,
           department_name = stage_dim_departement.department_name,
           department_location = stage_dim_departement.department_location,
           created_at = stage_dim_departement.created_at,
           updated_at = stage_dim_departement.updated_at
        FROM dim_departement
        WHERE dim_departement.department_id = stage_dim_departement.department_id
        AND dim_departement.updated_at < stage_dim_departement.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO dim_departement (department_id, department_name, department_location, created_at, updated_at)
        SELECT * FROM stage_dim_departement
        WHERE department_id NOT IN (SELECT department_id FROM dim_departement)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")
    
    cursor.execute("TRUNCATE TABLE stage_dim_departement;")
    print("Merge completed and staging table cleared.")