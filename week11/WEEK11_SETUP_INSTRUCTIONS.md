# Week 11: Pulling the New Lab Template

Welcome to Week 11! This week we explore Document Databases, Semi-Structured Data, MongoDB, and the `mongosh` interactive shell.

Before we begin the lab, you must pull the latest files from the class template repository and run the Week 11 database seed script to populate the `sports_db_nosql` database with the `live_game_logs` collection.

---

## Step 1: Open Your Codespace
1. Navigate to your personal private repository on GitHub (e.g., `github.com/your-username/COS313_labs`).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (`Ctrl + ~` or **Terminal -> New Terminal**).

---

## Step 2: Fetch the Week 11 Files
Pull the newly published Week 11 files down into your workspace. Run this command:
```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```
> **What this does:** This safely merges the instructor's template updates with your personal workspace. You should now see a brand new `week11/` folder containing your starter templates, seed script, and Cheat Sheet!

---

## Step 3: Seed the MongoDB Database
> 🚨 **CRITICAL STEP:**  
> Running this seed script populates your MongoDB database (`sports_db_nosql`) with the 20 real-time match documents needed for today's lab and homework.

Run this command in your Codespaces terminal to initialize your database:
```bash
mongosh sports_db_nosql < week11/seed_live_game_logs.js
```

### Verify it worked!
Run this quick check in your terminal:
```bash
mongosh sports_db_nosql --eval "db.live_game_logs.countDocuments();"
```
*(If you see `20` print out on the screen, your database is ready for Week 11!)*

---

## Step 4: Ready for Lab & Homework!
You are now ready to begin:
- **In-Class Lab:** Work inside `week11/lab_solutions.js`.
- **Homework:** Work inside `week11/hw_solutions.js`.
- **Syntax Reference:** Keep `week11/CHEAT_SHEET.md` open alongside your JavaScript editor.
