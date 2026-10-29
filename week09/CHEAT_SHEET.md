# COS313: Performance Tuning, B-Tree Indexing & Diagnostics Reference

This syntax reference serves as the standard grammar sheet for **Week 9 (Lab & Homework)** and **Exam 2**. It provides pure PostgreSQL syntax grammar, query execution plan metrics, indexing trade-offs, and the Week 9 schema Data Dictionary without domain-specific query solutions.

---

## 1. Week 9 Schema & System Catalog Data Dictionary

After running `week09_transition.sql`, your `sports_db` database contains the 4 core normalized tables (`users`, `teams`, `registrations`, `gear_orders`), the 1,006,600-row security log table (`audit_logs`), and PostgreSQL's built-in index catalog view (`pg_indexes`):

| Table / View Name | Primary Key (PK) | Foreign Keys (FK) & Constraints | Columns & Data Types |
| :--- | :--- | :--- | :--- |
| **`users`** *(40,264 rows)* | `user_id` (`SERIAL`) | `email` (`UNIQUE NOT NULL`) | `user_id` (`SERIAL`), `email` (`VARCHAR`), `first_name` (`VARCHAR`), `last_name` (`VARCHAR`), `phone` (`VARCHAR`), `birthdate` (`DATE`), `parent_email` (`VARCHAR`, nullable) |
| **`teams`** *(6 rows)* | `team_name` (`VARCHAR`) | `age_group IN ('U10', 'U12', 'U14')` | `team_name` (`VARCHAR`), `age_group` (`VARCHAR`) |
| **`registrations`** *(49,564 rows)* | `registration_id` (`SERIAL`) | `user_id` $\rightarrow$ `users(user_id)`<br>`team_name` $\rightarrow$ `teams(team_name)`<br>`CHECK (fee_amount >= 0.00)` | `registration_id` (`SERIAL`), `user_id` (`INT`), `team_name` (`VARCHAR`), `assigned_role` (`VARCHAR`), `fee_amount` (`NUMERIC(6,2)`) |
| **`gear_orders`** *(41,077 rows)* | `order_id` (`SERIAL`) | `registration_id` $\rightarrow$ `registrations(registration_id)` | `order_id` (`SERIAL`), `registration_id` (`INT`), `gear_item` (`VARCHAR`), `gear_size` (`VARCHAR`), `gear_quantity` (`INT`) |
| **`audit_logs`** *(1,006,600 rows)* | `log_id` (`SERIAL`) | *(None — standalone security log)* | `log_id` (`SERIAL`), `action` (`VARCHAR`), `user_email` (`VARCHAR`), `ip_address` (`VARCHAR`), `log_timestamp` (`TIMESTAMP`) |
| **`pg_indexes`** *(System View)* | *(Catalog View)* | *(Built-in PostgreSQL metadata view)* | `schemaname` (`NAME`), `tablename` (`NAME`), `indexname` (`NAME`), `tablespace` (`NAME`), `indexdef` (`TEXT`) |

* **Implicit ("Ghost") Index Rule:** PostgreSQL **automatically** creates a unique B-Tree index for every **`PRIMARY KEY`** and every **`UNIQUE`** constraint (e.g., `users` starts with **2** built-in indexes: `users_pkey` on `user_id` and `users_email_unique` on `email`).
* **Unindexed Foreign Key Rule:** PostgreSQL **never** automatically creates an index on a **`FOREIGN KEY`** column (`registrations.user_id` and `gear_orders.registration_id` have no index until you explicitly run `CREATE INDEX`).

---

## 2. B-Tree Index DDL Grammar (`CREATE INDEX` & `DROP INDEX`)

### 1. Idempotent Single-Column B-Tree Index
Precede index creation with `DROP INDEX IF EXISTS` so your script can be re-executed cleanly without `"relation already exists"` errors:
```sql
DROP INDEX IF EXISTS index_name;

CREATE INDEX index_name ON table_name (column_name);
```

### 2. Idempotent Composite (Multi-Column) B-Tree Index
Builds a single B-Tree index sorted first by `leading_col`, and then by `secondary_col` within ties:
```sql
DROP INDEX IF EXISTS index_name;

CREATE INDEX index_name ON table_name (leading_col [ASC | DESC], secondary_col [ASC | DESC]);
```
* **The Phonebook Rule (Leftmost Prefix Rule):** A composite index on `(leading_col, secondary_col)` accelerates queries filtering on `leading_col` alone or `leading_col AND secondary_col` together. Filtering on `secondary_col` alone cannot perform a direct point lookup (resulting in a full table `Seq Scan` or a multi-probe Skip Scan).

### 3. Updating Table Statistics (`ANALYZE`)
Refreshes PostgreSQL's internal row counts and data distribution histograms (`pg_statistic`) so the Query Planner can make accurate cost estimates:
```sql
ANALYZE table_name;
```
> [!NOTE]
> **`ANALYZE table_name;` vs. `EXPLAIN ANALYZE SELECT ...;`:** `ANALYZE` is a background maintenance command that updates catalog statistics across the entire table. `EXPLAIN ANALYZE` is a diagnostic tool that executes a specific `SELECT` query and benchmarks its actual execution plan.

---

## 3. Query Execution Plan Diagnostics (`EXPLAIN ANALYZE`)

### Diagnostic Syntax
```sql
-- 1. Estimate Only (does NOT execute the query):
EXPLAIN
SELECT ... FROM table_name WHERE condition;

-- 2. Live Execution & Timing (executes query and prints real timing):
EXPLAIN ANALYZE
SELECT ... FROM table_name WHERE condition;
```

### Execution Plan Metrics & Output Decoder (Read Inside-Out / Deepest `->` First)

| Plan Node / Metric | Type | Definition & Diagnostic Meaning |
| :--- | :--- | :--- |
| **`Seq Scan`** | Scan Node | **Sequential Scan ($O(N)$):** Reads every 8 KB heap page on disk from top to bottom. Indicates a missing index, a small table, or a low-selectivity filter. |
| **`Parallel Seq Scan`** | Scan Node | Sequential scan divided across multiple worker background processes. |
| **`Index Scan`** | Scan Node | **B-Tree Index Scan ($O(\log N)$):** Traverses the index directly to find leaf matching pointers, then jumps directly to individual heap pages. |
| **`Bitmap Index Scan`** | Scan Node | **Step 1 of Batch Lookup:** Scans the B-Tree index and builds an in-memory bit-array of matching physical page numbers. |
| **`Bitmap Heap Scan`** | Scan Node | **Step 2 of Batch Lookup:** Consumes the bitmap produced by `Bitmap Index Scan` and visits physical heap pages in sequential disk order to avoid random disk thrashing. |
| **`Hash Join`** | Join Node | Builds an in-memory hash table of the inner table and probes it with the outer table. Common when joining large, unindexed tables. |
| **`Nested Loop`** | Join Node | For every qualifying row in the outer table, probes the inner table (ideally via an `Index Scan` on an indexed foreign key). Fastest for selective joins. |
| **`Merge Join`** | Join Node | Joins two inputs that are already sorted on their join keys (e.g., via B-Tree index ordering or an explicit sort node). Highly efficient for large, sorted datasets. |
| **`cost=startup..total`** | Cost Estimate | Planner's estimated cost (arbitrary units): `startup` is cost to return the **first** row; `total` is cost to return **all** rows. |
| **`actual time=first..total`**| Actual Runtime| Real elapsed wall-clock time in milliseconds (`ms`): `first` row returned .. `total` time to complete the node. |
| **`rows=N`** | Row Count | In estimates: planner's expected rows. Under `actual`: true number of rows returned. Discrepancies indicate stale table statistics. |
| **`width=N`** | Row Size | Estimated average size of each output row in bytes. |
| **`loops=N`** | Iterations | Number of times the node was executed (e.g., in a `Nested Loop` inner probe or worker iterations). |
| **`Rows Removed by Filter`** | Filter Metric | Rows inspected and discarded during a scan; high values indicate unindexed queries or low selectivity. |
| **Selectivity Tipping Point**| Optimizer Rule | If a `WHERE` filter matches $> 5\%-15\%$ of total rows (low selectivity), the Query Planner intentionally bypasses an existing B-Tree index and chooses `Seq Scan` to avoid random disk page jumping. |

---

## 4. Indexing Strategy & Trade-offs (Exam 2 Theory)

B-Tree indexes are not free; every index introduces trade-offs between read speed, write overhead, and storage:

| When to Create an Index | When NOT to Create an Index |
| :--- | :--- |
| **Foreign Keys:** Columns used to `JOIN` parent and child tables (prevents full child table `Seq Scan`s). | **Small Tables (< 1,000 rows):** Sequential scan is faster than traversing B-Tree pointer levels. |
| **High Selectivity Filters:** Columns in `WHERE` clauses matching $< 5\%$ of total rows. | **Low Selectivity Filters:** Columns matching $> 15-20\%$ of rows (e.g., booleans, status flags). The engine chooses `Seq Scan` anyway. |
| **Sorting / Grouping:** Columns frequently appearing in `ORDER BY` or `GROUP BY`. | **Write-Heavy Tables:** Tables subject to high-frequency `INSERT`, `UPDATE`, or `DELETE`. |

* **The Write Penalty (Write Amplification):** Every index on a table forces the database engine to synchronously update both the heap table and every associated B-Tree on every `INSERT` and `DELETE`, and on `UPDATE`s modifying indexed columns. Over-indexing degrades write throughput.
* **Storage Overhead:** Indexes consume additional disk space (often 20%–50% of the base table size).
* **Strategic Denormalization (When Indexes Aren't Enough):** Intentionally adding controlled redundancy to a 3NF schema to eliminate expensive runtime joins under extreme read throughput:
  * **Pre-Calculated Summary Rollups:** Caching high-frequency aggregate counts (e.g., storing a running `total_registrations INT` on `teams`) maintained via triggers or atomic transactions.
  * **Historical Point-in-Time Snapshots:** Storing immutable copies of changing values (e.g., copying `unit_price_at_checkout` or `billing_address` into `invoices`) to ensure financial and legal audit integrity.

---

## 5. Auditing Indexes via System Catalogs (`pg_indexes`)

To inspect or count existing indexes on one or more tables:

```sql
-- 1. List index names, table names, and full definitions:
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE tablename IN ('table_one', 'table_two')
ORDER BY tablename ASC, indexname ASC;

-- 2. Count total indexes across specific tables:
SELECT COUNT(*) AS total_indexes
FROM pg_indexes
WHERE tablename IN ('table_one', 'table_two');

-- 3. Identify automatic Ghost Indexes (UNIQUE/PK) vs manual performance indexes:
SELECT 
    tablename, 
    indexname,
    CASE 
        WHEN indexdef LIKE 'CREATE UNIQUE INDEX%' THEN 'Ghost (Constraint)'
        ELSE 'Manual (Performance)'
    END AS index_type
FROM pg_indexes
WHERE tablename IN ('table_one', 'table_two')
ORDER BY tablename ASC, indexname ASC;
```
