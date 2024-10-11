from sqlalchemy import create_engine 

from generate_data.patient import generate_patients
from generate_data.doctor import generate_doctors
from generate_data.appointment import generate_appointments
from generate_data.treatment import generate_treatments 
from generate_data.procedure import generate_procedures
from generate_data.medication import generate_medications
from generate_data.department import generate_departments
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
    df_appointment = generate_appointments(200, 100, 20, 10)
    df_medication = generate_medications(10)
    df_departement = generate_departments(5)

    push_dataframe_to_rds(df_patients, 'patients', engine)
    push_dataframe_to_rds(df_treatment, 'treatments', engine)
    push_dataframe_to_rds(df_doctors, 'doctors', engine)
    push_dataframe_to_rds(df_appointment, 'appointment', engine)
    push_dataframe_to_rds(df_medication, 'medication', engine)
    
    engine.dispose
    
    
    
    
    