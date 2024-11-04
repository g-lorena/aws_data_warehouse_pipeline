

def merge_medication_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE dim_medication
        SET 
            medication_id = stage_dim_medication.medication_id,
            medication_name = stage_dim_medication.medication_name ,
            category = stage_dim_medication.category ,
            cost = stage_dim_medication.cost,
            created_at = stage_dim_medication.created_at, 
            updated_at = stage_dim_medication.updated_at
        FROM dim_medication
        WHERE dim_medication.medication_id = stage_dim_medication.medication_id
        AND dim_medication.updated_at < stage_dim_medication.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO dim_medication (medication_id, medication_name, category, cost, created_at, updated_at)
        SELECT * FROM stage_dim_medication
        WHERE medication_id NOT IN (SELECT medication_id FROM dim_medication)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")
    
    cursor.execute("TRUNCATE TABLE stage_dim_medication;")
    print("Merge completed and staging table cleared.")