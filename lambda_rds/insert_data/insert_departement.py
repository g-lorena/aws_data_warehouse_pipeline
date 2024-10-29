from utils.db import push_dataframe_to_rds

'''
inspector = inspect(engine)
    if 'department' not in inspector.get_table_names():
        print("Table 'department' does not exist. Skipping insert.")
        return
'''

        
def insert_departement_data(df_department, engine):
    
    if not df_department.empty:
        push_dataframe_to_rds(df_department, 'department', engine)
    

    