# COS313: Analytical SQL & Reporting Syntax Reference

This syntax reference serves as the standard grammar sheet for **Week 8 (Lab & Homework)** and **Exam 2**. It provides pure PostgreSQL syntax grammar and schema definitions without domain-specific query solutions.

---

## 1. Week 8 Normalized Schema Reference (Post-Surrogate Migration)

After running `week08_transition.sql`, `users` and `registrations` are linked via the integer surrogate key `user_id` (the legacy `registrations.user_email` column has been removed):

| Table Name | Primary Key (PK) | Foreign Keys (FK) & Constraints | Columns & Data Types |
| :--- | :--- | :--- | :--- |
| **`users`** | `user_id` (`SERIAL`) | `email` (`UNIQUE NOT NULL`) | `user_id` (`SERIAL`), `email` (`VARCHAR`), `first_name` (`VARCHAR`), `last_name` (`VARCHAR`), `phone` (`VARCHAR`), `birthdate` (`DATE`), `parent_email` (`VARCHAR`, nullable) |
| **`teams`** | `team_name` (`VARCHAR`) | `age_group IN ('U10', 'U12', 'U14')` | `team_name` (`VARCHAR`), `age_group` (`VARCHAR`) |
| **`registrations`** | `registration_id` (`SERIAL`) | `user_id` $\rightarrow$ `users(user_id)`<br>`team_name` $\rightarrow$ `teams(team_name)` | `registration_id` (`SERIAL`), `user_id` (`INT`), `team_name` (`VARCHAR`), `assigned_role` (`VARCHAR`: e.g., `'player'`, `'coach'`), `fee_amount` (`NUMERIC(6,2)`) |
| **`gear_orders`** | `order_id` (`SERIAL`) | `registration_id` $\rightarrow$ `registrations(registration_id)` | `order_id` (`SERIAL`), `registration_id` (`INT`), `gear_item` (`VARCHAR`), `gear_size` (`VARCHAR`), `gear_quantity` (`INT`) |

* **Surrogate PK vs. Natural Business Key Rule:** `user_id` (`SERIAL`) serves as an immutable 4-byte integer Primary Key for fast `JOIN`s that never changes when a user updates their email, while `email` retains a `UNIQUE NOT NULL` constraint to prevent duplicate accounts.

---

## 2. Defensive SQL & Three-Valued Logic (3VL) Grammar

### 1. Null Substitution (`COALESCE`)
Evaluates arguments left-to-right and returns the first non-`NULL` value (must share a compatible data type):
```sql
COALESCE(nullable_column, fallback_literal) AS column_alias
```
* **Join Rule (`LEFT JOIN` + `COALESCE`):** When substituting `0` for missing child records across a join, use `LEFT JOIN` so unmatched parent rows remain in the result set with `NULL` values for `COALESCE` to replace (an `INNER JOIN` drops unmatched rows before `COALESCE` ever runs).

### 2. Conditional Categorization (`CASE WHEN`)
Evaluates conditions sequentially top-to-bottom and returns the result of the first matching `WHEN` branch (returns `NULL` if no branch matches and `ELSE` is omitted):
```sql
CASE 
    WHEN condition_1 THEN result_1
    WHEN condition_2 THEN result_2
    ELSE default_result
END AS category_alias
```

### 3. Correlated Existence Check (`EXISTS` / `NOT EXISTS`)
Checks whether at least one matching row exists in a related table (returns strictly `TRUE` or `FALSE`, avoiding Three-Valued Logic `UNKNOWN` pitfalls when `NULL` values exist):
```sql
SELECT outer_table.column_a
FROM outer_table
WHERE [NOT] EXISTS (
    SELECT 1
    FROM related_table r
    WHERE r.join_key = outer_table.join_key
      AND r.filter_column = 'target_value'
);
```

---

## 3. Relational Views (`CREATE VIEW`)

A View stores a named `SELECT` query in the database catalog that acts like a virtual table:
* **Zero Duplicate Row Storage:** A standard View stores **0 bytes of row data** on disk; PostgreSQL re-executes the underlying `SELECT` query against the live base tables every time the View is queried.
* **Updatability:** Simple 1-table Views are updatable in PostgreSQL, whereas Views containing `JOIN`, `GROUP BY`, `DISTINCT`, or Window Functions are strictly **read-only**.

### Idempotent View Creation Grammar
Because `CREATE OR REPLACE VIEW` forbids renaming, dropping, or reordering existing view columns in PostgreSQL, precede view creation with `DROP VIEW IF EXISTS ... CASCADE`:

```sql
DROP VIEW IF EXISTS view_name CASCADE;

CREATE [OR REPLACE] VIEW view_name AS
SELECT 
    t1.column_a,
    t2.column_b,
    AGG_FUNC(t2.numeric_col) AS alias_name
FROM table_one t1
JOIN table_two t2 ON t1.key_col = t2.key_col
[WHERE boolean_condition]
[GROUP BY t1.column_a, t2.column_b];
```

### Querying a View
```sql
SELECT column_a, column_b
FROM view_name
[WHERE boolean_condition]
[ORDER BY column_a ASC]
[LIMIT n];
```

---

## 4. Common Table Expressions (`WITH`)

