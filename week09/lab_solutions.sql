-- ==========================================
-- STUDENT NAME: [Name]
-- STUDENT ID: [ID]
-- ==========================================

-- ------------------------------------------------------------------------------
-- Ticket 1: [INCIDENT-8104] SecOps Audit Lags & Baseline Execution Plan
-- ------------------------------------------------------------------------------
-- 1. Safely remove idx_audit_email if it exists (for clean re-runs), then write
--    your baseline EXPLAIN ANALYZE diagnostic on audit_logs for
--    user_email = 'william.martinez72@corp.io' below:




-- [DIAGNOSTIC REFLECTION 1]
-- Inspect your EXPLAIN ANALYZE terminal output above:
-- 1. Following the '->' arrow to the deepest leaf node, what physical scan node did PostgreSQL select?
-- 2. Why did each worker process have to inspect and discard over 335,000 rows ('Rows Removed by Filter')
--    just to locate 25 matching records?
-- 3. What was the unindexed total Execution Time in milliseconds?
-- Answer (1-2 sentences):
-- 




-- 2. Verification Query 1: Total count of logs for 'william.martinez72@corp.io'
-- Required Output Column: total_user_logs (Expected: 25)




-- 3. Verification Query 2: First 5 logs for 'william.martinez72@corp.io'
--    ordered by log_timestamp ASC, log_id ASC
-- Required Output Columns: log_id, action, user_email, ip_address, log_timestamp (Expected: 5 rows)




-- ------------------------------------------------------------------------------
-- Ticket 2: [PERF-8105] B-Tree Remediation & The Selectivity Tipping Point
-- ------------------------------------------------------------------------------
-- 1. Safely remove any existing idx_audit_email index, build the B-Tree index
--    idx_audit_email on audit_logs(user_email), and refresh planner statistics on audit_logs:




-- 2. Re-run your EXPLAIN ANALYZE diagnostic for user_email = 'william.martinez72@corp.io'
--    to test post-index performance:




-- [DIAGNOSTIC REFLECTION 2A: High Selectivity]
-- In 1-2 sentences, what two execution nodes replaced the sequential scan after creating
-- idx_audit_email, and by approximately what factor did execution time improve?
-- Answer:
-- 




-- 3. Selectivity Tipping Point Experiment:
--    Build temporary index idx_audit_action on audit_logs(action) and refresh statistics:




-- 4. Run an EXPLAIN ANALYZE diagnostic for action = 'password_reset' (4% of table):




-- 5. Run an EXPLAIN ANALYZE diagnostic for action = 'login_success' (96% of table):




-- [DIAGNOSTIC REFLECTION 2B: The Selectivity Tipping Point]
-- Compare the plans for password_reset (4%) vs login_success (96%) on idx_audit_action:
-- 1. What scan node did PostgreSQL use for password_reset?
-- 2. What scan node did PostgreSQL use for login_success?
-- 3. Why did the Query Planner abandon the index for login_success even though it exists?
-- Answer (1-2 sentences):
-- 




-- 6. Clean up temporary index idx_audit_action to avoid Write Penalty overhead:




-- ------------------------------------------------------------------------------
-- Ticket 3: [AUDIT-8106] Data Dictionary Audit & Ghost Index Verification
-- ------------------------------------------------------------------------------
-- 1. Verification Query 1: Query pg_indexes for tablename = 'audit_logs'
--    ordered by indexname ASC.
-- Required Output Columns: tablename, indexname, indexdef (Expected: 2 rows)




-- [DIAGNOSTIC REFLECTION 3: Ghost Indexes]
-- You only ran CREATE INDEX once in Ticket 2, yet pg_indexes displays TWO indexes for audit_logs.
-- What is the other index, and why did PostgreSQL create it automatically?
-- Answer:
-- 




-- 2. Verification Query 2: Count total indexes on tablename = 'audit_logs'
-- Required Output Column: total_indexes (Expected: 2)



