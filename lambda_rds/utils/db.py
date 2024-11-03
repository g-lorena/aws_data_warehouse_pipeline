import pandas as pd 
from sqlalchemy import create_engine, text, inspect
from datetime import datetime
import random

def connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME):
    try:
        conn_str = f'postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
        engine = create_engine(conn_str)
        print("connection to PostgreSQL data successful !")
        return engine

    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")

def update_last_extraction_time(table_name, dynamo_table): 
    try:
        dynamo_table.update_item(
            Key={'table_name': table_name},
            UpdateExpression="SET last_update_time = :update_time",
            ExpressionAttributeValues={
                ':update_time': datetime.now().strftime("%Y-%m-%d %H:%M:%S")  
            },
            ConditionExpression="attribute_exists(table_name)" 
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            dynamo_table.put_item(
                Item={
                    "table_name": table_name,
                    "last_update_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                    "last_extraction_time": ""  # Initialise avec une chaîne vide pour la première iteration
                }
            )
        else:
            raise
     
        
def push_dataframe_to_rds(df, table_name, engine):
    try:
        if engine is None:
            print("No database connection available.")
            return
        
        # Load the DataFrame into the specified table
        df.to_sql(table_name, engine, if_exists='append', index=False)
        print(f"Data successfully loaded into '{table_name}' table.")
    except Exception as e:
        print(f"Error loading data into '{table_name}': {e}")
        
        
def update_records(engine, table_name, table_key_id):
    try: 
        if engine is None:
            print("No database connection available.")
            return
    
        inspector = inspect(engine)
        if table_name not in inspector.get_table_names():
            print(f"Table '{table_name}' does not exist. Skipping insert.")
            return []
        
        existing_ids_df = pd.read_sql(f"SELECT {table_key_id} FROM {table_name}", engine)
        
        if existing_ids_df is None or existing_ids_df.empty:
            print(f"No existing records in '{table_name}' to update.")
            return []
        
        dept_ids = existing_ids_df[table_key_id].tolist() # liste des departements à update
        
        num_updates = random.randint(1, min(5, len(dept_ids)))

        if not dept_ids:
            print(f"No existing records in '{table_name} to update.")
            return []
        
        update_ids = random.sample(dept_ids, num_updates)
        return update_ids
    except Exception as e:
        print(f"Error during update operation: {e}")
        return []


def delete_records(engine, table_name, table_key_id, delete_ids):
    if engine is None:
        print("No database connection available.")
        return
    
    delete_query = text(f"DELETE FROM {table_name} WHERE {table_key_id} = :id")
    with engine.connect() as connection:
        for delete_id in delete_ids:
            try:
                result = connection.execute(delete_query, {'id': delete_id})
                
                if result.rowcount == 0:
                    print(f"No record found with {table_key_id} = {delete_id} in table {table_name}. Skipping deletion.")
                else:
                    print(f"Deleted record with {table_key_id}: {delete_id} in table {table_name}")
                
            
                connection.commit()
            except Exception as e:
                    print(f"Error deleting record with {table_key_id} {delete_id}: {e}")
    
def delete_departement(engine, table_name, table_key_id, doctor_table_name, delete_ids):
    if engine is None:
        print("No database connection available.")
        return
    
    check_doctors_query = text(f"SELECT COUNT(*) FROM {doctor_table_name} WHERE department_id = :department_id")
    delete_department_query = text(f"DELETE FROM {table_name} WHERE {table_key_id} = :id")
    with engine.connect() as connection:
        for delete_id in delete_ids:
            try:
                result = connection.execute(check_doctors_query, {'department_id': delete_id})
                doctor_count = result.fetchone()[0]
                
                if doctor_count > 0:
                    print(f"Cannot delete department {delete_id} as it has {doctor_count} assigned doctors.")
                else:
                    # aucun docteur assigné
                    connection.execute(delete_department_query, {'department_id': delete_id})
                    print(f"Deleted department {delete_id}.")
            except Exception as e:
                print(f"Error occurred while trying to delete department {delete_id}: {e}")
            
 
      
def get_departement_ids(engine):
    if engine is None:
        print("No database connection available.")
        return
    
    try:
        existing_departments = pd.read_sql("SELECT department_id FROM department", engine)
        if existing_departments is not None or not existing_departments.empty:
            department_ids = existing_departments['department_id'].tolist()
            return department_ids
        else:
            print('No departments found.')
            return []
    
    except Exception as e:
        print(f"Error fetching department IDs: {e}")
        return []

      