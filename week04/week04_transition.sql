-- =================================================================
-- WEEK 4 TRANSITION SCRIPT
-- 
-- The Business Scenario: The U10 Tigers team lost their coach due
-- to a scheduling conflict. We need to remove the coach assignment 
-- so the logistics team can find a replacement.
-- =================================================================

-- Create the Staffing Anomaly for Lab Ticket 2
-- We are deleting the coach records for the U10 Tigers so the EXCEPT query returns a result.
DELETE FROM master_registration_dump
WHERE team_name = 'U10 Tigers' 
  AND assigned_role = 'coach';

-- Create the Scholarship Anomaly for HW Task 2
-- We are setting one player's fee to 0 so the IN subquery returns a result.
UPDATE master_registration_dump
SET fee_amount = 0
WHERE team_name = 'U12 Bears' 
  AND assigned_role = 'player'
  AND first_name = 'Alex'
  AND last_name = 'Brodie';
