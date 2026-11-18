// ==========================================
// STUDENT NAME: [Name]
// STUDENT ID:   [ID]
// DATE:         [Date]
// ==========================================

db = db.getSiblingDB("sports_db_nosql");

// Idempotent pre-flight cleanup: Remove any previous homework test documents so this script can be re-run safely
db.live_game_logs.deleteMany({ game_id: { $in: [4095, 4096, 4097, 4099] } });

// ------------------------------------------------------------------------------
// Task 1: Legacy Data & The Frozen Record Dilemma (strict vs. moderate)
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// 1. Insert Legacy Document (Game 4099) bypassing validation:
// TODO: Insert Game 4099 (sport_type: "SOCCER_OLD") using { bypassDocumentValidation: true }



// 2. Prove Lockout under "strict" validation (try / catch update to home_team_name):
try {
  // TODO: Attempt update of home_team_name for Game 4099
  db.live_game_logs.updateOne(

  );
} catch (err) {
  console.log("Update blocked under strict validation as expected! Error Code:", err.code);
}

// 3. Thaw the Frozen Record (Switch validationLevel to "moderate" via collMod):
// TODO: Execute collMod command setting validationLevel to "moderate"



// 4. Execute Thawed Update (Update home_team_name to "Legacy United"):
// TODO: Re-execute updateOne to change home_team_name to "Legacy United" for Game 4099



// 5. Verification Query (Project game_id, sport_type, home_team_name; suppress _id):
// TODO: Write find query retrieving Game 4099 with projections and suppressed _id




// [DIAGNOSTIC REFLECTION 1]
// 1. The "Moderate" Compromise: What is the exact operational difference between
//    "strict" and "moderate"? What happens if a client attempts to insert a brand new
//    document with sport_type: "SOCCER_OLD"?
// Answer:
// 

// 2. The Technical Debt Trade-off: Why does "moderate" represent technical debt?
//    What migration strategy should an architect execute before switching back to "strict"?
// Answer:
// 



// ------------------------------------------------------------------------------
// Task 2: In-Flight Schema Evolution via collMod (Adding Lacrosse & Overtime)
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// TIP: Copy your validated $jsonSchema from Lab Ticket 1 as your starting baseline,
// then add "lacrosse" to the sport_type enum and add overtime_periods to properties.
// Remember: collMod completely overwrites the validator, so include the full schema!

// 1. Evolve Schema via collMod (Add "lacrosse" to enum, add overtime_periods bounds 1-4):
db.runCommand({
  collMod: "live_game_logs",
  validator: {
    $jsonSchema: {
      // TODO: Full evolved schema including lacrosse and overtime_periods
    }
  },
  validationLevel: "moderate",
  validationAction: "error"
});

// 2. Certify Valid Evolution (Insert Game 4095 with lacrosse and overtime_periods: 2):
// TODO: Insert compliant Game 4095 Lacrosse match document



// 3. Adversarial Boundary Test (Attempt to insert Game 4096 with overtime_periods: 5):
try {
  // TODO: Execute boundary test insert for Game 4096 per HOMEWORK.md Task 2
  db.live_game_logs.insertOne({

  });
} catch (err) {
  console.log("Overtime bound violation blocked as expected! Code:", err.code);
  console.log("Violation Details:", JSON.stringify(err.errInfo.details.schemaRulesNotSatisfied[0].propertiesNotSatisfied[0]));
}

// 4. Verification Query (Project game_id, sport_type, overtime_periods, current_score; suppress _id):
// TODO: Write find query retrieving Game 4095 with projections and suppressed _id




// [DIAGNOSTIC REFLECTION 2]
// 1. The Overwrite Hazard: In SQL, ALTER TABLE only requires you to declare the new column.
//    In MongoDB, running collMod with only overtime_periods succeeds ({ ok: 1 }). Why is this
//    an operational disaster in a team environment? What happens to current_score and timeline_events?
// Answer:
// 

// 2. Zero Downtime Migration: Compare MongoDB's collMod with PostgreSQL's ALTER TABLE ADD COLUMN CHECK.
//    Why can the SQL command block writes on large tables, while MongoDB's collMod executes instantaneously?
// Answer:
// 



// ------------------------------------------------------------------------------
// Task 3: Staged Rollout with validationAction: "warn"
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// 1. Switch to Warn Mode (Set validationAction: "warn" via collMod):
// TODO: Execute collMod command setting validationAction to "warn"



// 2. Simulate Rogue Write (Insert Game 4097 with sport_type: "curling"):
// TODO: Insert rogue Game 4097 per HOMEWORK.md Task 3



// 3. Verify Disk Persistence (Query Game 4097 projecting game_id, sport_type, match_status):
// TODO: Write find query retrieving Game 4097 with projections and suppressed _id



// 4. Restore Production Perimeter (Set validationAction: "error" via collMod):
// TODO: Execute collMod command setting validationAction back to "error"



// 5. Clean Up Probe Document (Delete Game 4097):
// TODO: Delete Game 4097


// [DIAGNOSTIC REFLECTION 3]
// 1. The Observability Pipeline: Where does MongoDB record schema violation alerts in "warn" mode?
//    How do engineering teams use server logs to audit violations before switching to "error"?
// Answer:
// 

// 2. The Danger of Prolonged "Warn" Mode: What happens to database data hygiene if left in "warn" mode?
// Answer:
// 



// ------------------------------------------------------------------------------
// Task 4: Architectural Reflection (Relational vs. Document Data Governance)
// ------------------------------------------------------------------------------
// [DIAGNOSTIC REFLECTION 4]
// 1. Atomic Boundaries & Foreign Keys: Can $jsonSchema enforce that home_team_id exists in a teams collection?
//    Where must cross-collection referential integrity be enforced in a document database?
// Answer:
// 

// 2. The "Whole Dollar" Decimal Trap: Why does cost: { bsonType: "double" } reject 100 in MongoDB,
//    while PostgreSQL NUMERIC(10,2) accepts it?
// Answer:
// 

// 3. Schema-on-Write vs. Schema-on-Read Evolution: How does adding $jsonSchema combine document velocity
//    with relational safety guarantees?
// Answer:
// 

// 4. The Polyglot Decision Matrix: Why archive completed matches from MongoDB into 3NF PostgreSQL?
// Answer:
// 
