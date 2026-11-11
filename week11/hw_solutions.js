// ==========================================
// STUDENT NAME: [Name]
// STUDENT ID: [ID]
// ==========================================

// Switch to the target database
db = db.getSiblingDB("sports_db_nosql");

// ------------------------------------------------------------------------------
// Task 1: Clean Sheet / Defensive Shutout Sweep (Cursor Sorting & Limiting)
// ------------------------------------------------------------------------------
// Write your query to find completed soccer shutouts (current_score.away = 0).
// Sort descending by current_score.home, breaking ties by game_id ASC, and limit to top 3.
// Project game_id, home_team_name, away_team_name, current_score, suppressing _id:




// [DIAGNOSTIC REFLECTION 1]
// 1. In what order did MongoDB return the top 3 shutout games, and what were the final scores?
// 2. In MongoDB query filters and sort criteria, why is enclosing nested dot-notation paths
//    (such as "current_score.home") in quotation marks strictly mandatory?
// Answer (1-2 sentences):
// 




// ------------------------------------------------------------------------------
// Task 2: Stoppage-Time Heroics (Multi-Criteria Array Matching with $elemMatch)
// ------------------------------------------------------------------------------
// Write your query to find soccer games with a goal at or after minute 90
// with an identified player (actor_user_id exists and is not null).
// Project game_id, home_team_name, away_team_name, timeline_events, suppressing _id:




// [DIAGNOSTIC REFLECTION 2]
// 1. Inspect the timeline_events for the 2 matching games: Which players (actor_user_id)
//    scored in stoppage time, in what minute did each goal occur, and what was the description?
// 2. Contrast this MongoDB query with how you would construct this in our normalized
//    PostgreSQL schema: What tables would you join, and what join condition would connect them?
// Answer (1-2 sentences):
// 




// ------------------------------------------------------------------------------
// Task 3: Cross-Sport Division Sweep (Set Membership with $in)
// ------------------------------------------------------------------------------
// Write your query to find games where sport_type is in ["soccer", "basketball"]
// and current_score.home >= 50.
// Project game_id, sport_type, home_team_name, current_score, suppressing _id:




// [DIAGNOSTIC REFLECTION 3]
// 1. Why did only basketball games appear in the final query results even though "soccer"
//    was explicitly included in the $in filter list?
// 2. How does MongoDB's schema-on-read flexibility allow soccer and basketball games to
//    reside in the same collection without database migration scripts or schema alterations?
// Answer (1-2 sentences):
// 




// ------------------------------------------------------------------------------
// Task 4: Architectural Reflection (NoSQL Document Store vs. Relational RDBMS)
// ------------------------------------------------------------------------------
// [DIAGNOSTIC REFLECTION 4]
// 1. During live match play, why is MongoDB's document model superior for high-frequency
//    in-game score updates and timeline event logging compared to writing to multiple
//    normalized tables in PostgreSQL? (Disk I/O, locking, atomicity).
// Answer:
// 

// 2. Once the tournament weekend ends and administrators need to generate season-wide
//    league standings, calculate playoff tiebreakers, and audit referee payroll across
//    thousands of past games, why does PostgreSQL (relational 3NF) regain a massive advantage?
// Answer:
// 

// 3. What operational risk does MongoDB's "schema-on-read" introduce if different client
//    applications write timeline events without strict centralized schema validation?
// Answer:
// 

