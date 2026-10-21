-- ==========================================
-- STUDENT NAME: [Name]
-- STUDENT ID: [ID]
-- ==========================================

-- ------------------------------------------------------------------------------
-- Ticket 1: The Roster Safety & Age-Eligibility Audit (Defensive SQL)
-- ------------------------------------------------------------------------------
-- Write your defensive audit query for active players on 'U14 Eagles' below.
-- Sort by emergency_email ASC, last_name ASC, first_name ASC, birthdate ASC, and limit to 8 rows.
-- Required Output Columns: first_name, last_name, birthdate, emergency_email, eligibility_status (Expected: 8 rows)




-- ------------------------------------------------------------------------------
-- Ticket 2: The Equipment Manifest (Relational Views)
-- ------------------------------------------------------------------------------
-- 1. Write your idempotent view definition for vw_equipment_manifest below.
-- Required Output Columns: age_group, gear_item, gear_size, total_quantity




-- 2. Write your two verification queries below:
--    * Verification Query 1: Total row count of the view (Expected: 84)
--    * Verification Query 2: First 5 records ordered by age_group, gear_item, gear_size




-- ------------------------------------------------------------------------------
-- Ticket 3: The Roster Age Extremes (Window Functions & Two-Stage Scoping)
-- ------------------------------------------------------------------------------
-- Write your two-stage analytical query to find active players in the top 2
-- competition age ranks (youngest to oldest) on each team below.
-- Required Output Columns: team_name, first_name, last_name, birthdate, age_rank (Expected: 14 rows)




