# Week 3 Setup Instructions: Database Transition

Welcome to Week 3! This week we are introducing a massive new dataset to the project: the external vendor shipping logs. 

Before we can begin the lab, you must pull the latest files from the class template repository and run a transition script to inject this new data into your existing database.

---

## Step 1: Pull the Latest Repository Updates
You need to pull the Week 3 folder (which includes your Cheat Sheet and the database script) from the class template repository into your local repository.

1. Open your terminal or Git Bash.
2. Navigate to your local youth sports project directory:
   ```bash
   cd path/to/your/youth_sports_project
   ```
3. Pull the latest changes from the class template repository. *(Note: Depending on how you cloned the repository, you may need to use `origin` or `upstream`)*:
   ```bash
   git pull origin main
   ```
4. Verify the pull was successful. You should now see a `Week 3` folder containing `CHEAT_SHEET.md` and `week03_transition.sql`.

---

## Step 2: Run the Database Transition Script
**🚨 CRITICAL STEP 🚨**
If you do not run this script, your database will not have the vendor shipping table, and every single JOIN query you write this week will crash with a "table does not exist" error!

1. Open your terminal or psql command line tool.
2. Connect to your `youth_sports` database:
   ```bash
   psql -U your_username -d youth_sports
   ```
3. Execute the transition script. *(Make sure you provide the correct absolute path to where the file is saved on your computer)*:
   ```sql
   \i 'C:/absolute/path/to/Week 3/week03_transition.sql'
   ```
4. **Verify it worked!** Run the following query in your database:
   ```sql
   SELECT COUNT(*) FROM vendor_gear_shipments;
   ```
   *If the script ran successfully, you will see exactly **41,530** rows.*

---

**You are now ready for Week 3!** 
The Lab and Homework prompts will be released on Moodle just before class begins. Feel free to review the `CHEAT_SHEET.md` to prepare for the SQL JOINs we will be covering!
