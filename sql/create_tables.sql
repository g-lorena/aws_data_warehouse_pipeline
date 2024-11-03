--- MAIN TABLES 
CREATE TABLE IF NOT EXISTS dim_departement (
    department_id VARCHAR(50) PRIMARY KEY,
    department_name VARCHAR(100),
    department_location  VARCHAR(100),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_doctors (
    doctor_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialization VARCHAR(100), 
    department_id VARCHAR(50), 
    hire_date DATE, 
    created_at TIMESTAMP, 
    updated_at TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES dim_departement(department_id)
);

CREATE TABLE IF NOT EXISTS dim_medication (
    medication_id VARCHAR(50) PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL,
    category  VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_procedure (
    procedure_code VARCHAR(50) PRIMARY KEY,
    procedure_description VARCHAR(100) NOT NULL,
    procedure_cost DECIMAL(10, 2),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    gender VARCHAR(100),
    dob DATE,
    patient_address VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fact_appointment (
    appointment_id VARCHAR(50) PRIMARY KEY,
    patient_id VARCHAR(50),
    doctor_id VARCHAR(50), 
    appointment_date DATE, 
    appointment_type VARCHAR(100), 
    diagnosis VARCHAR(100), 
    created_at TIMESTAMP, 
    updated_at TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES dim_patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctors(doctor_id)
);

CREATE TABLE IF NOT EXISTS fact_treatment (
    treatment_id VARCHAR(50) PRIMARY KEY,
    appointment_id VARCHAR(50), 
    medication_id VARCHAR(50), 
    procedure_code VARCHAR(50), 
    treatment_date DATE,
    created_at TIMESTAMP, 
    updated_at TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES fact_appointment(appointment_id),
    FOREIGN KEY (medication_id) REFERENCES dim_medication(medication_id),
    FOREIGN KEY (procedure_code) REFERENCES dim_procedure(procedure_code)
);


CREATE TABLE IF NOT EXISTS stage_dim_departement (
    department_id VARCHAR(50) PRIMARY KEY,
    department_name VARCHAR(100),
    department_location  VARCHAR(100),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stage_dim_doctors (
    doctor_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialization VARCHAR(100), 
    department_id INT, 
    hire_date DATE, 
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stage_dim_medication (
    medication_id VARCHAR(50) PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL,
    category  VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stage_dim_procedure (
    procedure_code VARCHAR(50) PRIMARY KEY,
    procedure_description VARCHAR(100) NOT NULL,
    procedure_cost DECIMAL(10, 2),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

CREATE TABLE stage_dim_patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    gender VARCHAR(100)
    dob DATE,
    patient_address VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP, 
    updated_at TIMESTAMP
);

