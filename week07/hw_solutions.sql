-- ==========================================
-- STUDENT NAME: [Name]
-- STUDENT ID: [ID]
-- ==========================================

-- ------------------------------------------------------------------------------
-- Task 1: The Failed Deletion (Referential Integrity)
-- ------------------------------------------------------------------------------
-- 1. In a 2–3 sentence SQL comment, explain which Foreign Key constraint blocked
--    the deletion, what rule is in effect, and why this prevents orphaned records:
-- 2. Include your commented-out DELETE statement immediately below your explanation:



-- ------------------------------------------------------------------------------
-- Task 2: The Safe Migration (Cascading Updates)
-- ------------------------------------------------------------------------------
-- 1. Write the UPDATE statement to change Alex Oakley's email in the users table:
-- 2. Write the SELECT query against registrations to prove the cascade worked:
-- 3. In a SQL comment, explain how registrations received the update automatically:



-- ------------------------------------------------------------------------------
-- Task 3: The Disaster Drill (ACID Transactions)
-- ------------------------------------------------------------------------------
-- Write your complete ACID transaction block below:
-- (BEGIN, UPDATE, SELECT ... ORDER BY registration_id LIMIT 5, ROLLBACK, SELECT ... ORDER BY registration_id LIMIT 5):



-- ------------------------------------------------------------------------------
-- Task 4: The Great Migration (Moving to Surrogate Keys - Boss Level)
-- ------------------------------------------------------------------------------
-- 1. Write your single, atomic transaction block (BEGIN ... COMMIT) executing
--    all migration phases (schema expansion, data backfill, constraint swapping, cleanup):
-- 2. Immediately after COMMIT, write your verification query against information_schema.columns:



