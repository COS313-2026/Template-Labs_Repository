-- ==============================================================================
-- WEEK 7: DATABASE TRANSITION & RESET SCRIPT
-- ==============================================================================
-- Run this script to reset your database to the START of Week 7.
-- It drops all relational tables and cleanses any legacy anomalies
-- in master_registration_dump so you begin with a clean slate.
--
-- STUDENTS: You will physically create 'users' and 'teams' in Ticket 2!
--
-- Usage: psql -d sports_db -f week07_transition.sql
-- ==============================================================================

-- 1. DROP ALL RELATIONAL TABLES (SAFE RESET)
DROP TABLE IF EXISTS gear_orders CASCADE;
DROP TABLE IF EXISTS registrations CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. ENSURE MASTER_REGISTRATION_DUMP IS CLEANSED OF ANOMALIES
-- (Fixes any lingering single-row updates from Week 6 live demos so that
--  Ticket 2's SELECT DISTINCT into users won't hit duplicate email collisions)
CREATE TEMP TABLE true_users AS
SELECT email, 
       MIN(first_name) as first_name, 
       MIN(last_name) as last_name, 
       MIN(phone) as phone, 
       MIN(birthdate) as birthdate, 
       MIN(parent_email) as parent_email
FROM master_registration_dump
GROUP BY email;

UPDATE master_registration_dump m
SET first_name   = t.first_name,
    last_name    = t.last_name,
    phone        = t.phone,
    birthdate    = t.birthdate,
    parent_email = t.parent_email
FROM true_users t
WHERE m.email = t.email;

DROP TABLE true_users;

-- Also reconcile any registration-level anomalies in the dump
CREATE TEMP TABLE true_registrations AS
SELECT email, team_name, assigned_role,
       MIN(fee_amount) as fee_amount,
       MIN(payment_status) as payment_status,
       MIN(registered_at) as registered_at
FROM master_registration_dump
GROUP BY email, team_name, assigned_role;

UPDATE master_registration_dump m
SET fee_amount     = t.fee_amount,
    payment_status = t.payment_status,
    registered_at  = t.registered_at
FROM true_registrations t
WHERE m.email = t.email 
  AND m.team_name = t.team_name 
  AND m.assigned_role = t.assigned_role;

DROP TABLE true_registrations;

-- 3. STATUS VERIFICATION
SELECT 'Database successfully reset to Week 7 start state. Only master_registration_dump exists.' AS status;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT email) AS unique_users FROM master_registration_dump;
