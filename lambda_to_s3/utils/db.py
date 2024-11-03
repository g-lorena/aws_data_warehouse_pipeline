import pandas as pd 
from sqlalchemy import create_engine, text, inspect
from datetime import datetime
import io

def connect_to_postgres(DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME):
    try:
        conn_str = f'postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
        engine = create_engine(conn_str)
        print("connection to PostgreSQL data successful !")
        return engine

    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")
        

def get_last_extraction_time(dynamo_table, table_name):
    response = dynamo_table.get_item(Key={"table_name": table_name})
    if 'Item' in response:
        return response['Item'].get('last_extraction_time')
    else: 
        return None
    
def update_last_extraction_time(dynamo_table, table_name):
    
    dynamo_table.update_item(
        Key={'table_name': table_name},
        UpdateExpression="SET last_extraction_time = :extraction_time",
        ExpressionAttributeValues={
            ':extraction_time': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    )
    '''
    dynamo_table.put_item(
        Item={
            "table_name":table_name,
            "last_extraction_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    )
    '''
def fetch_and_upload_to_s3(table_name, dynamo_table, engine, DST_BUCKET, RAW_FOLDER, s3):
    last_extraction_time = get_last_extraction_time(dynamo_table, table_name)
    
    if last_extraction_time in (None, ""): # premiere extraction
        query = f"""
            SELECT * FROM {table_name} 
        """
    else: 
        query = f"""
            SELECT * FROM {table_name} 
            WHERE updated_at > '{last_extraction_time}'
        """
    #created_at > '{last_extraction_time}'
    with engine.connect() as conn:
        df = pd.read_sql(query, conn)
        
        if df.empty:
            print(f"No new data to extract for table '{table_name}'.")
            
        else:
            update_last_extraction_time(dynamo_table, table_name)
            
            csv_buffer = io.StringIO()
            df.to_csv(csv_buffer, index=False)
            s3.put_object(
                Bucket=DST_BUCKET,
                Key=f"{RAW_FOLDER}/{table_name}/{table_name}_{datetime.now().strftime('%Y%m%d%H%M%S')}.csv",
                Body=csv_buffer.getvalue()
            )
        
            print(f"New data successfully extracted for table '{table_name}' and uploaded to S3.")
            
    