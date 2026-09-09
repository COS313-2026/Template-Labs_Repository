# Week 2 Syntax Cheat Sheet: Aggregations & Grouping

This cheat sheet provides generic syntax examples for the concepts you will need to complete the Week 2 Lab and Homework. **These examples use hypothetical tables and columns to demonstrate the syntax without solving your assignments for you.**

---

## 0. The Golden Rule of Quotes in SQL
Students often get confused by quotes. Memorize this:
* **NO QUOTES:** Table names, column names, and numbers (e.g., `SELECT first_name FROM master_registration_dump WHERE fee_amount > 10;`).
* **SINGLE QUOTES (`'`):** Text data/string values *inside* the table (e.g., `WHERE payment_status = 'unpaid'`).
* **DOUBLE QUOTES (`"`):** Only used if a column name has spaces (which ours do not). Avoid these!
* **COPY-PASTE WARNING (```sql):** When copying examples from these documents, **NEVER copy the ```sql or ```bash tags!** Those are just formatting tags to make the text colorful. Only copy the actual code *inside* the box.

---

## 1. Aggregate Functions (Summarizing a Column)
Use these when you want to summarize an entire column into a single value.

**Total Count of Rows:**
```sql
SELECT COUNT(*) FROM employee_database;
```

**Total Addition (Sum):**
```sql
SELECT SUM(salary) FROM employee_database;
```

**Average (Mean):**
```sql
SELECT AVG(salary) FROM employee_database;
```

**Extremes (Min/Max):**
```sql
SELECT MAX(salary), MIN(salary) FROM employee_database;
```

---

## 2. Grouping (Sorting into Buckets)
Use `GROUP BY` when you want a summary value *per category*.
*Rule of Thumb: If a column is in your `SELECT` but is NOT inside an aggregate function like SUM or COUNT, it MUST be in your `GROUP BY`.*

**Example: Get the total number of employees per department:**
```sql
SELECT department_name, COUNT(*) 
FROM employee_database 
GROUP BY department_name;
```

**⚠️ The Grouping Trap (Don't shatter your buckets!)**
Only `GROUP BY` broad categories (like `team_name` or `payment_status`). If you try to `SELECT` and `GROUP BY` an individual identifier (like `first_name` or `registration_id`), the database will create a unique bucket for every single person. Your `COUNT(*)` will just be `1`, and your summary will be ruined!

---

## 3. Filtering: `WHERE` vs. `HAVING`
You must use the correct filter depending on *when* the filter happens.

**The `WHERE` Clause:**
Filters raw, individual rows *before* they are grouped.
```sql
-- Count employees per department, but ONLY look at full-time employees
SELECT department_name, COUNT(*) 
FROM employee_database 
WHERE employment_type = 'Full-Time'
GROUP BY department_name;
```

**The `HAVING` Clause:**
Filters the summarized buckets *after* they have been grouped.
```sql
-- Find departments that have more than 50 employees total
SELECT department_name, COUNT(*) 
FROM employee_database 
GROUP BY department_name
HAVING COUNT(*) > 50;
```

---

## 4. The "Ultimate Query" Order of Operations
If you need to use all of them in a single query, you **must** write them in this exact order:

1. `SELECT`
2. `FROM`
3. `WHERE` (Filter raw data)
4. `GROUP BY` (Sort into buckets)
5. `HAVING` (Filter the buckets)
6. `ORDER BY` (Sort the final output — *Remember: Because this happens last, you can only sort by your final buckets or aggregate totals, not raw row data!*)

```sql
SELECT department_name, COUNT(*) 
FROM employee_database 
WHERE employment_type = 'Full-Time'
GROUP BY department_name
HAVING COUNT(*) > 50
ORDER BY COUNT(*) DESC;
```

---

## 5. Data Dictionary (`master_registration_dump`)
*Use this reference to help translate business requests into the correct SQL columns.*

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `registration_id` | INT | Unique identifier for the registration record |
| `email` | VARCHAR | Email address of the registrant (or parent/guardian) |
| `first_name` | VARCHAR | First name of the registrant |
| `last_name` | VARCHAR | Last name of the registrant |
| `phone` | VARCHAR | Contact phone number |
| `birthdate` | DATE | Date of birth of the registrant |
| `parent_email` | VARCHAR | Email address of the parent (if applicable) |
| `assigned_role` | VARCHAR | The role of the person (e.g., 'player', 'coach', 'volunteer') |
| `team_name` | VARCHAR | The name of the team they are assigned to (e.g., 'U10 Storm') |
| `age_group` | VARCHAR | The age division (e.g., 'U10', 'U12', 'U14') |
| `fee_amount` | NUMERIC | The financial cost of the registration in dollars |
| `payment_status` | VARCHAR | Current status of the fee (e.g., 'paid', 'unpaid', 'partial') |
| `gear_item` | VARCHAR | The type of apparel/gear ordered (e.g., 'Jersey', 'Cleats') |
| `gear_size` | VARCHAR | The size of the gear ordered (e.g., 'YS', 'M', 'L') |
| `gear_quantity` | INT | The number of gear items ordered |
| `registered_at` | TIMESTAMP | The exact date and time the registration was submitted |
