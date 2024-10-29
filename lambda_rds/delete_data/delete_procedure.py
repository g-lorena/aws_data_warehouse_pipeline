from utils.db import update_records, delete_records


def delete_procedures(engine):
    ids_to_delete = update_records(engine, 'procedures', 'procedure_code')
    delete_records('procedures', 'procedure_code', ids_to_delete)