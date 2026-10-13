-- ==============================================================================
-- LIVE DEMO 2: Testing the Armor (Slide 11 - Minute 32)
-- ==============================================================================
-- GOAL: Prove to students that database constraint errors are not software failures;
--       they are proof that the storage engine's armor is defending data integrity.
--
-- INSTRUCTOR GUIDE:
-- 1. Execute SETUP to establish the armored demo tables.
-- 2. Execute TEST 1 to show the CHECK constraint shield catching invalid money.
-- 3. Execute TEST 2 to show the FOREIGN KEY shield catching a phantom parent.
-- 4. Execute TEST 3 to show a valid insert succeeding cleanly.
-- 5. Execute CLEANUP.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- SETUP: Build a clean armored demo schema
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS demo_roster CASCADE;
DROP TABLE IF EXISTS demo_divisions CASCADE;

CREATE TABLE demo_divisions (
    division_name VARCHAR(50) PRIMARY KEY,
    max_teams INT CHECK (max_teams > 0)
);

INSERT INTO demo_divisions (division_name, max_teams)
VALUES ('U10 Competitive', 8);

CREATE TABLE demo_roster (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    division_name VARCHAR(50) REFERENCES demo_divisions(division_name),
    fee_amount NUMERIC(8, 2) CONSTRAINT check_positive_fee CHECK (fee_amount >= 0.00)
);


-- ------------------------------------------------------------------------------
-- TEST 1: The Check Constraint Shield (Negative Money!)
-- ------------------------------------------------------------------------------
-- Attempt to insert a corrupted negative fee:
INSERT INTO demo_roster (player_name, division_name, fee_amount)
VALUES ('Bad Data Player', 'U10 Competitive', -50.00);

-- EXPECTED RESULT IN TERMINAL:
-- ERROR:  new row for relation "demo_roster" violates check constraint "check_positive_fee"
-- DETAIL: Failing row contains (1, Bad Data Player, U10 Competitive, -50.00).
--
-- TALKING POINT FOR STUDENTS:
-- "Notice that the database stopped this before it ever touched disk. 
--  Without this constraint, negative revenue corrupts your financial reports!"


-- ------------------------------------------------------------------------------
-- TEST 2: The Referential Integrity Shield (The Ghost Division!)
-- ------------------------------------------------------------------------------
-- Attempt to link a player to a division that does not exist in the parent table:
INSERT INTO demo_roster (player_name, division_name, fee_amount)
VALUES ('Lost Player', 'Mars Rovers', 75.00);

-- EXPECTED RESULT IN TERMINAL:
-- ERROR:  insert or update on table "demo_roster" violates foreign key constraint "demo_roster_division_name_fkey"
-- DETAIL: Key (division_name)=(Mars Rovers) is not present in table "demo_divisions".
--
-- TALKING POINT FOR STUDENTS:
-- "A foreign key guarantees that child rows can never point to non-existent parents.
--  SQL error messages like this are proof that your relational armor is working!"


-- ------------------------------------------------------------------------------
-- TEST 3: The Valid Insert (Passing Through the Armor)
-- ------------------------------------------------------------------------------
INSERT INTO demo_roster (player_name, division_name, fee_amount)
VALUES ('Alex Morgan', 'U10 Competitive', 75.00);

-- Verify that the valid row was stored:
SELECT player_id, player_name, division_name, fee_amount 
FROM demo_roster;


-- ------------------------------------------------------------------------------
-- CLEANUP
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS demo_roster CASCADE;
DROP TABLE IF EXISTS demo_divisions CASCADE;
