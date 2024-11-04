
'''
patients (patient_id, name, age, gender, address).
appointments (appointment_id, patient_id, doctor_id, appointment_date, diagnosis).
Doctor Information: Information about doctors, their specializations, and their schedule.
doctors (doctor_id, name, specialty, location, hire_date).
Treatment and Diagnosis Records: Data about treatments administered during appointments.
treatments (treatment_id, appointment_id, medication, procedure_code, treatment_date).
CSV Files (Reference Data):

Procedures and Medications: External reference files containing details about medical procedures, medication names, and diagnostic codes.
procedures.csv (procedure_code, description, cost).
medications.csv (medication_id, name, category, cost).
'''