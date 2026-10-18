# Muthayammal Engineering College (Autonomous)
## Student Attendance Management System

A dedicated, lightweight, and permanent academic roll-call attendance system created for **Muthayammal Engineering College (Autonomous)**.

> Works 100% offline — just open `index.html` in any browser. No internet, no login, no installation required.

---

## Live Demo (GitHub Pages)
If hosted via GitHub Pages, open directly at:
```
https://<your-username>.github.io/attendance-system/
```

---

## Folder Structure

```text
attendance-system/
├── index.html                    # Complete standalone Application (Open directly in browser)
├── server.js                     # Optional: Zero-dependency local Node.js server (http://localhost:3000)
├── logo.png                      # Official MEC College Logo
├── student_schema.sql            # Relational Database DDL Schema
├── reports.sql                   # SQL report queries
├── schema.sql                    # SQLite schema
├── Student_Attendance_Idea.md    # Idea overview (root level)
├── .gitignore                    # Git ignore rules
│
└── docs/
    ├── IDEA_AND_ARCHITECTURE.md       # Exhaustive Architectural Specification & Design Document
    └── Student_Attendance_Idea.md     # Full idea & specification document
```

---

## Key Features

1. **Official Institutional Header**
   - Muthayammal Engineering College (Autonomous) logo embedded.
   - Clean formal layout — zero emojis.

2. **Page 1 — Student Details (One-Time Permanent Registry)**
   - Enrol students once: Full Name, Roll Number, Academic Year, Department, Section.
   - Records permanently stored in `localStorage` — never re-enter again.

3. **Page 2 — Student Attendance Register**
   - Select Department, Academic Year, Section, and Date.
   - The enrolled class roster appears instantly.
   - All students default to **ABSENT** on any new date.
   - Mark **P** (Present), **HD** (Half Day), **OD** (On Duty) per student.
   - Batch buttons: **All Present** | **All Absent**.

4. **Department & Section Configuration**

   | Department | Sections |
   |:---|:---|
   | **CSE** | A, B, C, D, E |
   | **MECH** | A, B, C |
   | **EEE** | A, B, C, D |
   | **BIO-TECH** | A |
   | **CSE [CYBER SECURITY]** | A |
   | **CSE [AI&ML]** | A |
   | **CSE [CSBS]** | A |
   | **CSE [VLSI]** | A |
   | **ECE** | A, B, C, D |
   | **IT** | A, B, C, D |

5. **Non-Destructive Roll Call**
   - Student delete/remove option removed from daily roll call — protects permanent academic records.

---

## How to Run

### Option A: Direct Browser Launch (Simplest — Recommended)
Double-click **`index.html`** or open it in Chrome, Edge, or Firefox. Runs fully offline with automatic persistence.

### Option B: Local Node.js Server
```bash
cd attendance-system
node server.js
```
Then open: `http://localhost:3000`

---

## How to Host on GitHub Pages

1. Create a new repository on GitHub (e.g., `attendance-system`)
2. Push all project files to the `main` branch
3. Go to **Settings → Pages → Source → Deploy from branch → main / root**
4. GitHub will publish the site at:
   ```
   https://<your-username>.github.io/attendance-system/
   ```

---

## Documentation

- [Idea & Specification](docs/Student_Attendance_Idea.md)
- [Full Architecture & ER Model](docs/IDEA_AND_ARCHITECTURE.md)
