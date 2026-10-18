-- ============================================================================
-- ATTENDANCE SYSTEM - CORE QUERIES & HR REPORTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SEED DATA (Departments, Employees & Initial Records)
-- ----------------------------------------------------------------------------
INSERT INTO departments (department_id, name, code) VALUES
('dept-1', 'Engineering', 'ENG'),
('dept-2', 'Human Resources', 'HR'),
('dept-3', 'Product & Design', 'PRD')
ON CONFLICT DO NOTHING;

INSERT INTO employees (employee_id, employee_code, first_name, last_name, email, department_id, role, daily_target_hours) VALUES
('emp-1', 'EMP001', 'Alice', 'Smith', 'alice@company.com', 'dept-1', 'EMPLOYEE', 8.00),
('emp-2', 'EMP002', 'Bob', 'Jones', 'bob@company.com', 'dept-1', 'EMPLOYEE', 8.00),
('emp-3', 'EMP003', 'Carol', 'Danvers', 'carol@company.com', 'dept-2', 'HR', 8.00),
('emp-4', 'EMP004', 'David', 'Miller', 'david@company.com', 'dept-3', 'EMPLOYEE', 8.00)
ON CONFLICT DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. DAILY CHECK-IN OPERATION (Idempotent daily record creation + punch log)
-- ----------------------------------------------------------------------------
-- Step A: Upsert daily attendance record
INSERT INTO attendance_records (
    record_id, 
    employee_id, 
    attendance_date, 
    status, 
    first_check_in, 
    updated_at
)
VALUES (
    'rec-emp1-20261017', 
    'emp-1', 
    '2026-10-17', 
    'CHECKED_IN', 
    '2026-10-17 09:05:00', 
    CURRENT_TIMESTAMP
)
ON CONFLICT (employee_id, attendance_date) DO UPDATE SET
    status = 'CHECKED_IN',
    updated_at = CURRENT_TIMESTAMP;

-- Step B: Insert punch ledger record
INSERT INTO attendance_punches (
    punch_id, 
    record_id, 
    employee_id, 
    punch_type, 
    punched_at, 
    ip_address, 
    device_info
)
VALUES (
    'punch-1', 
    'rec-emp1-20261017', 
    'emp-1', 
    'CHECK_IN', 
    '2026-10-17 09:05:00', 
    '192.168.1.10', 
    'Chrome on Windows 11'
);

-- ----------------------------------------------------------------------------
-- 3. CHECK-OUT OPERATION & WORKING HOURS CALCULATION (Flexible Hours)
-- ----------------------------------------------------------------------------
-- Step A: Log the CHECK_OUT punch
INSERT INTO attendance_punches (
    punch_id, 
    record_id, 
    employee_id, 
    punch_type, 
    punched_at, 
    ip_address, 
    device_info
)
VALUES (
    'punch-2', 
    'rec-emp1-20261017', 
    'emp-1', 
    'CHECK_OUT', 
    '2026-10-17 17:35:00', 
    '192.168.1.10', 
    'Chrome on Windows 11'
);

-- Step B: Update the daily record with total minutes & final status
-- (For SQLite: uses (strftime('%s', last) - strftime('%s', first)) / 60)
-- Flexible criteria: >= 480 mins (8h) = PRESENT, >= 240 mins (4h) = HALF_DAY, else UNDER_HOURS
UPDATE attendance_records
SET 
    last_check_out = '2026-10-17 17:35:00',
    total_work_minutes = ROUND((strftime('%s', '2026-10-17 17:35:00') - strftime('%s', first_check_in)) / 60),
    effective_work_minutes = ROUND((strftime('%s', '2026-10-17 17:35:00') - strftime('%s', first_check_in)) / 60),
    status = CASE 
        WHEN ROUND((strftime('%s', '2026-10-17 17:35:00') - strftime('%s', first_check_in)) / 60) >= 480 THEN 'PRESENT'
        WHEN ROUND((strftime('%s', '2026-10-17 17:35:00') - strftime('%s', first_check_in)) / 60) >= 240 THEN 'HALF_DAY'
        ELSE 'UNDER_HOURS'
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE record_id = 'rec-emp1-20261017';


-- ----------------------------------------------------------------------------
-- 4. EMPLOYEE VIEW: CURRENT ATTENDANCE STATUS & TODAY'S METRICS
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_code,
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(ar.status, 'NOT_CHECKED_IN') AS attendance_status,
    ar.first_check_in,
    ar.last_check_out,
    ROUND(COALESCE(ar.effective_work_minutes, 0) / 60.0, 2) AS total_hours_worked,
    e.daily_target_hours AS target_hours,
    CASE 
        WHEN ar.status = 'CHECKED_IN' THEN 
            ROUND((strftime('%s', CURRENT_TIMESTAMP) - strftime('%s', ar.first_check_in)) / 3600.0, 2)
        ELSE ROUND(COALESCE(ar.effective_work_minutes, 0) / 60.0, 2)
    END AS elapsed_hours_today
