from datetime import datetime
import random
from sqlalchemy import create_engine, text

def update_generate_departments(update_ids, engine):
    with engine.connect() as connection:
        for department_id in update_ids:
            updated_department = {
                'department_name': fake.job(),
                'updated_at': datetime.now() 
            }
            
            update_query = text("""
            UPDATE department
            SET department_name = :department_name, updated_at = :updated_at
            WHERE department_id = :department_id
            """)
            try:

                connection.execute(update_query, {
                    'department_name': updated_department['department_name'],
                    'updated_at': updated_department['updated_at'],
                    'department_id': department_id
                })
                connection.commit()
                print(f"Updated department_id: {department_id} with new values.")
            except Exception as e:
                print(f"Error updating department_id {department_id}: {e}")
    
def update_patients(engine):
    update_ids = update_records(engine, 'department', 'department_id')
    update_generate_departments(update_ids, engine)
    