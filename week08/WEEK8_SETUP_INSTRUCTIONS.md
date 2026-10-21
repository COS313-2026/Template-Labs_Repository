# Week 8: Pulling the New Lab Template

Welcome to Week 8! This week we build on our normalized 3NF relational schema (with the `user_id` surrogate key migration) to construct enterprise analytical layers: Defensive SQL (`COALESCE`, `CASE WHEN`, `EXISTS`), Relational Views (`CREATE VIEW`), Common Table Expressions (`WITH`), and Analytical Window Functions (`OVER`).

Before we begin the lab, you must pull the latest files from the class template repository and run the transition script to synchronize and prepare your database.

---

## Step 1: Open Your Codespace
1. Navigate to your personal private repository on GitHub (e.g., `github.com/your-username/COS313_labs`).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (`Ctrl + ~` or **Terminal -> New Terminal**).

---

## Step 2: Fetch the Week 8 Files
Pull the newly published Week 8 files down into your workspace. Run this command:
```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```
> **What this does:** This safely merges the instructor's template updates with your personal workspace. You should now see a brand new `week08/` folder containing your starter templates, transition script, and Cheat Sheet!

---

## Step 3: Run the Database Transition Script
> 🚨 **CRITICAL STEP:**  
> Every student must start Week 8 from the exact same post-surrogate-migration baseline (`users`, `teams`, `registrations` linked via `user_id`, and `gear_orders`). Running this script reloads all 50,000 original records and builds the standardized Week 8 schema.

Run this exact command in your terminal to initialize your database for Week 8:
```bash
psql -U admin -d sports_db -f week08/week08_transition.sql
```

### Verify it worked!
Run this quick check in your terminal:
```bash
psql -U admin -d sports_db -c "SELECT COUNT(*) AS users_count FROM users; SELECT COUNT(*) AS reg_count FROM registrations;"
```
*(If you see `40264` for `users_count` and `49564` for `reg_count`, your database has been successfully synchronized to the Week 8 baseline!)*

---

## Step 4: Ready for Lab & Homework!
You are now ready to begin:
- **In-Class Lab:** Work inside `week08/lab_solutions.sql`.
- **Homework:** Work inside `week08/hw_solutions.sql`.
- **Syntax Reference:** Keep `week08/CHEAT_SHEET.md` open alongside your SQL editor.
