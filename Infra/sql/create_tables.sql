CREATE TABLE dim_departement (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_location  VARCHAR(100),
    created_at DATE, 
    updated_at DATE
);

CREATE TABLE dim_doctors (
    doctor_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialization VARCHAR(100), 
    department_id INT, 
    hire_date DATE, 
    created_at DATE, 
    updated_at DATE
    FOREIGN KEY (department_id) REFERENCES dim_departement(department_id)
);

CREATE TABLE dim_medication (
    medication_id INT PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL,
    category  VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2),
    created_at DATE, 
    updated_at DATE
);

CREATE TABLE dim_procedure (
    procedure_code INT PRIMARY KEY,
    procedure_description VARCHAR(100) NOT NULL,
    procedure_cost DECIMAL(10, 2),
    created_at DATE, 
    updated_at DATE
);

CREATE TABLE dim_patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    gender VARCHAR(100)
    dob DATE,
    patient_address VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    created_at DATE, 
    updated_at DATE
);

CREATE TABLE fact_appointment (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT, 
    appointment_date DATE, 
    appointment_type VARCHAR(100), 
    diagnosis VARCHAR(100), 
    created_at DATE, 
    updated_at DATE,
    FOREIGN KEY (patient_id) REFERENCES dim_patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctors(doctor_id)
);

CREATE TABLE fact_treatment (
    treatment_id INT PRIMARY KEY,
    appointment_id INT, 
    medication_id INT, 
    procedure_code INT, 
    treatment_date DATE,
    created_at DATE, 
    updated_at DATE,
    FOREIGN KEY (appointment_id) REFERENCES fact_appointment(appointment_id),
    FOREIGN KEY (medication_id) REFERENCES dim_medication(medication_id),
    FOREIGN KEY (procedure_code) REFERENCES dim_procedure(procedure_code)
);

