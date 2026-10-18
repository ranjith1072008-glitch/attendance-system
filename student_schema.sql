-- ============================================================================
-- STUDENT ATTENDANCE MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Designed for Schools, Colleges, Universities & Institutes
-- ============================================================================

-- 1. COURSES / CLASSES TABLE
CREATE TABLE IF NOT EXISTS classes (
    class_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,     -- e.g. "B.Tech CSE - 3rd Year", "Grade 11-A"
    code VARCHAR(20) NOT NULL UNIQUE,      -- e.g. "CSE-3", "G11A"
    department VARCHAR(100) NOT NULL,      -- e.g. "Computer Science & Engineering"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. STUDENTS TABLE (Replaces Employees)
CREATE TABLE IF NOT EXISTS students (
    student_id VARCHAR(36) PRIMARY KEY,
    roll_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "23CS101", "REG-5021"
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NULL,
    class_id VARCHAR(36) REFERENCES classes(class_id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    required_daily_hours NUMERIC(4,2) DEFAULT 6.00, -- e.g. 6.0 college/class hours
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. STUDENT DAILY ATTENDANCE RECORDS TABLE
CREATE TABLE IF NOT EXISTS student_attendance_records (
    record_id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'NOT_CHECKED_IN',
    -- Status Enum values:
    -- 'NOT_CHECKED_IN', 'CHECKED_IN', 'PRESENT', 'HALF_DAY', 'UNDER_HOURS', 'ABSENT'
    first_check_in TIMESTAMP NULL,          -- Campus / School Entry Time
    last_check_out TIMESTAMP NULL,         -- Campus / School Exit Time
    total_study_minutes INTEGER NOT NULL DEFAULT 0,
    effective_study_minutes INTEGER NOT NULL DEFAULT 0,
    remarks TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_date UNIQUE (student_id, attendance_date)
);

-- 4. STUDENT ATTENDANCE PUNCHES TABLE (Campus Gate / Biometric / RFID Log)
CREATE TABLE IF NOT EXISTS student_attendance_punches (
    punch_id VARCHAR(36) PRIMARY KEY,
    record_id VARCHAR(36) NOT NULL REFERENCES student_attendance_records(record_id) ON DELETE CASCADE,
    student_id VARCHAR(36) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    punch_type VARCHAR(10) NOT NULL,       -- 'CHECK_IN' (Entry) or 'CHECK_OUT' (Exit)
    punched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gate_name VARCHAR(50) DEFAULT 'Main Gate',
    device_info VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for lightning fast roll-call and faculty reports
CREATE INDEX IF NOT EXISTS idx_stud_attendance_date ON student_attendance_records(attendance_date);
CREATE INDEX IF NOT EXISTS idx_stud_attendance_student_date ON student_attendance_records(student_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_students_roll ON students(roll_number);
CREATE INDEX IF NOT EXISTS idx_students_class ON students(class_id);
