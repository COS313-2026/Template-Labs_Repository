# Week 4 Cheat Sheet & Data Dictionary

## Data Dictionary

### Table: `master_registration_dump`
Our primary legacy table containing user registrations.
*   `registration_id` (INT) - Primary key.
*   `email` (VARCHAR) - User's email address.
*   `first_name` (VARCHAR) - User's first name.
*   `last_name` (VARCHAR) - User's last name.
*   `phone` (VARCHAR) - User's phone number.
*   `birthdate` (DATE) - User's date of birth.
*   `parent_email` (VARCHAR) - Email of the parent/guardian (if applicable).
*   `assigned_role` (VARCHAR) - The role of the user (`player`, `coach`, `parent`, `volunteer`).
*   `team_name` (VARCHAR) - The name of the team they are assigned to.
*   `age_group` (VARCHAR) - The age bracket for their team (e.g., `U10`, `U12`).
*   `fee_amount` (DECIMAL) - The amount paid for registration (0 means scholarship).
*   `payment_status` (VARCHAR) - Status of their fee (`paid`, `unpaid`, `partial`).
*   `gear_item` (VARCHAR) - The specific gear item requested (e.g., `Cleats`, `Jersey`).
*   `gear_size` (VARCHAR) - The size of the gear requested.
*   `gear_quantity` (INT) - The requested quantity.
*   `registered_at` (TIMESTAMP) - The exact timestamp of when they registered.

### Table: `vendor_gear_shipments`
The third-party vendor fulfillment table (added in Week 3).
*   `shipment_id` (SERIAL) - Primary key.
*   `registration_id` (INT) - Foreign key linking back to `master_registration_dump`.
*   `shipped_item` (VARCHAR) - The name of the item the vendor shipped.
*   `shipped_quantity` (INT) - The amount of the item actually shipped.
*   `shipment_date` (DATE) - The date the item was dispatched.

---

## Quick Reference: The DISTINCT Keyword
Set operations like `UNION` and `INTERSECT` automatically remove duplicate rows from their final output. However, Alternative Logic methods (like `OR` clauses or `INNER JOIN`s) do **not** automatically deduplicate data.

To force a standard query to perfectly mimic the deduplication of a Set Operation, you must add the `DISTINCT` keyword immediately after `SELECT`.

**CRITICAL RULE:** `DISTINCT` does **not** just operate on the first column. It operates on the **entire row combination** of everything listed in the `SELECT` statement. If you add a highly unique column (like an email address or a primary key) to your `SELECT` clause, **`DISTINCT` will not collapse the rows as you might expect**, because every single row's combination will suddenly become mathematically unique!

```sql
-- This might return the same person 5 times if they match 5 times
SELECT first_name, last_name FROM employees WHERE department = 'Sales' OR role = 'Manager';

-- This mathematically mimics a UNION by forcefully removing duplicates
SELECT DISTINCT first_name, last_name FROM employees WHERE department = 'Sales' OR role = 'Manager';
```

## Quick Reference: Set Operations
Set operations combine the results of two **independent** queries. Both queries MUST return the exact same number of columns, and the data types of those columns must match in order.

*   **`UNION`**: Combines rows from both queries and automatically removes duplicates.
*   **`UNION ALL`**: Combines rows from both queries but keeps duplicates.
*   **`INTERSECT`**: Returns only the rows that exist in both Query 1 and Query 2.
*   **`EXCEPT`**: Returns rows from Query 1 that do not exist in Query 2 (subtracts Query 2 from Query 1).

```sql
-- Example: Using UNION to combine two queries
SELECT name FROM employees WHERE department = 'Sales'
UNION
SELECT name FROM employees WHERE department = 'Marketing';
```

## Quick Reference: Labeling UNION Queries (Literal Strings)
When you use a `UNION` to stack aggregations, you lose context of which table the row came from. You can solve this by typing a hardcoded literal string directly into your `SELECT` clause. This generates a brand new "label" column out of thin air!

### Without a Label:
```sql
SELECT SUM(salary) FROM full_time_employees
UNION ALL
SELECT SUM(contract_cost) FROM contractors;
```
**Output:**
```text
   sum   
---------
 5400000
 1200000
```
*(Notice how you have no idea which number is which!)*

### With a Label (The Solution):
```sql
SELECT 'Internal' AS source, SUM(salary) AS total_cost FROM full_time_employees
UNION ALL
SELECT 'External' AS source, SUM(contract_cost) AS total_cost FROM contractors;
```
**Output:**
```text
  source  | total_cost 
----------+------------
 Internal |    5400000
 External |    1200000
```
*(The context is now perfectly preserved!)*

## Quick Reference: Self-Joins
A Self-Join is used when you need to compare rows within the same table. 

**Critical Rule:** You MUST use table aliases (`AS a` and `AS b`) in the `FROM` and `JOIN` clauses to tell the database which "copy" of the table you are referencing. 
```sql
SELECT a.column1, b.column2
FROM my_table a
INNER JOIN my_table b 
  ON a.match_column = b.match_column
WHERE a.filter_condition = 'X' AND b.filter_condition = 'Y';
```

## Quick Reference: Subqueries
Subqueries allow you to nest a query inside another query, usually in the `WHERE` clause.

*   **Scalar Subquery:** Use when the inner query returns exactly one row and one column (e.g., an aggregate like `AVG()` or `MAX()`). You can use standard operators like `=`, `<`, `>`.
```sql
SELECT name, salary FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);
```

*   **List Subquery (`IN` / `NOT IN`):** Use when the inner query returns multiple rows but only one column. You cannot use `=`, you must use `IN` to check if a value exists anywhere in the resulting list.
```sql
SELECT name FROM employees 
WHERE department_id IN (SELECT department_id FROM active_departments);
```
