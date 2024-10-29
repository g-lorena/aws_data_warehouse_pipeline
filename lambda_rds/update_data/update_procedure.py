import pandas as pd
from datetime import datetime
import random
from utils.db import update_records
from sqlalchemy import create_engine, text

def update_generate_procedures(update_ids, engine):
    with engine.connect() as connection:
        for procedure_code in update_ids:
            updated_procedure = {
                'procedure_cost': round(random.uniform(100.0, 10000.0), 2),
                'updated_at': datetime.now() 
            }
            
            update_query = text("""
            UPDATE procedures
            SET procedure_cost = :procedure_cost, updated_at = :updated_at
            WHERE procedure_code = :procedure_code
            """)
            try:
                connection.execute(update_query, {
                    'procedure_cost': updated_procedure['procedure_cost'],
                    'updated_at': updated_procedure['updated_at'],
                    'procedure_code': procedure_code
                })
                connection.commit()
                print(f"Updated procedure_code: {procedure_code} with new values.")
            except Exception as e:
                print(f"Error updating procedure_code {procedure_code}: {e}")
    

def update_procedures(engine):
    update_ids = update_records(engine, 'procedures', 'procedure_code')
    update_generate_procedures(update_ids, engine)
    
    