A Common Table Expression (CTE) defines a temporary, in-memory result set scoped strictly to a **single SQL statement** (it vanishes immediately at the semicolon `;`, unlike a persistent `VIEW`).

### Pattern A: Aggregating an Already-Aggregated Column (Two-Step Aggregation)
Because PostgreSQL forbids nested aggregates like `AVG(SUM(col))`, compute the inner aggregate in Stage 1 (`WITH`) and aggregate that column in Stage 2:
```sql
WITH cte_name AS (
    SELECT 
        group_column,
        AGG_FUNC_1(metric_column) AS calculated_metric
    FROM source_table_or_view
    [WHERE row_condition]
    GROUP BY group_column
)
SELECT 
    AGG_FUNC_2(calculated_metric) AS overall_summary
FROM cte_name;
```

### Pattern B: Filtering Groups Against an Overall Aggregate
```sql
WITH cte_name AS (
    SELECT 
        group_column,
        AGG_FUNC(metric_column) AS calculated_metric
    FROM source_table_or_view
    [WHERE row_condition]
    GROUP BY group_column
)
SELECT 
    group_column,
    calculated_metric
FROM cte_name
WHERE calculated_metric > (
    SELECT AGG_FUNC(calculated_metric) FROM cte_name
)
ORDER BY calculated_metric DESC;
```

*(Multiple CTEs can be chained in a single `WITH` clause separated by a comma: `WITH cte_one AS (...), cte_two AS (SELECT ... FROM cte_one) SELECT ... FROM cte_two;`)*

---

## 5. Analytical Window Functions (`OVER`)

* **`PARTITION BY` vs. `GROUP BY`:** With `GROUP BY`, you either collapse rows into summary groups (losing individual row details) or group by every individual row column (isolating each row in a 1-row group where rows cannot be ranked against peers). **`PARTITION BY` gives you both at once:** it keeps every individual row on screen while grouping rows into buckets behind the scenes to reset the `#1, #2, #3` counter for each bucket.
* **Placement Rule:** Window Functions (`OVER`) are only valid inside the `SELECT` list (and `ORDER BY`)—never inside `WHERE`, `GROUP BY`, or `HAVING`.

### Window Function Syntax Anatomy
```sql
WINDOW_FUNCTION() OVER (
    [PARTITION BY partition_col1, ...]
    ORDER BY sort_col1 [ASC | DESC], sort_col2 [ASC | DESC], ...
) AS window_alias
```
* **Omitting `PARTITION BY`:** `WINDOW_FUNCTION() OVER (ORDER BY sort_col1)` treats the entire table as a single bucket (`1` to `N`).
* **Date / Timestamp Sorting (`ASC` vs. `DESC`):** Because later dates are numerically larger (e.g., `2016 > 2012`), `ORDER BY date_col DESC` places the **most recent / youngest** date at `#1`, whereas `ORDER BY date_col ASC` places the **earliest / oldest** date at `#1`.

### Ranking Functions Reference
| Function | Tie-Breaking Behavior | Example Sequence (Tie at #1) |
| :--- | :--- | :---: |
| **`ROW_NUMBER()`** | Assigns a unique sequential integer to every row in the partition (never ties, never gaps). | `1, 2, 3, 4` |
| **`RANK()`** | Standard competition ranking; tied rows share the same rank and **skip** subsequent number(s). | `1, 1, 3, 4` |
| **`DENSE_RANK()`** | Consecutive tier ranking; tied rows share the same rank and **never skip** the next integer. | `1, 1, 2, 3` |

### Two-Stage Window Filtering Pattern (Finding the "Top $N$ Per Group")
Because `WHERE` executes before `SELECT` (where `OVER` is calculated), you cannot filter a window rank in the same query's `WHERE` clause. Calculate the rank in Stage 1 (`WITH`), then filter it in Stage 2:
```sql
WITH ranked_cte AS (
    SELECT 
        partition_col,
        detail_col,
        sort_col,
        WINDOW_FUNCTION() OVER (
            PARTITION BY partition_col
            ORDER BY sort_col DESC
        ) AS window_alias
    FROM source_table_or_view
    [WHERE raw_row_condition]   -- Note: NO GROUP BY needed for basic row ranking!
)
SELECT 
    partition_col,
    detail_col,
    sort_col,
    window_alias
FROM ranked_cte
WHERE window_alias <= n         -- Safe: window_alias is already a finished column from Stage 1
ORDER BY partition_col ASC, window_alias ASC; -- Outer ORDER BY controls final display order
```

---

## 6. SQL Logical Order of Execution

The relational engine evaluates SQL clauses in the following strict logical order (not top-to-bottom as typed):

1. **`FROM` / `JOIN`** — Assemble and link source tables or views.
2. **`WHERE`** — Filter raw rows prior to grouping or windowing (`SELECT` aliases and Window Functions do **not** exist yet!).
3. **`GROUP BY`** — Bucket remaining rows into summary groups.
4. **`HAVING`** — Filter aggregated groups.
5. **`SELECT`** — Evaluate column expressions, aliases, and **Window Functions (`OVER`)**.
6. **`DISTINCT`** — Deduplicate projected output rows.
7. **`ORDER BY`** — Sort the final result set (`SELECT` aliases are accessible here).
8. **`LIMIT` / `OFFSET`** — Restrict final output row count.

