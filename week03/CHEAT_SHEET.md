# Week 3 Cheat Sheet: Multiple Relations & Joins

This cheat sheet provides a quick reference for the SQL syntax and rules required to successfully combine multiple tables in a relational database.

---

## 1. The Anatomy of a JOIN
When you join two tables, you are taking data from **Table A** and stitching it horizontally to data in **Table B**.

```sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m      -- The "Left" Table
INNER JOIN vendor_gear_shipments v   -- The "Right" Table
  ON m.registration_id = v.registration_id;  -- The Stitch (How they connect)
```

### The Table Aliasing Rule
When you join tables together, you **MUST** tell the database exactly which table a column belongs to.
*   **Good:** `SELECT m.first_name`
*   **Bad:** `SELECT first_name` *(If both tables have a `first_name` column, the database will crash with an "ambiguous column" error!)*

---

## 2. The Taxonomy of JOINs

### A. INNER JOIN (The Intersection)
Returns **only** the rows that have matching values in **both** tables. If a user didn't get a shipment, they vanish from the results.
```sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m
INNER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id;
```

### B. LEFT JOIN (The Protector)
Returns **ALL** rows from the Left table, and the matched rows from the Right table. If there is no match on the right side, it simply fills those columns with `NULL`.
```sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m
LEFT JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id;
```

---

## 3. The Golden Rule: ON vs. WHERE
When writing complex queries, it is incredibly easy to confuse these two clauses. Remember this rule:
*   **`ON` dictates HOW:** Use it strictly to define the structural relationship between the keys (how the tables stitch together).
*   **`WHERE` dictates WHICH:** Use it strictly to filter the data down *after* the tables have been stitched.

**Example (A filtered JOIN):**
```sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m
INNER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id  -- HOW they stitch together
WHERE m.team_name = 'U10 Storm';            -- WHICH rows to keep after stitching
```

---

## 4. The "Orphan" Finder
You can use a `LEFT JOIN` combined with a `WHERE ... IS NULL` clause to find records in the left table that are "missing" from the right table. 

**Example (Find users who never received a shipment):**
```sql
SELECT m.first_name, m.last_name
FROM master_registration_dump m
LEFT JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id
WHERE v.shipment_id IS NULL;  -- Look for the missing right-side ID!
```

---

## 5. Joining with Aggregations (GROUP BY)
You can combine everything you learned in Week 2 with your new JOIN skills! Just remember to prefix your columns with their table aliases.

**Example (Find total shipped quantity per age group):**
```sql
SELECT m.age_group, SUM(v.shipped_quantity)
FROM master_registration_dump m
INNER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id
GROUP BY m.age_group;
```

---

## ⚠️ DANGER: The Cartesian Product 
If you forget to include the `ON` clause, the database doesn't know how to match the rows. It will multiply every single row in Table A by every single row in Table B. 

If you join 50,000 users and 50,000 shipments without an `ON` clause, you will instantly generate a **2.5 billion row table** and likely crash the server! Always check your `ON` clause!
