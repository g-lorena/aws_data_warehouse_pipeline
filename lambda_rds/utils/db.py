import pandas as pd 
from sqlalchemy import create_engine, text


def connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME):
    try:
        conn_str = f'postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
        engine = create_engine(conn_str)
        print("connection to PostgreSQL data successful !")
        return engine

    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")
        
        
def push_dataframe_to_rds(df, table_name, engine):
    try:
        # Load the DataFrame into the specified table
        df.to_sql(table_name, engine, if_exists='append', index=False)
        print(f"Data successfully loaded into '{table_name}' table.")
    except Exception as e:
        print(f"Error loading data into '{table_name}': {e}")
        
        
def update_records(engine, table_name, table_key_id):
    inspector = inspect(engine)
    if table_name not in inspector.get_table_names():
        print("Table '{table_name}' does not exist. Skipping insert.")
        return
    
    existing_ids_df = pd.read_sql("SELECT {table_key_id} FROM {table_name}", engine)
    dept_ids = existing_ids_df[table_key_id].tolist() # liste des departements à update
    
    num_updates = random.randint(1, min(5, len(dept_ids)))

    if not dept_ids:
        print("No existing records in '{table_name} to update.")
        return
    
    update_ids = random.sample(dept_ids, num_updates)
    return update_ids
    
    
        