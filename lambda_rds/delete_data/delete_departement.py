from utils.db import update_records, delete_records


def delete_departement(engine):
    ids_to_delete = update_records(engine, 'department', 'department_id')
    delete_records('department', 'department_id', ids_to_delete)