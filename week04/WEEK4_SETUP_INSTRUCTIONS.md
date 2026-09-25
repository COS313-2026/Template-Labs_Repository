# Week 4 Setup Instructions

Before beginning the Week 4 Lab or Homework, you must run the transition script to update your database with this week's business anomalies.

1. Open your GitHub Codespace for this course.
2. Open the integrated terminal within VS Code.
3. Navigate to your Week 4 directory.
4. Execute the following command to run the transition script against your database:


psql -U admin -d sports_db -f week04_transition.sql


If the command executes and outputs DELETE 1 and UPDATE 1, your database is successfully prepared for Week 4!
