from utils.db import update_records, delete_departement


def delete_departement(engine):
    ids_to_delete = update_records(engine, 'department', 'department_id')
    delete_departement('department', 'department_id', 'doctors', ids_to_delete)