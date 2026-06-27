# COS313: Database Systems — Student Setup & Workflow Guide

Welcome to your isolated engineering workspace! In this course, you will manage a continuous youth sports software scenario. This guide explains how to initialize your private database sandbox environment and pull new lab assignments each week.

---

## Part 1: Initializing Your Private Sandbox Workspace

Follow these steps on Day One to create your personal database environment.

### 1. Generate Your Private Repository
1. Log into your GitHub account and navigate to the class's organization "COS313-2026" and the course template repository "Template-Labs_Repository".  If you don't yet have access to the organization reach out to the instructor to ensure you are added as a member.
2. Click the green button at the top-right corner that says **"Use this template"** and select **"Create a new repository"**.
3. In the setup form, configure the following:
   * **Owner**: Select your personal GitHub username.
   * **Repository Name**: Type `COS313_labs`.
   * **Visibility**: Select **Private** (This ensures your assignment solutions remain confidential).
4. Click the green **Create repository** button. GitHub will copy the starter files into a new repository under your personal GitHub profile.

### 2. Launch Your Browser Database Container
1. Open your newly created personal private repository (e.g. https://github.com/username/COS313_labs).
2. Click the green **"<> Code"** button near the top right.
3. Select the **Codespaces** tab inside the popup wrapper.
4. Click the green button that says **"Create codespace on main"**.

*Note: Wait roughly 2 minutes for your container to compile. The automated system will boot a Linux environment, install PostgreSQL, seed your data, and launch an in-browser code editor. Your workspace is ready when you see the database explorer icon appear on your left sidebar.*

---

## Part 2: Pulling Weekly Lab Updates

As the semester progresses, your instructor will add new weekly folders (e.g., `week02_aggregates/`) to the master template. Follow these steps inside your active cloud terminal to pull down updates without losing your past work.

### 1. Link Your Workspace to the Master Template (Do This ONCE)
The very first time you need to pull an update, you must tell your local workspace where the parent template lives. Open the terminal window at the bottom of your Codespace editor and execute this exact command:

```bash
git remote add template https://github.com/COS313-2026/Template-Labs_Repository.git
```

### 2. Fetch and Merge New Files (Do This EVERY Week)
Every week when a new lab is released, open your Codespace terminal and run this command:

```bash
git pull template main --allow-unrelated-histories
```

#### What this does:
* It checks the master template for **new assignment folders** and merges them into your workspace.
* Your past solutions in older folders remain completely **untouched and safe**.

### 3. Run the Database Environment Transition Script
Because our youth sports platform grows and changes every week, you must sync your PostgreSQL container with the new data requirements. 

1. Look at your file explorer and open the newly pulled weekly folder.
2. Open the file named `weekX_transition.sql` (where `X` is the current week number).
3. Select all text (`Ctrl+A` or `Cmd+A`) and execute the script against your live database connection. 

Your database container is now fully updated and ready for the week's in-class lab challenge!

---

## Part 3: Properly Closing Your Codespaces Session

GitHub Codespaces runs on a cloud virtual machine. To ensure you do not lose your unsaved work or accidentally drain your monthly free hours allocation, follow these engineering shutdown steps at the end of every class.

### Option A: The Quick Exit (Default Behavior)
You can simply **close your browser tab or window**. 
* The cloud container will immediately enter an "idle" state.
* After **30 minutes of total inactivity**, the server will automatically power down to save your hours [index].
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

