

def merge_treatment_table(cursor):
    cursor.execute("BEGIN;")
    
    update_query = """
        UPDATE fact_treatment
        SET 
            treatment_id = stage_fact_treatment.treatment_id,
            appointment_id = stage_fact_treatment.appointment_id,
            medication_id = stage_fact_treatment.medication_id,
            procedure_code = stage_fact_treatment.procedure_code,
            treatment_date = stage_fact_treatment.treatment_date,
            created_at = stage_fact_treatment.created_at, 
            updated_at = stage_fact_treatment.updated_at
        FROM stage_fact_treatment
        WHERE fact_treatment.treatment_id = stage_fact_treatment.treatment_id
        AND fact_treatment.updated_at < stage_fact_treatment.updated_at
    """
    
    cursor.execute(update_query)
    
    cursor.execute("COMMIT;")
    
    insert_query = """
        INSERT INTO fact_treatment (treatment_id, appointment_id, medication_id, procedure_code, treatment_date, created_at, updated_at)
        SELECT * FROM stage_fact_treatment
        WHERE treatment_id NOT IN (SELECT treatment_id FROM fact_treatment)
    """
    
    cursor.execute(insert_query)
    cursor.execute("COMMIT;")

    cursor.execute("TRUNCATE TABLE stage_fact_treatment;")
    print("Merge completed and staging table cleared.")