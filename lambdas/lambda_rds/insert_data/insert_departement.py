from utils.db import push_dataframe_to_rds
from generate_data.department import generate_departments

        
def insert_departement_data(engine):
    df_department = generate_departments(5)
    if not df_department.empty:
        push_dataframe_to_rds(df_department, 'department', engine)
    

    