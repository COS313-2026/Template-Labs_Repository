# Week 12: Pulling the Lab Template & Environment Verification

Welcome to Week 12! This week we explore **MongoDB Schema Validation**, in-flight schema evolution via `collMod`, defense-in-depth JSON Schema architecture (`$jsonSchema`), and operational governance (`strict` vs. `moderate` validation levels and `error` vs. `warn` validation actions).

Before beginning today's lab, pull the latest files from the class template repository and verify that your MongoDB database baseline is intact.

---

## Step 1: Open Your Codespace
1. Navigate to your personal repository on GitHub (e.g., `github.com/your-username/COS313_labs`).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (`Ctrl + ~` or **Terminal -> New Terminal**).

---

## Step 2: Fetch the Week 12 Files
Pull the newly published Week 12 files down into your workspace. Run this command:
```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```
> **What this does:** This safely merges the instructor's template updates into your personal workspace without overwriting your prior work. You should now see a brand new `week12/` folder containing:
> - `lab_solutions.mongodb.js` (In-Class Lab starter playground)
> - `hw_solutions.mongodb.js` (Homework starter playground)
> - `CHEAT_SHEET.md` (Complete Week 12 syntax, BSON types, & Data Dictionary)
> - `WEEK12_SETUP_INSTRUCTIONS.md` (This guide)

---

## Step 3: Verify Your MongoDB Environment
> [!NOTE]
> **No Container Rebuild Required!**  
> Because MongoDB Community 7.0 and `mongosh` were already provisioned in Week 11, your Codespace is already fully equipped.

1. **Check MongoDB Service:** Confirm your MongoDB VS Code extension is connected (`mongodb://localhost:27017` in the left activity bar).
2. **Verify Baseline Collection:** Check that your `live_game_logs` collection is populated with the 20 baseline match records. Run this command in your Codespaces terminal:
   ```bash
   mongosh sports_db_nosql --eval "db.live_game_logs.countDocuments();"
   ```
   *(If you see `20` print out on the screen, your database is 100% ready for Ticket 0!)*

---

## Step 4: Resetting the Baseline (If Needed)
If `countDocuments()` does **not** return `20` (for example, if documents were added or deleted during Week 11 experimentation), or if you want to wipe any experimental schema validators and start with a completely fresh slate, run your existing Week 11 seed script:
```bash
mongosh sports_db_nosql < week11/seed_live_game_logs.js
```
> **What this does:** The seed script executes `db.live_game_logs.drop()`, which clears any test documents, wipes any lingering collection validators, and cleanly re-seeds the 20 baseline match records.

---

## Step 5: Working with MongoDB Playgrounds (`.mongodb.js`)

Your starter files are configured as **MongoDB Playgrounds**:
- **In-Class Lab:** Work inside `week12/lab_solutions.mongodb.js`.
- **Homework:** Work inside `week12/hw_solutions.mongodb.js`.

### Running Individual Tickets:
Each ticket and task contains `db = db.getSiblingDB("sports_db_nosql");` at the top of its section so it is completely self-contained:
1. Highlight the code for the specific ticket you want to run (including the `db = db.getSiblingDB(...)` line).
2. Right-click and choose **Run Selected Lines From Playground** (or press **`Ctrl + Alt + S`** / **`Cmd + Alt + S`** on macOS).
3. A colorized **`Results.json`** tab will open on the right displaying the command status and output.

*(Tip: You can also click the small blue text **`▶ Run Selected Lines From Playground`** that appears directly above code blocks in the VS Code editor).*

---

## Step 6: Final Run & Saving Output for Submission

When you have completed your tickets and want to generate your final submission output:

### Method A: From the Playground (Recommended)
1. Open `week12/lab_solutions.mongodb.js` (or `hw_solutions.mongodb.js`).
2. Click the green **Play (▶)** icon in the top-right corner of the editor (or press `Ctrl + Shift + P` and choose **`MongoDB: Run All From Playground`**).
3. The complete output for all tickets will render in the **`Results.json`** tab.
4. With `Results.json` focused, press **`Ctrl + S`** (or `Cmd + S`) and save the file as:
   - For Lab: `week12/lab_output.json`
   - For Homework: `week12/hw_output.json`

### Method B: From the Terminal
Alternatively, you can pipe your script directly into a text output file from your Codespaces terminal:
```bash
mongosh sports_db_nosql < week12/lab_solutions.mongodb.js > week12/lab_output.txt
mongosh sports_db_nosql < week12/hw_solutions.mongodb.js > week12/hw_output.txt
```

*(Both starter scripts include idempotent cleanup safeguards—such as deleting temporary test documents before inserting—so you can safely re-run them from start to finish).*
