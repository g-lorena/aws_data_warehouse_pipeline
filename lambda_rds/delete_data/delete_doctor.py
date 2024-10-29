from utils.db import update_records, delete_records


def delete_doctors(engine):
    ids_to_delete = update_records(engine, 'doctors', 'doctor_id')
    delete_records('doctors', 'doctor_id', ids_to_delete)