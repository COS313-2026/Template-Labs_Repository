# COS313: Database Systems — Student Setup & Workflow Guide

Welcome to your own personal engineering workspace! In this course, you will manage a continuous youth sports software scenario. This guide explains how to initialize your private database sandbox environment and pull new lab assignments each week.

---

## Step 0: The Prerequisites (GitHub Account)

Before you can launch your database, you need a GitHub account.

1. Navigate to [GitHub.com](https://github.com) and sign up for a free account if you don't already have one. (We highly recommend using your university `.edu` email).
2. **STRONGLY RECOMMENDED:** Apply for the [GitHub Student Developer Pack](https://education.github.com/pack). 
   * *Why?* A standard free account gives you 120 hours per core used of cloud computing time per month (standard codespace instance uses 2 cores, so that means 60 hours total per month). That is enough for this class *if* you carefully shut down your workspace. The Student Pack upgrades you to 180 hours per core used of cloud computing time per month, giving you a massive safety net! You can start the coursework today while waiting for your student status to be approved.

---

## Part 1: Initializing Your Private Sandbox Workspace

Follow these steps on before the first day of class to create your personal database environment.

### 1. Generate Your Private Repository
1. Log into your GitHub account and navigate directly to the course template repository at `https://github.com/COS313-2026/Template-Labs_Repository`. 
2. Click the green button at the top-right corner that says **"Use this template"** and select **"Create a new repository"**.
3. In the setup form, configure the following:
   * **Owner**: Select your personal GitHub username.
   * **Repository Name**: Type `COS313_labs`.
   * **Visibility**: Select **Private** (This ensures your assignment solutions remain confidential).
4. Click the green **Create repository** button. GitHub will copy the starter files into a new repository under your personal GitHub profile.

### 2. Launch Your Browser Database Container
1. Open your newly created personal private repository (e.g. `https://github.com/username/COS313_labs`).
2. Click the green **"<> Code"** button near the top right.
3. Select the **Codespaces** tab inside the popup wrapper.
4. Click the green button that says **"Create codespace on main"**.

*Note: Wait roughly 2 minutes for your container to compile. The automated system will boot a Linux environment, install PostgreSQL, seed your data, and launch an in-browser code editor. Your workspace is ready when you see the database explorer icon appear on your left sidebar.*

### 3. The Sanity Check
Let's prove your database actually built correctly! 
1. Open the Terminal window at the bottom of your VS Code environment (You can press `Ctrl + ~` or click **Terminal -> New Terminal** in the top menu if it is not open).
2. Type the following command to connect to your database: `psql -U admin -d sports_db`
3. Execute this SQL query: `SELECT COUNT(*) FROM master_registration_dump;`
4. If it returns roughly `47,972`, congratulations! Your environment is perfectly configured. Type `\q` to exit the database.

---


### 4. How to Write and Test Queries (SQLTools)
While you can run queries in the terminal using `psql` (like we did in the Sanity Check), it is much easier to write and test your lab assignments using the visual GUI we pre-installed for you called **SQLTools**.

1. Look at the far left vertical activity bar in VS Code and click on the **Database Icon** (it looks like a little cylinder).
2. You will see a connection pre-configured for you called **Youth Sports Database**. 
3. Hover your mouse over it and click the **Connect** icon (it looks like a little plug). The icon will turn green when connected.
4. To write a query, you can either open any `.sql` file in your workspace, or click the **New SQL File** button in the SQLTools sidebar.
5. Type your query, and then click **Run on active connection** at the top of the text editor. A results table will pop up on the right side of your screen!

---

## Part 2: Pulling Weekly Lab Updates

As the semester progresses, your instructor will add new weekly folders to the master template. Follow these steps inside your active cloud terminal to pull down updates without losing your past work.

### 1. Link Your Workspace to the Master Template (Do This ONCE)
The very first time you need to pull an update, you must tell your local workspace where the parent template lives. Open the terminal window at the bottom of your Codespace editor and execute this exact command:

```bash
git remote add template https://github.com/COS313-2026/Template-Labs_Repository.git
```

### 2. Fetch and Merge New Files (Do This EVERY Week)
Every week when a new lab is released, open your Codespace terminal and run this command:

```bash
git pull template main --no-rebase --allow-unrelated-histories --no-edit
```

> **🚨 Troubleshooting: The Merge Conflict**
> Because we added `--no-edit`, Git should update silently. However, if Git suddenly opens a weird text editor or throws an error about a "merge conflict," do not panic! This means you accidentally edited a file from an older week that the instructor also updated. If a text editor named `nano` opens, press `Ctrl + X`, then `N`, then `Enter` to abort. Ask a TA for help resolving the conflict.

### 3. Run the Database Environment Transition Script
Because our youth sports platform grows and changes every week, you must sync your PostgreSQL container with the new data requirements. 

1. Open the terminal window at the bottom of your editor.
2. Execute the transition script using `psql` (Make sure you replace `weekX` with the actual folder name, like `week02`):
   ```bash
   psql -U admin -d sports_db -f weekX/weekX_transition.sql
   ``` 

Your database container is now fully updated and ready for the week's in-class lab challenge!

---

## Part 3: Properly Closing Your Codespaces Session

GitHub Codespaces runs on a cloud virtual machine. To ensure you do not lose your unsaved work or accidentally drain your monthly free hours allocation, follow these engineering shutdown steps at the end of every class.

### Option A: The Quick Exit (Default Behavior)
You can simply **close your browser tab or window**. 
* The cloud container will immediately enter an "idle" state.
* After **30 minutes of total inactivity**, the server will automatically power down to save your hours.
* *Note: While your code is safely saved inside the cloud container, it is not yet backed up to your GitHub profile. To back it up, follow the pro steps below.*

### Option B: Don't waste my Codespaces time method (Recommended)
Before you close your browser tab, spend 30 seconds running these three terminal commands to push your solutions safely to your cloud backup and instantly freeze your billing timer:

1. **Save and Back Up Your Code**: 
   Open the terminal window at the bottom of your editor and execute this git sequence to save your answers securely:
   ```bash
   git add .
   git commit -m "Submitting Week X Lab Solutions"
   git push origin main
   ```

2. **Force an Immediate Hard Shutdown**:
   Instead of letting the server idle for 30 minutes, shut it down instantly to preserve your monthly core-hours budget:
   * Press `Ctrl + Shift + P` (or `Cmd + Shift + P` on Mac) to open the Command Palette.
   * Type **`Codespaces: Stop Current Codespace`** and press **Enter**.

The screen will turn grey, indicating the server has successfully turned off. You can now close your browser tab knowing your assignment is securely backed up and your hours are completely safe!

---

## Part 4: Submitting Your Work

Instead of just submitting a `.sql` file to Moodle, you must also generate and submit a text output file that shows the exact results of your queries. This allows your instructor to grade your output instantly.

1.  **Add Your Signature**: At the absolute top of your `.sql` file, you must include the following comment block exactly as shown, filled out with your information. This is required for the automated grading system to recognize your submission:
    ```sql
    -- ==========================================
    -- STUDENT NAME: [First Last]
    -- STUDENT ID: [ID Number]
    -- ==========================================
    ```
2.  **Generate the Output File**: Open your Codespace terminal (bash) and run the `psql` command to execute your SQL file and save the output. It is critical that you name your output files differently for the Lab and the Homework so they don't overwrite each other! Also be sure to update the folder name each week so that you don't accidentally overwrite what you did in a previous lab or homework assignment.

    **For the In-Class Lab:**
    ```bash
    psql -h localhost -p 5432 -U admin -d sports_db -a -f week01/lab_solutions.sql > week01/lab_output.txt 2>&1
    ```
    
    **For the Homework:**
    ```bash
    psql -h localhost -p 5432 -U admin -d sports_db -a -f week01/hw_solutions.sql > week01/hw_output.txt 2>&1
    ```
3.  **Download Your Files**: You need to get these files out of the cloud and onto your local computer.
    *   In the VS Code file explorer (left sidebar), locate your `.sql` script and your newly generated `.txt` output file.
    *   **Right-click** on each file and select **Download...** to save them to your computer.
4.  **Submit**: Upload both files to Moodle.
