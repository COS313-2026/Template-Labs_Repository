# Week 9: Pulling the New Lab Template

Welcome to Week 9! This week we explore physical database storage, the PostgreSQL Query Planner, execution plan diagnostics (`EXPLAIN ANALYZE`), Balanced Tree (`B-Tree`) indexing (`CREATE INDEX`), and auditing metadata via system catalogs (`pg_indexes`).

Before we begin the lab, you must pull the latest files from the class template repository and run the Week 9 transition script to synchronize your core tables and generate the 1,006,600-row `audit_logs` table.

---

## Step 1: Open Your Codespace
1. Navigate to your personal private repository on GitHub (e.g., `github.com/your-username/COS313_labs`).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (`Ctrl + ~` or **Terminal -> New Terminal**).

---

## Step 2: Fetch the Week 9 Files
Pull the newly published Week 9 files down into your workspace. Run this command:
```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```
> **What this does:** This safely merges the instructor's template updates with your personal workspace. You should now see a brand new `week09/` folder containing your starter templates, transition script, and Cheat Sheet!

---

## Step 3: Run the Database Transition Script
> 🚨 **CRITICAL STEP:**  
> Running this script ensures your `users`, `teams`, `registrations`, and `gear_orders` tables are in their clean post-surrogate-migration state AND generates the **1,006,600-row `audit_logs` table** needed for today's index tuning lab.

Run this exact command in your terminal to initialize your database for Week 9 (it will take ~3–5 seconds to generate the 1 million audit rows):
```bash
psql -U admin -d sports_db -f week09/week09_transition.sql
```

### Verify it worked!
Run this quick check in your terminal:
```bash
psql -U admin -d sports_db -c "SELECT COUNT(*) AS audit_log_rows FROM audit_logs;"
```
*(If you see `1006600` print out on the screen, your database is ready for Week 9!)*

---

## Step 4: Ready for Lab & Homework!
You are now ready to begin:
- **In-Class Lab:** Work inside `week09/lab_solutions.sql`.
- **Homework:** Work inside `week09/hw_solutions.sql`.
- **Syntax Reference:** Keep `week09/CHEAT_SHEET.md` open alongside your SQL editor.
