-- ==============================================================================
-- LIVE DEMO 3: The Heart-Attack & Instant Rollback (Slide 15 - Minute 45)
-- ==============================================================================
-- GOAL: The Disaster Drill! Demonstrate the catastrophic danger of a naked
--       UPDATE/DELETE without a WHERE clause, and prove how ACID transactions
--       save a data engineer's career via ROLLBACK.
--
-- PREREQUISITE:
-- The 'registrations' table must exist in your database.
-- (If missing, create it from master_registration_dump).
--
-- INSTRUCTOR GUIDE:
-- 1. Execute STEP 1 to show the real baseline revenue from registrations.
-- 2. Execute STEP 2 (BEGIN;) to open the transaction safety net.
-- 3. Execute STEP 3 to simulate the accidental wipeout of all fee revenue.
-- 4. Execute STEP 4 to prove the catastrophe to the class (Total = $0.00).
-- 5. Execute STEP 5 (ROLLBACK;) to trigger the recovery.
-- 6. Execute STEP 6 to prove all revenue was 100% restored.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- STEP 1: The Baseline Ledger (Real Production Data)
-- Show the class how much revenue the league currently holds:
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_registrations, 
    SUM(fee_amount)::money AS total_revenue
FROM registrations;

-- EXPECTED RESULT:
-- 49,564 registrations and $1,316,365.00 in revenue!


-- ------------------------------------------------------------------------------
-- STEP 2: The Safety Net (Open the Transaction)
-- ------------------------------------------------------------------------------
BEGIN;

-- TALKING POINT:
-- "Notice PostgreSQL says BEGIN. We are now in a sandboxed transaction timeline.
--  Nothing we do here is permanent until we explicitly type COMMIT."


-- ------------------------------------------------------------------------------
-- STEP 3: The Heart-Attack (Accidental Naked UPDATE)
-- Imagine it is 2:00 AM. You meant to waive ONE player's fee, but forgot WHERE!
-- ------------------------------------------------------------------------------
UPDATE registrations 
SET fee_amount = 0.00;

-- EXPECTED RESULT:
-- UPDATE 49564


-- ------------------------------------------------------------------------------
-- STEP 4: The Proof of Disaster
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_registrations, 
    SUM(fee_amount)::money AS total_revenue
FROM registrations;

-- EXPECTED RESULT:
-- total_revenue: $0.00!
--
-- ASK THE CLASS:
-- "Did we just bankrupt the league? If this ran on a naked connection without 
--  BEGIN, how do we get that money back? We can't! But watch this..."


-- ------------------------------------------------------------------------------
-- STEP 5: The Miraculous Recovery
-- ------------------------------------------------------------------------------
ROLLBACK;

-- EXPECTED RESULT:
-- ROLLBACK


-- ------------------------------------------------------------------------------
-- STEP 6: The Proof of Complete Restoration
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_registrations, 
    SUM(fee_amount)::money AS total_revenue
FROM registrations;

-- TALKING POINT:
-- "Every single penny across all 49,564 registrations ($1,316,365.00) is 100% restored!
--  The Golden Rule: Never run an UPDATE or DELETE in production without BEGIN!"
