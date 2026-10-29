-- ==============================================================================
-- WEEK 9: DATABASE TRANSITION & BOTTLENECK GENERATION SCRIPT
-- ==============================================================================
-- Run this script to:
--   1. Ensure the core 3NF tables (users, teams, registrations, gear_orders)
--      are in their standardized post-surrogate-migration state.
--   2. Drop any lingering views or custom indexes from prior runs.
--   3. Build and populate the 1,006,600-row 'audit_logs' table (25 login events
--      for each of the 40,264 users) to create an authentic Sequential Scan
--      bottleneck for B-Tree index tuning.
--
-- Usage: psql -U admin -d sports_db -f week09/week09_transition.sql
-- ==============================================================================

-- 0. RESTORE ALL 50,000 ORIGINAL RECORDS INTO MASTER_REGISTRATION_DUMP
CREATE TABLE IF NOT EXISTS master_registration_dump (
    registration_id INT,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    birthdate DATE,
    parent_email VARCHAR(255),
    assigned_role VARCHAR(50),
    team_name VARCHAR(100),
    age_group VARCHAR(20),
    fee_amount NUMERIC(10,2),
    payment_status VARCHAR(50),
    gear_item VARCHAR(100),
    gear_size VARCHAR(20),
    gear_quantity INT,
    registered_at TIMESTAMP
);

TRUNCATE TABLE master_registration_dump;

\copy master_registration_dump FROM '/workspace/.devcontainer/seed_data/master_registration_dump.csv' DELIMITER ',' CSV HEADER;

-- Reconcile legacy user-level and registration-level anomalies
CREATE TEMP TABLE true_users AS
SELECT email, 
       MIN(first_name) AS first_name, 
       MIN(last_name) AS last_name, 
       MIN(phone) AS phone, 
       MIN(birthdate) AS birthdate, 
       MIN(parent_email) AS parent_email
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

CREATE TEMP TABLE true_registrations AS
SELECT email, team_name, assigned_role,
       MIN(fee_amount) AS fee_amount,
       MIN(payment_status) AS payment_status,
       MIN(registered_at) AS registered_at
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

-- 1. DROP EXISTING TABLES & VIEWS CLEANLY
DROP TABLE IF EXISTS books, checkouts, members, vendor_gear_shipments CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS gear_orders CASCADE;
DROP TABLE IF EXISTS registrations CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. REBUILD USERS TABLE (40,264 rows)
CREATE TABLE users (
    email VARCHAR PRIMARY KEY,
    first_name VARCHAR,
    last_name VARCHAR,
    phone VARCHAR,
    birthdate DATE,
    parent_email VARCHAR
);

INSERT INTO users (email, first_name, last_name, phone, birthdate, parent_email)
SELECT DISTINCT email, first_name, last_name, phone, birthdate, parent_email
FROM master_registration_dump
ORDER BY email;

-- 3. REBUILD TEAMS TABLE (6 rows)
CREATE TABLE teams (
    team_name VARCHAR PRIMARY KEY,
    age_group VARCHAR
);

INSERT INTO teams (team_name, age_group)
SELECT DISTINCT team_name, age_group
FROM master_registration_dump
ORDER BY team_name;

-- 4. REBUILD REGISTRATIONS TABLE (49,564 rows)
CREATE TABLE registrations (
    registration_id SERIAL PRIMARY KEY,
    user_email VARCHAR,
    team_name VARCHAR,
    assigned_role VARCHAR,
    fee_amount NUMERIC
);

INSERT INTO registrations (user_email, team_name, assigned_role, fee_amount)
SELECT DISTINCT email, team_name, assigned_role, fee_amount
FROM master_registration_dump
ORDER BY email, team_name, assigned_role;

-- 5. REBUILD GEAR ORDERS TABLE (41,077 rows after scholarship cleanup)
CREATE TABLE gear_orders (
    order_id SERIAL PRIMARY KEY,
    registration_id INT,
    gear_item VARCHAR,
    gear_size VARCHAR,
    gear_quantity INT
);

INSERT INTO gear_orders (registration_id, gear_item, gear_size, gear_quantity)
SELECT r.registration_id, m.gear_item, m.gear_size, m.gear_quantity
FROM master_registration_dump m
JOIN registrations r 
  ON m.email = r.user_email 
 AND m.team_name = r.team_name 
 AND m.assigned_role = r.assigned_role
WHERE m.gear_item IS NOT NULL;

-- 6. APPLY WEEK 7 CONSTRAINTS, CLEANUP, AND SURROGATE KEY MIGRATION
UPDATE registrations SET fee_amount = -50.00 WHERE fee_amount < 15.00;
UPDATE registrations SET fee_amount = 0.00 WHERE fee_amount < 0.00;

DELETE FROM gear_orders 
WHERE registration_id IN (
    SELECT registration_id FROM registrations WHERE fee_amount = 0.00
);

ALTER TABLE registrations ADD CONSTRAINT fk_user FOREIGN KEY (user_email) REFERENCES users(email) ON UPDATE CASCADE;
ALTER TABLE registrations ADD CONSTRAINT fk_team FOREIGN KEY (team_name) REFERENCES teams(team_name);
ALTER TABLE gear_orders ADD CONSTRAINT fk_registration FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE;
ALTER TABLE registrations ADD CONSTRAINT unique_registration UNIQUE (user_email, team_name, assigned_role);
ALTER TABLE registrations ADD CONSTRAINT check_fee CHECK (fee_amount >= 0.00);

UPDATE users SET email = 'deleted_user@example.com' WHERE email = 'alex.oakley65@outlook.com';

ALTER TABLE users ADD COLUMN user_id SERIAL;
ALTER TABLE registrations ADD COLUMN user_id INT;

UPDATE registrations r
SET user_id = u.user_id
FROM users u
WHERE r.user_email = u.email;

ALTER TABLE registrations DROP CONSTRAINT fk_user;
ALTER TABLE users DROP CONSTRAINT users_pkey;
ALTER TABLE users ADD PRIMARY KEY (user_id);
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

ALTER TABLE registrations 
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE registrations DROP COLUMN user_email;

-- ==============================================================================
-- 7. BUILD THE 1,006,600-ROW AUDIT_LOGS TABLE (THE PERFORMANCE BOTTLENECK)
-- ==============================================================================
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    action VARCHAR(50),
    user_email VARCHAR(255),
    ip_address VARCHAR(45),
    log_timestamp TIMESTAMP
);

-- Generate 25 login history rows per user (40,264 users * 25 = 1,006,600 rows)
INSERT INTO audit_logs (action, user_email, ip_address, log_timestamp)
SELECT 
    CASE WHEN gs.n = 25 THEN 'password_reset' ELSE 'login_success' END,
    u.email, 
    '192.168.1.' || ((u.user_id + gs.n) % 254 + 1):: text,
    TIMESTAMP '2026-01-01 08:00:00' + (gs.n || ' days')::interval
FROM 
    users u 
CROSS JOIN 
    generate_series(1, 25) AS gs(n);

-- Update table statistics so the PostgreSQL Query Planner has exact row counts
ANALYZE users;
ANALYZE teams;
ANALYZE registrations;
ANALYZE gear_orders;
ANALYZE audit_logs;
