-- ==============================================================================
-- LIVE DEMO 1: The Creation Order Crash & Fix (Slide 7 - Minute 15)
-- ==============================================================================
-- GOAL: Demonstrate the "chicken or the egg" DDL dependency error live in class,
--       and show how the idempotent script pattern solves it.
--
-- INSTRUCTOR GUIDE:
-- 1. Execute STEP 1 to show the crash and explain the error to students.
-- 2. Execute STEP 2 to show the clean idempotent solution.
-- 3. Execute STEP 3 to verify both tables exist and are connected.
-- 4. Execute STEP 4 for cleanup.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- STEP 1: The Dependency Crash (The Chicken or the Egg Trap)
-- Attempt to create the child table referencing a parent that does not exist yet!
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS demo_registrations CASCADE;
DROP TABLE IF EXISTS demo_users CASCADE;

-- Run this statement to trigger the intentional crash:
CREATE TABLE demo_registrations (
    registration_id SERIAL PRIMARY KEY,
    user_email VARCHAR(255) REFERENCES demo_users(email)
);

-- EXPECTED RESULT IN TERMINAL:
-- ERROR:  relation "demo_users" does not exist
--
-- TALKING POINT FOR STUDENTS:
-- "PostgreSQL cannot point a foreign key at a parent table that does not physically 
-- exist on disk yet! Table relationships have strict creation dependencies."


-- ------------------------------------------------------------------------------
-- STEP 2: The Idempotent Fix (Parents First, Children Second)
-- ------------------------------------------------------------------------------

-- First: Create the PARENT table
CREATE TABLE demo_users (
    email VARCHAR(255) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

-- Second: Create the CHILD table (now it succeeds!)
CREATE TABLE demo_registrations (
    registration_id SERIAL PRIMARY KEY,
    user_email VARCHAR(255) REFERENCES demo_users(email)
);

-- EXPECTED RESULT:
-- CREATE TABLE
-- CREATE TABLE


-- ------------------------------------------------------------------------------
-- STEP 3: Verify the Dependency Graph
-- ------------------------------------------------------------------------------
SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('demo_users', 'demo_registrations')
ORDER BY table_name DESC;


-- ------------------------------------------------------------------------------
-- STEP 4: Cleanup
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS demo_registrations CASCADE;
DROP TABLE IF EXISTS demo_users CASCADE;
