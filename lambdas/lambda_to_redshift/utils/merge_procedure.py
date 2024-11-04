

def merge_procedure_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE dim_procedure
        SET 
            procedure_code = stage_dim_procedure.procedure_code,
            procedure_description = stage_dim_procedure.procedure_description,
            procedure_cost = stage_dim_procedure.procedure_cost,
            created_at = stage_dim_procedure.created_at, 
            updated_at = stage_dim_procedure.updated_at
        FROM dim_procedure
        WHERE dim_procedure.procedure_code = stage_dim_procedure.procedure_code
        AND dim_procedure.updated_at < stage_dim_procedure.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO dim_procedure (procedure_code, procedure_description, procedure_cost, created_at, updated_at)
        SELECT * FROM stage_dim_procedure
        WHERE procedure_code NOT IN (SELECT procedure_code FROM dim_procedure)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")
    
    cursor.execute("TRUNCATE TABLE stage_dim_procedure;")
    print("Merge completed and staging table cleared.")