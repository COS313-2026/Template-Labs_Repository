# Week 3: Pulling the New Lab Template

Welcome to Week 3! This week we are introducing a massive new dataset to the project: the external vendor shipping logs. 

Before we can begin the lab, you must pull the latest files from the class template repository and run a transition script to inject this new data into your existing database.

## Step 1: Open Your Codespace
1. Navigate to your personal private repository on GitHub (e.g., github.com/your-username/COS313_labs).
2. Click the green **"<> Code"** button, select the **Codespaces** tab, and open your existing Codespace. Wait for it to boot up.
3. Open the Terminal window at the bottom of VS Code (Press Ctrl + ~ or go to **Terminal -> New Terminal** in the top menu).

## Step 2: Fetch the Week 3 Files
Pull the newly published Week 3 files down into your workspace. Run this command:
`ash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
`
> **What this does:** This safely merges the instructor's updates with your personal code. Look at your File Explorer on the left side of VS Code. You should now see a brand new week03/ folder containing your starter files and Cheat Sheet!

## Step 3: Run the Database Transition Script
**?? CRITICAL STEP ??**
If you do not run this script, your database will not have the vendor shipping table, and every single JOIN query you write this week will crash with a "table does not exist" error!

Run this exact command in your terminal to securely load the shipping dataset into your database:
`ash
psql -U admin -d sports_db -f week03/week03_transition.sql
`

**Verify it worked!** Run this quick check in your terminal to make sure the table was created:
`ash
psql -U admin -d sports_db -c "SELECT COUNT(*) FROM vendor_gear_shipments;"
`
*(If you see "41530" print out on the screen, your database has been successfully updated!)*

**You are now ready to begin the Week 3 Lab!** You can close the terminal and wait for the lab prompts to be posted.
