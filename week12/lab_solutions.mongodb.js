// ==========================================
// STUDENT NAME: [Name]
// STUDENT ID:   [ID]
// DATE:         [Date]
// ==========================================

// ------------------------------------------------------------------------------
// Ticket 0: Environment Verification & Vulnerability Audit
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// 1. Confirm baseline count (should return 20):
db.live_game_logs.countDocuments();

// 2. Vulnerability Probe (Insert corrupted document and observe schemaless acceptance):
db.live_game_logs.insertOne({
  game_id: "BAD_9999",                    // String instead of integer!
  sport_type: "quidditch",                // Fictional unapproved sport!
  current_score: { home: -50, away: 100 } // Negative score!
});

// 3. Clean up the probe document:
db.live_game_logs.deleteOne({ game_id: "BAD_9999" });



// ------------------------------------------------------------------------------
// Ticket 1: Applying the Defensive Perimeter (collMod with $jsonSchema)
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// Apply collMod command with full $jsonSchema validator:
// (Follow the structural requirements in IN_CLASS_LAB.md Ticket 1)
db.runCommand({
  collMod: "live_game_logs",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        // TODO: Add mandatory top-level keys per IN_CLASS_LAB.md
      ],
      properties: {
        // TODO: Define all properties per the specification in IN_CLASS_LAB.md

      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});


// [DIAGNOSTIC REFLECTION 1]
// 1. The Hybrid Perimeter: Why did we configure additionalProperties: false inside
//    current_score while leaving the root document open (additionalProperties: true)?
// Answer:
// 

// 2. Integer Defense: Why did we define game_id with bsonType: ["int", "long"]
//    instead of simply using bsonType: "number"? What dangerous loophole opens up
//    if you use "number" on an ID field, and why do we include both "int" and "long"?
// Answer:
// 



// ------------------------------------------------------------------------------
// Ticket 2: The Adversarial Red-Team Challenge
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// Baseline Reference Document (Satisfies all Ticket 1 rules):
// To test vulnerabilities in isolation, mutate ONLY the target property being tested:
// {
//   game_id: 4091,
//   sport_type: "soccer",
//   match_status: "in_progress",
//   home_team_id: 101,
//   away_team_id: 102,
//   current_score: { home: 0, away: 0 }
// };

// Attack 1 (Type Breach - String game_id):
try {
  // TODO: Execute Attack 1
  db.live_game_logs.insertOne({

  });
} catch (err) {
  console.log("Attack 1 Blocked! Code:", err.code);
  console.log("Attack 1 Details:", JSON.stringify(err.errInfo.details.schemaRulesNotSatisfied[0].propertiesNotSatisfied[0]));
}

// Attack 2 (Domain Range Breach - Negative score):
try {
  // TODO: Execute Attack 2
  db.live_game_logs.insertOne({

  });
} catch (err) {
  console.log("Attack 2 Blocked! Code:", err.code);
  const scoreDetails = err.errInfo.details.schemaRulesNotSatisfied[0].propertiesNotSatisfied[0].details[0].propertiesNotSatisfied[0];
  console.log("Attack 2 Details:", JSON.stringify(scoreDetails));
}

// Attack 3 (Categorical Enum Breach - Unapproved sport):
try {
  // TODO: Execute Attack 3
  db.live_game_logs.insertOne({

  });
} catch (err) {
  console.log("Attack 3 Blocked! Code:", err.code);
  console.log("Attack 3 Details:", JSON.stringify(err.errInfo.details.schemaRulesNotSatisfied[0].propertiesNotSatisfied[0]));
}

// Attack 4 (Required Key Omission - Missing home_team_id):
try {
  // TODO: Execute Attack 4
  db.live_game_logs.insertOne({

  });
} catch (err) {
  console.log("Attack 4 Blocked! Code:", err.code);
  console.log("Attack 4 Missing Property:", JSON.stringify(err.errInfo.details.schemaRulesNotSatisfied[0].missingProperties));
}


// [DIAGNOSTIC REFLECTION 2]
// 1. Zero Auto-Casting in Action: In SQL (PostgreSQL), '4091' is auto-converted to an integer. Why did MongoDB reject "4091" instead of converting it? What does this prove about MongoDB's type evaluation?
// Answer:
// 

// 2. Error Payload Forensics: What propertyName, operatorName, and consideredValue were reported in Attack 2?
// Answer:
// 



// ------------------------------------------------------------------------------
// Ticket 3: Valid Operation Compliance
// ------------------------------------------------------------------------------
db = db.getSiblingDB("sports_db_nosql");

// Idempotent safeguard: Clean up Game 4090 before insert so script can be re-run cleanly
db.live_game_logs.deleteOne({ game_id: 4090 });

// 1. Insert Compliant Match Document (Game 4090):
// TODO: Insert compliant match document for Game 4090 (status: "in_progress", score: 1-0, with timeline event at minute 22)



// 2. Verification Query (Project game_id, sport_type, match_status, current_score; suppress _id):
// TODO: Write find query retrieving Game 4090 with requested projections and suppressed _id




// [DIAGNOSTIC REFLECTION 3]
// All-or-Nothing Gatekeeping: If Game 4090 had 15 valid fields, but one event had elapsed_minute: 250,
// does MongoDB drop the bad event or reject the whole document? How does this compare to relational atomicity?
// Answer:
// 
