# Week 1: SQL Quick Reference & Cheat Sheet

This guide provides the basic syntax and concepts you need to survive your first week of database querying. Use these examples as structural templates for your lab and homework!

---

## 1. The Core Anatomy of a Query
> **🚨 Beginner Trap: Single vs Double Quotes**
> In SQL, you must always use **single quotes** (`'`) for text strings. Double quotes (`"`) are used for system column names and will cause your query to crash! (e.g. `WHERE team = 'Storm'` is correct, `WHERE team = "Storm"` is broken).

Every basic query follows the same fundamental structure: **What** do you want, **Where** is it, and **How** do you filter it?

```sql
SELECT column_name1, column_name2 
FROM table_name 
WHERE some_condition = 'true';
```

---

## 2. Counting Rows vs. Viewing Rows
If a table has a million records, returning all of them will crash your screen. We use two specific commands to sample data or count it safely.

**Viewing a Sample (`LIMIT`)**
Caps the output to a specific number of rows so you can preview the data structure.
```sql
SELECT first_name, last_name 
FROM students 
LIMIT 5;
```

**Counting the Total (`COUNT(*)`)**
Instead of returning the actual rows, this returns a single number representing *how many* rows matched your filter.
```sql
SELECT COUNT(*) 
FROM students 
WHERE graduation_year = 2026;
```

---

## 3. Filtering Logic (`WHERE` clause)

### Chaining Conditions (`AND` / `OR`)
You can combine multiple rules together to find exactly what you need.
```sql
SELECT first_name 
FROM students 
WHERE major = 'Computer Science' AND graduation_year = 2026;
```

### Lists of Values (`IN` / `NOT IN`)
If you need to check if a value matches *any* item in a specific list, use `IN`. It is much cleaner than writing a giant chain of `OR` statements.
```sql
SELECT product_name 
FROM inventory 
WHERE category IN ('Electronics', 'Books', 'Clothing');
```
*Tip: You can use `NOT IN` to exclude a list of items!*

### Finding the Unknowns (`IS NULL`)
In a database, a missing value is `NULL`. You cannot use an equals sign (`= NULL`) because you cannot mathematically equal an unknown concept.
```sql
SELECT first_name 
FROM students 
WHERE phone_number IS NULL;
```
*Tip: Use `IS NOT NULL` to find rows where the data actually exists.*

---

## 4. Text and Dates

### Searching Text (`LIKE`)
Use the `%` symbol as a wildcard to find partial text matches. 
```sql
-- Finds anyone whose last name ends with 'son' (e.g. Johnson, Peterson)
SELECT first_name, last_name 
FROM students 
WHERE last_name LIKE '%son';

-- Finds any class with 'Data' anywhere in the title
SELECT course_name 
FROM courses 
WHERE course_name LIKE '%Data%';
```

### Filtering by Date
Dates are formatted as text strings (`'YYYY-MM-DD'`), but SQL is smart enough to understand time. You can use greater-than and less-than signs to find events before or after a specific day.
```sql
SELECT event_name 
FROM schedule 
WHERE event_date < '2026-01-01'; 
```

---

## 5. Math and Sorting

### Column Math
SQL is a calculator. You can multiply `*`, divide `/`, add `+`, and subtract `-` columns together dynamically, and you can even filter using the results!
```sql
-- Find items where the calculated total cost is greater than 100
SELECT item_name, quantity, price 
FROM shopping_cart 
WHERE (quantity * price) > 100;
```

*Inequality Operators to remember:* 
*   `>` (Greater than)
*   `>=` (Greater than or equal to)
*   `!=` or `<>` (Not equal to)

### Sorting Results (`ORDER BY`)
You can sort your final output alphabetically or numerically.
```sql
SELECT first_name, gpa 
FROM students 
ORDER BY gpa DESC;
```
*   `DESC` sorts highest-to-lowest (or Z to A).
*   `ASC` sorts lowest-to-highest (or A to Z).
