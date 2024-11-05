from utils.db import update_records, delete_records


def delete_medications(engine):
    ids_to_delete = update_records(engine, 'medications', 'medication_id')
    delete_records(engine, 'medications', 'medication_id', ids_to_delete)