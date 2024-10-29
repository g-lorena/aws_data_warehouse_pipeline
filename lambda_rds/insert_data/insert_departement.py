from utils.db import push_dataframe_to_rds
from generate_data.department import generate_departments

'''
inspector = inspect(engine)
    if 'department' not in inspector.get_table_names():
        print("Table 'department' does not exist. Skipping insert.")
        return
'''

        
def insert_departement_data(engine):
    df_departement = generate_departments(5)
    if not df_department.empty:
        push_dataframe_to_rds(df_department, 'department', engine)
    

    