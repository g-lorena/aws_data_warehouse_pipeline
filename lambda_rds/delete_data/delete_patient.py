from utils.db import update_records, delete_records


def delete_patients(engine):
    ids_to_delete = update_records(engine, 'patients', 'patient_id')
    delete_records('patients', 'patient_id', ids_to_delete)