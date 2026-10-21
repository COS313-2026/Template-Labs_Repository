-- ==========================================
-- STUDENT NAME: [Name]
-- STUDENT ID: [ID]
-- ==========================================

-- ------------------------------------------------------------------------------
-- Task 1: The Unified Roster (Views & Complexity Abstraction)
-- ------------------------------------------------------------------------------
-- 1. Write your idempotent view definition for vw_team_rosters below.
-- Required Output Columns: team_name, first_name, last_name, phone, parent_email




-- 2. Write your two verification queries below:
--    * Verification Query 1: Total row count of vw_team_rosters (Expected: 11,934)
--    * Verification Query 2: First 5 records ordered by team_name, last_name, first_name




-- ------------------------------------------------------------------------------
-- Task 2: The Above-Average Alert (CTEs & Multi-Stage Pipelines)
-- ------------------------------------------------------------------------------
-- Write your two-stage CTE pipeline querying vw_team_rosters to find teams whose
-- active player count strictly exceeds the league-wide average team player count below.
-- Order by roster_size descending, then team_name ascending.
-- Required Output Columns: team_name, roster_size (Expected: 3 rows)




-- ------------------------------------------------------------------------------
-- Task 3: Auto-Assigning Jerseys (Analytical Window Functions)
-- ------------------------------------------------------------------------------
-- Write your two-stage window query on vw_team_rosters to assign strictly sequential,
-- unique jersey numbers starting at 1 per team (ordered by last_name, first_name).
-- Filter the outer query to display only jersey numbers 1 and 2, ordered by team_name, jersey_number.
-- Required Output Columns: team_name, first_name, last_name, jersey_number (Expected: 12 rows)




-- ------------------------------------------------------------------------------
-- Task 4: The Defensive Analytics Audit (Defensive Design & 3VL)
-- ------------------------------------------------------------------------------
-- 1. Write your Verification Query 1 below to prove the total row count of
--    qualifying U10 active player audit records (Expected: 4,001):




-- 2. Write your Verification Query 2 below to display the first 5 audit records
--    ordered by last_name ascending, first_name ascending, and gear_status ascending.
-- Required Output Columns: first_name, last_name, gear_status, payment_tier