FROM employees e
LEFT JOIN attendance_records ar 
    ON e.employee_id = ar.employee_id 
    AND ar.attendance_date = '2026-10-17'
WHERE e.employee_id = 'emp-1';


-- ----------------------------------------------------------------------------
-- 5. EMPLOYEE ATTENDANCE HISTORY
-- ----------------------------------------------------------------------------
SELECT 
    ar.attendance_date,
    ar.first_check_in,
    ar.last_check_out,
    ROUND(ar.effective_work_minutes / 60.0, 2) AS hours_worked,
    ar.status,
    CASE 
        WHEN (ar.effective_work_minutes / 60.0) >= e.daily_target_hours THEN 'Target Met'
        WHEN ar.status = 'HALF_DAY' THEN 'Half Day'
        ELSE 'Deficit'
    END AS day_evaluation
FROM attendance_records ar
JOIN employees e ON ar.employee_id = e.employee_id
WHERE ar.employee_id = 'emp-1'
ORDER BY ar.attendance_date DESC;


-- ----------------------------------------------------------------------------
-- 6. HR REPORT: DAILY ATTENDANCE DASHBOARD
-- Shows real-time check-in status of all active employees for any given date
-- ----------------------------------------------------------------------------
SELECT 
    d.name AS department_name,
    e.employee_code,
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(ar.status, 'ABSENT') AS attendance_status,
    ar.first_check_in,
    ar.last_check_out,
    ROUND(COALESCE(ar.effective_work_minutes, 0) / 60.0, 2) AS hours_worked,
    CASE 
        WHEN ar.first_check_in IS NULL THEN 'Absent / No Check-in'
        WHEN ar.last_check_out IS NULL THEN 'Currently In Office / Working'
        ELSE 'Completed Day'
    END AS activity_state
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN attendance_records ar 
    ON e.employee_id = ar.employee_id 
    AND ar.attendance_date = '2026-10-17'
WHERE e.is_active = TRUE
ORDER BY d.name, e.last_name;


-- ----------------------------------------------------------------------------
-- 7. HR REPORT: MONTHLY ATTENDANCE ROLLUP & WORKING HOURS SUMMARY
-- Aggregates monthly totals per employee (Days worked, total hours, average/day)
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_code,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.name AS department_name,
    COUNT(CASE WHEN ar.status IN ('PRESENT', 'HALF_DAY', 'UNDER_HOURS', 'CHECKED_OUT') THEN 1 END) AS total_days_attended,
    COUNT(CASE WHEN ar.status = 'PRESENT' THEN 1 END) AS full_days_count,
    COUNT(CASE WHEN ar.status = 'HALF_DAY' THEN 1 END) AS half_days_count,
    ROUND(SUM(COALESCE(ar.effective_work_minutes, 0)) / 60.0, 2) AS total_monthly_hours,
    ROUND(
        AVG(CASE WHEN ar.effective_work_minutes > 0 THEN ar.effective_work_minutes / 60.0 ELSE NULL END), 
        2
    ) AS avg_daily_hours,
    ROUND(
        SUM(COALESCE(ar.effective_work_minutes, 0) / 60.0) - 
        (COUNT(CASE WHEN ar.status IN ('PRESENT', 'HALF_DAY') THEN 1 END) * e.daily_target_hours), 
        2
    ) AS balance_hours_vs_target
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN attendance_records ar 
    ON e.employee_id = ar.employee_id 
    AND strftime('%Y-%m', ar.attendance_date) = '2026-10'
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.employee_code, e.first_name, e.last_name, d.name, e.daily_target_hours
ORDER BY d.name, total_monthly_hours DESC;


-- ----------------------------------------------------------------------------
-- 8. HR REPORT: INCOMPLETE PUNCH & EXCEPTION REPORT
-- Identifies records where check-in occurred but check-out was missed
-- ----------------------------------------------------------------------------
SELECT 
    ar.attendance_date,
    e.employee_code,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.name AS department_name,
    ar.first_check_in,
    ar.status,
    'Missing Check-out Punch' AS exception_type
FROM attendance_records ar
JOIN employees e ON ar.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE ar.first_check_in IS NOT NULL 
  AND ar.last_check_out IS NULL 
  AND ar.attendance_date < CURRENT_DATE
ORDER BY ar.attendance_date DESC;
