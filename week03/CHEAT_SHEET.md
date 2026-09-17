# Week 3 Cheat Sheet: Multiple Relations & Joins

This cheat sheet provides a quick reference for the SQL syntax and rules required to successfully combine multiple tables in a relational database.

---

## 1. The Anatomy of a JOIN
When you join two tables, you are taking data from **Table A** and stitching it horizontally to data in **Table B**.

`sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m      -- The "Left" Table
INNER JOIN vendor_gear_shipments v   -- The "Right" Table
  ON m.registration_id = v.registration_id;  -- The Stitch (How they connect)
`

### The Table Aliasing Rule
When you join tables together, you **MUST** tell the database exactly which table a column belongs to.
*   **Good:** SELECT m.first_name
*   **Bad:** SELECT first_name *(If both tables have a irst_name column, the database will crash with an "ambiguous column" error!)*

---

## 2. The Taxonomy of JOINs

> **The Shorthand Rule:** In SQL, the words INNER and OUTER are optional keywords. JOIN is identical to INNER JOIN, and LEFT JOIN is identical to LEFT OUTER JOIN. 
> **However, for this class, you MUST use the full phrasing (e.g., INNER JOIN, LEFT OUTER JOIN).** Explicit code is readable code.

### A. CROSS JOIN (The Cartesian Product)
Multiplies **every** row in Table A by **every** row in Table B. Rarely used (e.g., generating exhaustive grids).
`sql
SELECT s.student_name, g.score
FROM demo_students s
CROSS JOIN demo_grades g;
`

### B. INNER JOIN (The Intersection)
Returns **only** the rows that have matching values in **both** tables. If a student didn't get a grade, they vanish.
`sql
SELECT s.student_name, g.score
FROM demo_students s
INNER JOIN demo_grades g ON s.student_id = g.student_id;
`

### C. LEFT OUTER JOIN (Protect the Left)
Returns **ALL** rows from the Left table, and the matched rows from the Right. Unmatched right-side columns get NULL.
`sql
SELECT s.student_name, g.score
FROM demo_students s
LEFT OUTER JOIN demo_grades g ON s.student_id = g.student_id;
`

### D. RIGHT OUTER JOIN (Protect the Right)
Returns **ALL** rows from the Right table, and the matched rows from the Left. Unmatched left-side columns get NULL.
`sql
SELECT s.student_name, g.score
FROM demo_students s
RIGHT OUTER JOIN demo_grades g ON s.student_id = g.student_id;
`

### E. FULL OUTER JOIN (The Complete Picture)
Returns **ALL** rows from both tables, placing NULLs on whichever side is missing a match.
`sql
SELECT s.student_name, g.score
FROM demo_students s
FULL OUTER JOIN demo_grades g ON s.student_id = g.student_id;
`

---

## 3. The Golden Rule: ON vs. WHERE
When writing complex queries, it is incredibly easy to confuse these two clauses. Remember this rule:
*   **ON dictates HOW:** Use it strictly to define the structural relationship between the keys (how the tables stitch together).
*   **WHERE dictates WHICH:** Use it strictly to filter the data down *after* the tables have been stitched.

**Example (A filtered JOIN):**
`sql
SELECT m.first_name, v.shipped_item
FROM master_registration_dump m
INNER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id  -- HOW they stitch together
WHERE m.team_name = 'U10 Storm';            -- WHICH rows to keep after stitching
`

---

## 4. The "Orphan" Finder
You can use a LEFT OUTER JOIN combined with a WHERE ... IS NULL clause to find records in the left table that are "missing" from the right table. 

**Example (Find users who never received a shipment):**
`sql
SELECT m.first_name, m.last_name
FROM master_registration_dump m
LEFT OUTER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id
WHERE v.shipment_id IS NULL;  -- Look for the missing right-side ID!
`

---

## 5. Joining with Aggregations (GROUP BY)
You can combine everything you learned in Week 2 with your new JOIN skills! Just remember to prefix your columns with their table aliases.

**Example (Find total shipped quantity per age group):**
`sql
SELECT m.age_group, SUM(v.shipped_quantity)
FROM master_registration_dump m
INNER JOIN vendor_gear_shipments v 
  ON m.registration_id = v.registration_id
GROUP BY m.age_group;
`

---

## ?? The Cartesian Explosion (Why we use INNER JOIN)
If you use the old legacy syntax (FROM table_a, table_b) and forget the WHERE clause, the database will multiply every single row together (50,000 $\times$ 50,000 = a 2.5 billion row table). 
**This is why we ALWAYS use explicit INNER JOIN syntax.** The modern INNER JOIN forces you to write an ON clause. If you forget it, the database will safely throw a syntax error instead of crashing the server!
