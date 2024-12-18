CREATE DATABASE Hospital;
USE Hospital;

CREATE TABLE Doctor (
    id BIGINT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    degree VARCHAR(50),
    years_of_exp TINYINT,
    specialization VARCHAR(50) NOT NULL,
    CHECK (degree IN ('Bachelor', 'Master', 'Doctoral'))
);

CREATE TABLE Patient (
    id BIGINT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(25),
    date_of_birth DATE,
    city VARCHAR(50),
    country VARCHAR(50),
    street_number INT,
    building_number INT,
    email VARCHAR(100) UNIQUE NOT NULL,
    CHECK (gender IN ('Male', 'Female'))
);

CREATE TABLE Specialization (
    name VARCHAR(50) PRIMARY KEY,
    start_date DATE,
    manager_id BIGINT,
    FOREIGN KEY (manager_id) REFERENCES Doctor(id)
);

CREATE TABLE Appointment (
    doctor_id BIGINT,
    day VARCHAR(25),
    shift_number TINYINT,
    clinic_id INT NOT NULL,
    PRIMARY KEY (doctor_id, day, shift_number),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(id) ON DELETE CASCADE,
    CHECK (shift_number BETWEEN 1 AND 6),
    CHECK (day IN ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'))
);

CREATE TABLE Clinic (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50),
    floor INT,
    specialization VARCHAR(50) NOT NULL,
    FOREIGN KEY (specialization) REFERENCES Specialization(name)
    ON UPDATE CASCADE ON DELETE CASCADE,
    CHECK (floor BETWEEN 0 AND 10)
);

CREATE TABLE Operation_details (
    id INT PRIMARY KEY IDENTITY(1,1),
    description VARCHAR(1000),
    date DATETIME,
    clinic_id INT NOT NULL,
    FOREIGN KEY (clinic_id) REFERENCES Clinic(id)
);

CREATE TABLE Room (
    id INT PRIMARY KEY IDENTITY(1,1),
    floor INT,
    capacity INT DEFAULT 0,
    CHECK (floor BETWEEN 0 AND 10)
);

CREATE TABLE Patient_Phone (
    patient_id BIGINT,
    phone VARCHAR(50),
    PRIMARY KEY (patient_id, phone),
    FOREIGN KEY (patient_id) REFERENCES Patient(id)
);

CREATE TABLE Nurse (
    id BIGINT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    supervizor_id BIGINT NOT NULL,
    FOREIGN KEY (supervizor_id) REFERENCES Doctor(id)
);

CREATE TABLE Take_care (
    nurse_id BIGINT,
    room_id INT,
    PRIMARY KEY (nurse_id, room_id),
    FOREIGN KEY (nurse_id) REFERENCES Nurse(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Room(id) ON DELETE CASCADE
);

CREATE TABLE Patient_stay (
    patient_id BIGINT,
    room_id INT,
    entry DATETIME,
    leave DATETIME,
    PRIMARY KEY (patient_id, room_id, entry),
    FOREIGN KEY (patient_id) REFERENCES Patient(id),
    FOREIGN KEY (room_id) REFERENCES Room(id)
);

CREATE TABLE Perform_operation (
    doctor_id BIGINT,
    operation_id INT,
    patient_id BIGINT,
    PRIMARY KEY (doctor_id, operation_id, patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(id),
    FOREIGN KEY (operation_id) REFERENCES Operation_details(id),
    FOREIGN KEY (patient_id) REFERENCES Patient(id)
);

CREATE TABLE Operation_help (
    nurse_id BIGINT,
    operation_id INT,
    PRIMARY KEY (nurse_id, operation_id),
    FOREIGN KEY (nurse_id) REFERENCES Nurse(id),
    FOREIGN KEY (operation_id) REFERENCES Operation_details(id)
);

INSERT INTO Doctor(id, first_name, last_name, degree, years_of_exp, specialization) 
VALUES 
(0, 'Yahya', 'Zakaria', 'Doctoral', 6, 'Otolaryngology (ENT)'),
(23011042, 'Islam', 'Najm', 'Doctoral', 9, 'General Medicine'),
(23011342, 'Abdullah', 'Yahya', 'Doctoral', 4, 'Ophthalmology'),
(23011400, 'Amr', 'Mohamed', 'Doctoral', 5, 'Pediatrics'),
(23011407, 'Fady', 'Youssery', 'Doctoral', 3, 'Gastroenterology'),
(23011552, 'Moaz', 'Maher', 'Doctoral', 8, 'Orthopedics'),
(23011652, 'Youssef', 'Mohamed', 'Doctoral', 7, 'Dermatology');

INSERT INTO Specialization(name, start_date, manager_id)
VALUES
    ('Otolaryngology (ENT)', '2024-01-01', 0),
    ('General Medicine', '2024-01-01', 23011042),
    ('Ophthalmology', '2024-01-01', 23011342),
    ('Pediatrics', '2024-01-01', 23011400),
    ('Gastroenterology', '2024-01-01', 23011407),
    ('Orthopedics', '2024-01-01', 23011552),
    ('Dermatology', '2024-01-01', 23011652);

ALTER TABLE Doctor 
ADD FOREIGN KEY (specialization) REFERENCES Specialization(name);

ALTER TABLE Appointment
ADD FOREIGN KEY (clinic_id) REFERENCES Clinic(id);
GO

CREATE TRIGGER trg_EnsureDoctorClinicSpecialization
ON Appointment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Doctor d ON i.doctor_id = d.id
        JOIN Clinic c ON i.clinic_id = c.id
        WHERE d.specialization != c.specialization
    )
    BEGIN
        RAISERROR ('Doctor''s specialization must match the clinic''s specialization.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_CheckRoomCapacity
ON Patient_stay
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Room r ON i.room_id = r.id
        LEFT JOIN Patient_stay ps
            ON ps.room_id = r.id AND ps.leave IS NULL
        WHERE r.capacity <= (
            SELECT COUNT(*)-1
            FROM Patient_stay ps_active
            WHERE ps_active.room_id = r.id AND ps_active.leave IS NULL
        )
    )
    BEGIN
        RAISERROR ('Room has reached its maximum capacity.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO