import psycopg2

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
     
def get_last_extraction_time(table_name):
    response = dynamo_table.get_item(Key={"table_name": table_name})
    if 'Item' in response:
        return response['Item'].get('last_extraction_time')
    else: 
        return None