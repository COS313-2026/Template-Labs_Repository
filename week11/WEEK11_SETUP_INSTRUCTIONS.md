# Week 11: Pulling the New Lab Template & MongoDB Setup

Welcome to Week 11! This week we explore Document Databases, Semi-Structured Data, MongoDB, and the `mongosh` interactive shell.

Before beginning the lab, you must pull the latest files from the class template repository, rebuild your Codespace container to activate MongoDB, and seed the `sports_db_nosql` database.

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
> **What this does:** This safely merges the instructor's template updates with your personal workspace. You should now see a brand new `week11/` folder containing your starter templates (`lab_solutions.mongodb.js`, `hw_solutions.mongodb.js`), seed script, and Cheat Sheet!

---

## Step 3: Rebuild Your Codespace Container
> 🚨 **CRITICAL STEP FOR WEEK 11:**  
> Because Week 11 introduces MongoDB, your Codespace container needs to be rebuilt once to start the MongoDB Community service alongside PostgreSQL and install the `mongosh` CLI tool.

1. When you run `git pull`, VS Code may display a notification in the bottom-right corner:  
   *"Configuration files in .devcontainer have changed. Would you like to rebuild your container?"*  
   Click **Rebuild Now**.
2. **If you don't see the popup:**  
   Press `Ctrl + Shift + P` (or `Cmd + Shift + P` on macOS), type **`Codespaces: Rebuild Container`**, and press **Enter**.
3. Wait ~1–2 minutes for the container to rebuild. Both PostgreSQL and MongoDB 7.0 will now be running side-by-side!

---

## Step 4: Connect the MongoDB VS Code Extension
Your rebuilt container automatically includes the official **MongoDB for VS Code** extension. Connect it once to enable interactive query execution:

1. Click the **MongoDB leaf icon** on the left activity bar.
2. In the top section titled **CONNECTIONS**, click **"Connect with Connection String"** (or the **`+`** icon).
3. The prompt will be pre-filled with:
   ```text
   mongodb://localhost:27017
   ```
4. Press **Enter**. You are now connected! You will see `localhost:27017` appear in the connection list.

---

## Step 5: Seed the MongoDB Database
> 🚨 **CRITICAL STEP:**  
> Running this seed script populates your MongoDB database (`sports_db_nosql`) with the 20 real-time match documents needed for today's lab and homework.

Run this command in your Codespaces terminal:
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

## Step 6: How to Work & Run Queries (MongoDB Playgrounds)

Your starter templates are configured as **MongoDB Playgrounds** (`.mongodb.js`):
- **In-Class Lab:** Work inside `week11/lab_solutions.mongodb.js`.
- **Homework:** Work inside `week11/hw_solutions.mongodb.js`.

### Running Individual Tickets:
Each ticket and task includes `db = db.getSiblingDB("sports_db_nosql");` at the top of its section so it is completely self-contained:
1. Highlight the code for the specific ticket you want to test (including the `db = db.getSiblingDB(...)` line).
2. Right-click and choose **Run Selected Lines From Playground** (or press **`Ctrl + Alt + S`** / **`Cmd + Alt + S`** on Mac).
3. A clean, colorized **`Results.json`** tab will open on the right displaying your query output!

*(Tip: You can also click the small blue text **`▶ Run Selected Lines From Playground`** that appears directly above your queries in the editor).*

---

## Step 7: Final Run & Saving Output for Submission

When you have completed all tickets and want to generate your final submission output:

### Method A: From the Playground (Recommended)
1. Open `week11/lab_solutions.mongodb.js`.
2. Click the green **Play (▶)** icon in the top-right corner of the editor (or press `Ctrl + Shift + P` and choose **`MongoDB: Run All From Playground`**).
3. The complete output for all tickets will render in the **`Results.json`** tab.
4. With `Results.json` focused, press **`Ctrl + S`** (or `Cmd + S`) and save the file as:
   ```text
   week11/lab_output.json
   ```

### Method B: From the Terminal
Alternatively, you can pipe your script directly into a text output file from your Codespaces terminal:
```bash
mongosh sports_db_nosql < week11/lab_solutions.mongodb.js > week11/lab_output.txt
```
*(To reset Game 4055 back to its clean initial state before your final full run, simply re-run the seed script: `mongosh sports_db_nosql < week11/seed_live_game_logs.js`)*.
