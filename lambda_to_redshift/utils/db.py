import pandas as pd 

def connect_to_redshift(REDSHIFT_DB, REDSHIFT_USER, REDSHIFT_PASSWORD, REDSHIFT_HOST):
    try:
        conn = psycopg2.connect(
                dbname=REDSHIFT_DB,
                user=REDSHIFT_USER,
                password=REDSHIFT_PASSWORD,
                host=REDSHIFT_HOST,
                port='5439'
        )
        return conn
    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")
     