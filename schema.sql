-- ============================================================================
-- ATTENDANCE MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Compatible with PostgreSQL and SQLite (with standard ANSI SQL types)
-- ============================================================================

-- Enable foreign key support (SQLite specific pragmas can be executed by clients)
-- PRAGMA foreign_keys = ON;

-- 1. DEPARTMENTS TABLE
CREATE TABLE IF NOT EXISTS departments (
    department_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. EMPLOYEES TABLE
CREATE TABLE IF NOT EXISTS employees (
    employee_id VARCHAR(36) PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department_id VARCHAR(36) REFERENCES departments(department_id) ON DELETE SET NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE', -- 'EMPLOYEE', 'HR', 'MANAGER'
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    daily_target_hours NUMERIC(4,2) DEFAULT 8.00, -- Flexible shift target (e.g., 8 hours)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ATTENDANCE DAILY RECORDS TABLE
-- Aggregated daily attendance record for fast reporting & status queries
CREATE TABLE IF NOT EXISTS attendance_records (
    record_id VARCHAR(36) PRIMARY KEY,
    employee_id VARCHAR(36) NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'NOT_CHECKED_IN',
    -- Status Enum values: 
    -- 'NOT_CHECKED_IN', 'CHECKED_IN', 'CHECKED_OUT', 'PRESENT', 'HALF_DAY', 'UNDER_HOURS', 'ABSENT'
    first_check_in TIMESTAMP NULL,
    last_check_out TIMESTAMP NULL,
    total_work_minutes INTEGER NOT NULL DEFAULT 0,
    total_break_minutes INTEGER NOT NULL DEFAULT 0,
    effective_work_minutes INTEGER NOT NULL DEFAULT 0,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_employee_date UNIQUE (employee_id, attendance_date)
);

-- 4. ATTENDANCE PUNCHES TABLE
-- Immutable event ledger for all biometric / web check-ins and check-outs
CREATE TABLE IF NOT EXISTS attendance_punches (
    punch_id VARCHAR(36) PRIMARY KEY,
    record_id VARCHAR(36) NOT NULL REFERENCES attendance_records(record_id) ON DELETE CASCADE,
    employee_id VARCHAR(36) NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    punch_type VARCHAR(10) NOT NULL, -- 'CHECK_IN' or 'CHECK_OUT'
    punched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NULL,
    device_info VARCHAR(255) NULL,
    location_coords VARCHAR(100) NULL,
    is_manual_entry BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. ATTENDANCE ADJUSTMENT / REGULARIZATION REQUESTS TABLE
-- Allows HR or Employees to resolve missed check-ins/check-outs
CREATE TABLE IF NOT EXISTS attendance_adjustments (
    adjustment_id VARCHAR(36) PRIMARY KEY,
    record_id VARCHAR(36) NOT NULL REFERENCES attendance_records(record_id) ON DELETE CASCADE,
    employee_id VARCHAR(36) NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    requested_punch_type VARCHAR(10) NOT NULL, -- 'CHECK_IN', 'CHECK_OUT'
    requested_time TIMESTAMP NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    reviewed_by VARCHAR(36) NULL REFERENCES employees(employee_id),
    reviewed_at TIMESTAMP NULL,
    reviewer_comments TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PERFORMANCE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_attendance_records_date ON attendance_records(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_employee_date ON attendance_records(employee_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_status ON attendance_records(status);
CREATE INDEX IF NOT EXISTS idx_attendance_punches_employee ON attendance_punches(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_punches_record ON attendance_punches(record_id);
CREATE INDEX IF NOT EXISTS idx_attendance_punches_time ON attendance_punches(punched_at);
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department_id);
