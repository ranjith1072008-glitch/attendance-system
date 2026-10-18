# Muthayammal Engineering College (Autonomous)
## Student Attendance Management System - Final Documentation & Idea Specification

---

## 1. Project Directory & Saved Assets

All project files, database schemas, and documentation have been structured and saved in:
📁 **`C:\Users\SSC\.gemini\antigravity\scratch\attendance-system\`**

### File Manifest:
- [index.html](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/index.html) — Final Standalone Attendance Dashboard application with embedded MEC logo and offline persistence.
- [README.md](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/README.md) — Project guide and execution instructions.
- [IDEA_AND_ARCHITECTURE.md](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/docs/IDEA_AND_ARCHITECTURE.md) — Comprehensive technical architecture specification and ER model.
- [server.js](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/server.js) — Lightweight native Node.js web server (`http://localhost:3000`).
- [student_schema.sql](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/student_schema.sql) — Production SQL database DDL schema.
- [attendance.db](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/attendance.db) — Live SQLite database storing permanent student and attendance records.
- [logo.png](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/logo.png) — Official Muthayammal Engineering College logo.

---

## 2. Core Idea & Business Logic Breakdown

### 2.1 One‑Time Student Registration (`Student Details`)
- Faculty enrols a student **once** by entering:
  - Student Full Name
  - Roll Number / Register Number
  - Academic Year (`I`, `II`, `III`, `IV`)
  - Department
  - Section
- Once saved, the student becomes a **permanent record**. Faculty never re‑enters their information again.

### 2.2 Department & Section Hierarchy Matrix
The system dynamically governs which sections can be selected based on the department:

| Department               | Allowed Sections                |
|:------------------------|:--------------------------------|
| **CSE**                 | Section **A, B, C, D, E**       |
| **MECH**                | Section **A, B, C**             |
| **EEE**                 | Section **A, B, C, D**          |
| **BIO‑TECH**            | Section **A** only              |
| **CSE [CYBER SECURITY]**| Section **A** only              |
| **CSE [AI&ML]**         | Section **A** only              |
| **CSE [CSBS]**          | Section **A** only              |
| **CSE [VLSI]**          | Section **A** only              |
| **ECE**                 | Section **A, B, C, D**          |
| **IT**                  | Section **A, B, C, D**          |

### 2.3 Next‑Day Automatic Default `ABSENT`
- When the date changes or faculty selects a new date, all students default to **`ABSENT`** (red badge).
- Faculty only needs to tap **`P`** (Present), **`HD`** (Half Day), or **`OD`** (On Duty).
- Batch controls (**`All Present`** and **`All Absent`**) allow 1‑click roster updates.

### 2.4 Integrity & Non‑Destructive Design
- The `Remove` / delete action has been purposefully eliminated from daily roll‑call to protect permanent records from accidental deletion.
- Pure department names without cluttered bracketed text.
- Zero emojis across all interface elements.

---

## 3. How to Launch & Use

> **[!TIP]**
> **To Open Directly in Browser:**
> Double‑click [index.html](file:///C:/Users/SSC/.gemini/antigravity/scratch/attendance-system/index.html) in your file explorer.
>
> **To Run via Node.js Server:**
> ```bash
> cd "C:\Users\SSC\.gemini\antigravity\scratch\attendance-system"
> node server.js
> ```
> Visit: `http://localhost:3000`

---
