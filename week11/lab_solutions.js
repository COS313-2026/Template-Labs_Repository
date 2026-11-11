// ==========================================
// STUDENT NAME: [Name]
// STUDENT ID: [ID]
// ==========================================

// Switch to the target database
db = db.getSiblingDB("sports_db_nosql");

// ------------------------------------------------------------------------------
// Ticket 0: Environment Verification
// ------------------------------------------------------------------------------
// Verify that live_game_logs contains 20 documents:
db.live_game_logs.countDocuments();


// ------------------------------------------------------------------------------
// Ticket 1: [AUDIT-9101] Live Scoreboard Audit & Document Projection
// ------------------------------------------------------------------------------
// Write your query to find completed soccer matches where home score >= 3.
// Project game_id, home_team_id, away_team_id, current_score, suppressing _id:




// [DIAGNOSTIC REFLECTION 1]
// 1. In a normalized relational schema, retrieving match results and score snapshots
//    often requires joining games with score or event tables. What performance and
//    modeling advantage does storing current_score as an embedded subdocument offer?
// 2. Why does MongoDB include _id in query results by default even when you explicitly
//    list specific fields in your projection, and what exact syntax is required to omit it?
// Answer (1-2 sentences):
// 




// ------------------------------------------------------------------------------
// Ticket 2: [DISCIPLINE-9102] The Red Card Disciplinary Incident ($elemMatch)
// ------------------------------------------------------------------------------
// 1. The Trap Query: Run the naive dot-notation query (returns 4 matches):




// 2. The Correct Isolated Query: Use $elemMatch on timeline_events ensuring
//    event_type = "red_card" AND elapsed_minute >= 45 on the SAME event object.
//    Project game_id, home_team_id, away_team_id, timeline_events, suppressing _id:




// [DIAGNOSTIC REFLECTION 2]
// 1. Look at Game 4007's document in MongoDB. Why did the naive dot-notation query
//    mistakenly match Game 4007? (What was the red card minute, and what other event occurred?)
// 2. Why does MongoDB's query engine require $elemMatch when filtering on multiple
//    properties of an embedded object within an array?
// Answer (1-2 sentences):
// 




// ------------------------------------------------------------------------------
// Ticket 3: [OPS-9103] In-Game Score Correction & Event Appending ($set & $push)
// ------------------------------------------------------------------------------
// 1. Write the update command on game_id: 4055 using $set to change current_score.away to 2
//    and $push to append the minute 88 substitution event:
//    (Tip: If you run your script repeatedly, re-run seed_live_game_logs.js to reset)




// 2. Verification Query: Retrieve Game 4055 to verify the updated score and event log:




// [DIAGNOSTIC REFLECTION 3]
// 1. If a developer accidentally issued an update without the $set operator
//    (e.g., passing { "current_score.away": 2 } directly), what data loss would occur?
// 2. In a high-traffic sports application, what architectural risk arises if an array
//    field inside a single MongoDB document grows without bound?
// Answer (1-2 sentences):
// 

