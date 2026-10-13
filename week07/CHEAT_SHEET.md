# COS313: Data Engineering & DDL Syntax Reference

This syntax reference serves as the standard grammar sheet for **Week 7 (Lab & Homework)** and **Exam 2 (Part 2: Practical Data Engineering)**. It provides pure PostgreSQL syntax grammar and structural patterns.

---

## 1. Physical Table Creation & Idempotency

### Safe Re-run Pattern (Drop Before Create)
To ensure scripts are safely re-runnable without "relation already exists" errors, always issue an idempotent drop with `CASCADE`:
```sql
DROP TABLE IF EXISTS table_name CASCADE;
```
*(Note: `CASCADE` automatically severs any incoming foreign key constraints from child tables).*

### Table DDL Syntax
```sql
CREATE TABLE table_name (
    column_name DATA_TYPE [NOT NULL] [PRIMARY KEY],
    column_name DATA_TYPE [NOT NULL],
    column_name DATA_TYPE,
    [CONSTRAINT constraint_name CHECK (boolean_expression)]
);
```

### Common PostgreSQL Data Types
| Data Type | Description | Typical Use Case |
| :--- | :--- | :--- |
| `SERIAL` | Auto-incrementing 4-byte integer (1 to 2.1B) | Surrogate Primary Keys |
| `INT` / `INTEGER` | Standard 4-byte signed integer | Foreign keys referencing `SERIAL`, quantities |
| `VARCHAR(n)` | Variable-length character string (max $n$) | Names, emails, codes, states |
| `NUMERIC(p, s)` | Exact fixed-point numeric ($p$ precision, $s$ scale) | Financial fees, currency (`NUMERIC(10,2)`) |
| `DATE` | Calendar date (YYYY-MM-DD) | Birthdates, event dates |
| `TIMESTAMP` | Date and time (with optional timezone) | Registration logs, audit timestamps |
| `BOOLEAN` | Logical true/false | Flags, active status |

---

## 2. Integrity Constraints & Referential Actions

Constraints armor the database by rejecting invalid transactions at the engine level.

### Table-Level Constraints via `ALTER TABLE`
```sql
-- 1. Foreign Key Constraint:
ALTER TABLE child_table 
    ADD CONSTRAINT fk_name 
    FOREIGN KEY (child_column) REFERENCES parent_table (parent_column)
    [ON DELETE RESTRICT | CASCADE | SET NULL]
    [ON UPDATE RESTRICT | CASCADE];

-- 2. Composite UNIQUE Constraint (Multi-Column Key):
ALTER TABLE table_name 
    ADD CONSTRAINT uq_name UNIQUE (column1, column2, ...);

-- 3. CHECK Constraint (Membership & Range Validation):
ALTER TABLE table_name 
    ADD CONSTRAINT ck_name CHECK (column_name IN ('Val1', 'Val2', 'Val3'));

ALTER TABLE table_name 
    ADD CONSTRAINT ck_name CHECK (numeric_column >= 0.00);
```

### Foreign Key Referential Action Rules
* **`RESTRICT` (Default):** Rejects any deletion or update of a parent row if child rows currently reference it. Prevents orphaned records.
* **`CASCADE`:** Automatically propagates the change. Deleting a parent purges referencing children; updating a parent PK updates the child FK.
* **`SET NULL`:** Deleting or updating the parent sets the child's referencing FK column to `NULL` (requires child column to be nullable).

---

## 3. Schema Evolution (`ALTER TABLE`)

In production environments, schemas evolve over time as requirements change:

```sql
-- Add a new column:
ALTER TABLE table_name ADD COLUMN column_name DATA_TYPE;

-- Drop an existing column:
ALTER TABLE table_name DROP COLUMN column_name;

-- Promote a column to Primary Key:
ALTER TABLE table_name ADD PRIMARY KEY (column_name);

-- Remove an existing constraint by name:
ALTER TABLE table_name DROP CONSTRAINT constraint_name;
```

---

## 4. Multi-Table Updates (PostgreSQL Join Syntax)

Standard ANSI SQL `UPDATE ... JOIN` syntax is not supported in PostgreSQL. Instead, PostgreSQL uses the `UPDATE ... FROM ... WHERE` join pattern:

```sql
UPDATE target_table t
SET target_column = s.source_column
FROM source_table s
WHERE t.natural_key = s.natural_key;
```

---

## 5. ACID Transaction Sandboxes

Transaction blocks guarantee that a series of operations execute as a single, atomic unit:

```sql
BEGIN;      -- Open an isolated transaction sandbox

-- Execute your DML or DDL operations:
UPDATE table_name SET status = 'active';

COMMIT;     -- Permanently write all changes to disk (Durability)
```

### The Emergency Escape (`ROLLBACK`)
If an operational error occurs or you are testing a simulated disaster drill, revert all pending modifications:
```sql
BEGIN;
UPDATE table_name SET balance = 0.00;  -- Disaster occurred!
ROLLBACK;                              -- Zero changes are persisted
```

> **🚨 PostgreSQL Transaction Abort Rule:**  
> If *any* statement causes a database error while inside an open `BEGIN;` block, PostgreSQL immediately marks the transaction aborted. All subsequent commands are ignored until you issue:
> ```sql
> ROLLBACK;
> ```
> Once cleared, you can start a fresh `BEGIN;` block.

---

## 6. Verification & System Catalog Inspection

```sql
-- Verify Table Row Count:
SELECT COUNT(*) FROM table_name;

-- Inspect Physical Table Columns in PostgreSQL Catalog:
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('table_a', 'table_b')
ORDER BY table_name DESC, column_name ASC;
```
