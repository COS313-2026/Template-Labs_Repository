# Week 7: Pulling the New Lab Template

Welcome to Week 7! This week we transition from flat-file monolithic architectures to a fully normalized, armor-plated relational database schema with Primary Keys, Foreign Keys, cascading rules, and ACID transaction safety nets.

Before we begin the lab, you must pull the latest files from the class template repository and run the transition script to reset and prepare your database.

---

## Step 1: Open Your Codespace
1. Navigate to your personal private repository on GitHub (e.g., `github.com/your-username/COS313_labs`).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (`Ctrl + ~` or **Terminal -> New Terminal**).

---

## Step 2: Fetch the Week 7 Files
Pull the newly published Week 7 files down into your workspace. Run this command:
```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```
> **What this does:** This safely merges the instructor's template updates with your personal workspace. You should now see a brand new `week07/` folder containing your starter templates and Cheat Sheets!

---

## Step 3: Run the Database Transition Script
> 🚨 **CRITICAL STEP:**  
> If you do not run this script, your database will still contain old views and tables from prior weeks that will conflict with your new schema.

Run this exact command in your terminal to initialize your database for Week 7:
```bash
psql -U admin -d sports_db -f week07/week07_transition.sql
```

### Verify it worked!
Run this quick check in your terminal:
```bash
psql -U admin -d sports_db -c "SELECT COUNT(*) FROM master_registration_dump;"
```
*(If you see `50000` print out on the screen and only `master_registration_dump` exists, your database has been successfully updated!)*

---

## Step 4: Ready for Lab & Homework!
You are now ready to begin:
- **In-Class Lab:** Open `lab_solutions.md` to design your physical ERD (press `Ctrl + K` then `V` for live preview), and open `lab_solutions.sql` to build and migrate your tables.
- **Homework:** Work inside `hw_solutions.sql`.
