import psycopg2

from sqlalchemy import create_engine 

from generate_data.patients import generate_patients
from generate_data.doctors import generate_doctors
from generate_data.appointments import generate_appointments
from generate_data.treatments import generate_treatments 

# connect to 

DB_USERNAME = os.environ.get("DB_USERNAME")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_NAME = os.environ.get("DB_NAME")
DB_HOST = 'os.environ.get("DB_HOST")'
REGION = os.environ.get("REGION")
DB_PORT = '5432'


def connect_to_postgres():
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

def lambda_handler(event, context):
    engine = connect_to_postgres()
    
    df_patients = generate_patients(100)
    df_treatment = generate_treatments(300, 200)
    df_doctors = generate_doctors(20)
    df_appointment = generate_appointments(200, 100, 20)

    push_dataframe_to_rds(df_patients, 'patients', engine)
    push_dataframe_to_rds(df_treatment, 'treatments', engine)
    push_dataframe_to_rds(df_doctors, 'doctors', engine)
    push_dataframe_to_rds(df_appointment, 'appointment', engine)
    
    engine.dispose
    
    
    
    
    