-- ==============================================================================
-- WEEK 8: DATABASE TRANSITION & SYNCHRONIZATION SCRIPT
-- ==============================================================================
-- Run this script to:
--   1. Reload all 50,000 original records from the Week 1 CSV seed file into
--      master_registration_dump (healing any deletions or edits from Weeks 1-7).
--   2. Reconcile legacy flat-file anomalies and rebuild the normalized 3NF tables.
--   3. Apply Week 7 protective constraints, cleanses, and the 'user_id'
--      surrogate key migration (from Week 7 Homework Task 4).
--
-- Usage: psql -U admin -d sports_db -f week08/week08_transition.sql
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

-- Reconcile legacy user-level and registration-level anomalies (from Week 7 Transition)
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

-- 1. DROP EXISTING NORMALIZED TABLES (CASCADE removes dependent views)
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

-- 5. REBUILD GEAR ORDERS TABLE
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

-- 6. APPLY WEEK 7 CONSTRAINTS AND CLEANUP
-- Seed corrupted negative fees (from Week 7 Lab) and cleanse them to $0.00 scholarships
UPDATE registrations SET fee_amount = -50.00 WHERE fee_amount < 15.00;
UPDATE registrations SET fee_amount = 0.00 WHERE fee_amount < 0.00;

-- Simulate scholarship recipients whose equipment orders have not yet been submitted
DELETE FROM gear_orders 
WHERE registration_id IN (
    SELECT registration_id FROM registrations WHERE fee_amount = 0.00
);

-- Apply constraints
ALTER TABLE registrations ADD CONSTRAINT fk_user FOREIGN KEY (user_email) REFERENCES users(email) ON UPDATE CASCADE;
ALTER TABLE registrations ADD CONSTRAINT fk_team FOREIGN KEY (team_name) REFERENCES teams(team_name);
ALTER TABLE gear_orders ADD CONSTRAINT fk_registration FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE;
ALTER TABLE registrations ADD CONSTRAINT unique_registration UNIQUE (user_email, team_name, assigned_role);
ALTER TABLE registrations ADD CONSTRAINT check_fee CHECK (fee_amount >= 0.00);

-- Migrate the angry user (Week 7 Homework Task 2)
UPDATE users SET email = 'deleted_user@example.com' WHERE email = 'alex.oakley65@outlook.com';

-- ==============================================================================
-- 7. THE GREAT MIGRATION (Surrogate Keys - From Week 7 Homework Task 4)
-- ==============================================================================
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
