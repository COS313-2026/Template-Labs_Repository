# COS313: NoSQL Schema Validation & Data Governance Reference Sheet

This syntax and architecture reference serves as the standard guide for **Week 12 (Lab & Homework)**. It provides MongoDB `$jsonSchema` grammar, BSON type specifications, operational governance commands (`collMod`, `validationLevel`, `validationAction`), Error 121 forensic navigation, and the complete NoSQL Data Dictionary without disclosing assignment solutions.

---

## 1. Schema & Data Dictionary (`sports_db_nosql.live_game_logs`)

All Week 12 lab tickets and homework tasks operate against the `live_game_logs` collection within the `sports_db_nosql` database.

### Target Document Specification
Each document in `live_game_logs` represents a single sports match undergoing live tracking or completed play:

```json
{
  "_id": ObjectId("6af8e67f9b898a056807478d"),
  "game_id": 4001,
  "sport_type": "soccer",
  "match_status": "completed",
  "home_team_id": 101,
  "home_team_name": "Maple Grove United",
  "away_team_id": 102,
  "away_team_name": "Blaine Fire",
  "current_score": {
    "home": 3,
    "away": 2
  },
  "timeline_events": [
    {
      "elapsed_minute": 14,
      "period": "1H",
      "event_type": "goal",
      "actor_user_id": 1012,
      "details": "Opening strike from top of the box"
    },
    {
      "elapsed_minute": 28,
      "period": "1H",
      "event_type": "foul",
      "actor_user_id": 1055,
      "details": "Tripping outside penalty area"
    }
  ]
}
```

### Data Dictionary

| Field Name | Target BSON Type | Nullable? | Description & Domain Rules |
| :--- | :--- | :---: | :--- |
| `_id` | `objectId` | No | Unique MongoDB primary key (generated automatically). |
| `game_id` | `int` or `long` | No | Unique positive game identifier ($\ge 1$). Whole integer. |
| `sport_type` | `string` | No | Approved sport whitelist: `"soccer"`, `"basketball"`, `"volleyball"` (or `"lacrosse"` in HW). |
| `match_status` | `string` | No | Workflow state: `"scheduled"`, `"in_progress"`, `"completed"`, or `"cancelled"`. |
| `home_team_id` | `int` or `long` | No | Unique positive team identifier ($\ge 1$). Whole integer. |
| `home_team_name`| `string` | Yes | Human-readable home team name. |
| `away_team_id` | `int` or `long` | No | Unique positive team identifier ($\ge 1$). Whole integer. |
| `away_team_name`| `string` | Yes | Human-readable away team name. |
| `current_score` | `object` | No | Real-time score sub-document: `{ home: int, away: int }`. Both values must be $\ge 0$. |
| `current_score.home` | `int` or `long` | No | Home team score ($\ge 0$). No fractions permitted. |
| `current_score.away` | `int` or `long` | No | Away team score ($\ge 0$). No fractions permitted. |
| `timeline_events`| `array` | Yes | List of in-game chronological event objects. |
| `timeline_events[].elapsed_minute` | `number` | No | Match minute ($0 \le \text{minute} \le 150$). Accepts decimals for stoppage time. |
| `timeline_events[].period` | `string` | No | Game period (e.g., `"1H"`, `"2H"`, `"1Q"`, `"2Q"`, `"OT"`). |
| `timeline_events[].event_type` | `string` | No | Whitelisted event category (`"goal"`, `"foul"`, `"yellow_card"`, `"red_card"`, `"substitution"`, etc.). |
| `timeline_events[].actor_user_id` | `int` or `long` | Yes | Player/coach user identifier involved in the event. |
| `timeline_events[].details` | `string` | Yes | Free-text referee description of the play. |
| `overtime_periods` | `int` or `long` | Yes | Optional field added during schema evolution ($1 \le \text{ot} \le 4$). |

---

## 2. The BSON Type Palette (Beyond Basic JSON)

Standard JSON has only 6 data types and lacks native dates, binary objects, or integer distinctions. When declaring `$jsonSchema` rules, MongoDB uses **BSON binary type strings**:

| BSON Type Keyword | Physical Representation | Best Use Case | Example |
| :--- | :--- | :--- | :--- |
| `"string"` | UTF-8 Text | Titles, names, notes, codes | `"plumbing"`, `"Fieldhouse"` |
| `"bool"` | Boolean | Flags, verified checkboxes | `true`, `false` |
| `"objectId"` | 12-byte unique key | MongoDB `_id` | `ObjectId("...")` |
| `"date"` | 64-bit UTC timestamp | Audit logs, schedules | `ISODate("2026-11-17T15:00:00Z")` |
| `"object"` | Embedded sub-document | Grouped related properties | `{ company_name: "Apex Electric" }` |
| `"array"` | Ordered list of items | Event logs, tags, checklists | `[ { step: 1 }, ... ]` |
| **`"int"`** | 32-bit signed integer | Standard discrete counts, IDs | `8104` (up to $\pm 2.1$ Billion) |
| **`"long"`** | 64-bit signed integer | Massive IDs, millisecond timestamps | `9007199254740993` |
| **`"double"`** | 64-bit IEEE 754 float | Ratings, hours, measurements | `2.5`, `98.6` |
| **`"decimal"`** | 128-bit exact decimal | Exact financial accounting | `NumberDecimal("450.00")` |
| **`"number"`** | **Umbrella Type** | **Continuous numeric values** | Matches `int`, `long`, `double`, or `decimal`! |

---

## 3. The Clean 2-Rule Enterprise Numeric Standard

MongoDB’s validator does **ZERO automatic type conversion**. It inspects the literal binary tag attached to the data:
* In SQL: `INSERT 100` into `NUMERIC` $\rightarrow$ automatically converted to `100.00`.
* In MongoDB: If schema demands `bsonType: "double"`, inserting `{ estimated_cost: 100 }` (no decimal) is serialized as an `int` and **rejected with Error 121!**

### The Standard 2-Rule Formula:
1. **For Money, Hours & Continuous Measurements:**  
   Use the **`"number"` umbrella alias**. This accepts whole numbers ($100$), floats ($100.50$), and exact decimals while strictly rejecting strings:
   ```javascript
   estimated_cost: { bsonType: "number", minimum: 0 }
   ```
2. **For Discrete IDs, Counts & Quantities:**  
   Use the **multi-type array `["int", "long"]`** to enforce discrete whole numbers and accept both 32-bit and 64-bit driver integers, while strictly forbidding decimals and fractions:
   ```javascript
   ticket_id: { bsonType: ["int", "long"], minimum: 1 }
   ```

---

## 4. Core `$jsonSchema` Syntax Pattern

*(Illustrated using our isolated lecture entity: `facility_maintenance_tickets`)*

Validation rules are packaged inside the `$jsonSchema` operator:

```javascript
validator: {
  $jsonSchema: {
    bsonType: "object",
    required: ["ticket_id", "facility_id", "issue_type", "urgency", "status"],
    properties: {

      // 1. Scalar discrete integer constraint (positive whole numbers)
      ticket_id: {
        bsonType: ["int", "long"],
        minimum: 1,
        description: "Must be a positive integer"
      },

      facility_id: {
        bsonType: ["int", "long"],
        minimum: 1,
        description: "Must be a positive integer"
      },

      // 2. Whitelisted categorical enum strings
      issue_type: {
        enum: ["plumbing", "electrical", "hvac", "turf", "lighting"],
        description: "Must be an approved facility issue category"
      },

      urgency: {
        enum: ["routine", "urgent", "emergency"],
        description: "Operational priority tier"
      },

      status: {
        enum: ["open", "assigned", "in_repair", "closed"],
        description: "Ticket lifecycle status"
      },

      // 3. Continuous numeric value (currency / measurements)
      estimated_cost: {
        bsonType: "number",
        minimum: 0,
        description: "Estimated cost cannot be negative"
      },

      // 4. Hierarchical nested sub-document with strict whitelist
      contractor: {
        bsonType: "object",
        additionalProperties: false, // <-- Rejects unexpected fields inside subdocument!
        required: ["company_name", "license_verified"],
        properties: {
          company_name:     { bsonType: "string" },
          lead_technician:  { bsonType: "string" },
          license_verified: { bsonType: "bool" }
        }
      },

      // 5. Array of objects with item validation
      work_log: {
        bsonType: "array",
        items: {
          bsonType: "object",
          required: ["step_number", "action_taken", "hours_spent"],
          properties: {
            step_number:  { bsonType: ["int", "long"], minimum: 1 },
            action_taken: { bsonType: "string" },
            hours_spent:  { bsonType: "number", minimum: 0.1, maximum: 24.0 }
          }
        }
      }

    }
  }
}
```

---

## 5. Operational Governance Commands

In production, dropping collections destroys data. DBAs apply and tune schema rules in-flight using the **`collMod`** database command:

### A. Applying Schema to an Active Collection (`collMod`)
```javascript
db.runCommand({
  collMod: "<collection_name>",
  validator: {
    $jsonSchema: { ... }
  },
  validationLevel: "strict",
  validationAction: "error"
});
```

> **The Overwrite Rule:** `collMod` completely **replaces** the current validator if it exists (it does **not** merge properties!). Anything that is in the current validator but not in the new validator will be lost! When evolving an active schema, you must re-submit the complete, evolved `$jsonSchema` retaining all existing rules.
>
> **💡 Zero-Downtime Migration:** Unlike SQL (where `ALTER TABLE ... ADD COLUMN ... CHECK (...)` scans all disk rows and can lock active tables), `collMod` only updates the in-memory catalog entry, executing in milliseconds with zero downtime.

### B. The 3 `validationLevel` Options

| Setting | New Inserts | Updates to Clean Docs | Updates to Dirty Legacy Docs | Best Use Case |
| :--- | :---: | :---: | :---: | :--- |
| **`"strict"`** *(Default)* | ✅ Validated | ✅ Validated | 🛑 **Re-checked** (Blocks updates if any old typo remains) | Steady-state production. |
| **`"moderate"`** | ✅ Validated | ✅ Validated | 🚪 **EXEMPT** (Grandfathers old invalid docs) | Temporary migration bridge while legacy data is scrubbed. |
| **`"off"`** | ❌ Bypassed | ❌ Bypassed | ❌ Bypassed | Emergency maintenance or high-speed bulk CSV imports. |

> **⚠️ Warning:** Under `validationLevel: "moderate"`, already-dirty documents completely bypass validation. That means someone could add *more* bad data to an already-dirty document! Always treat `moderate` as a temporary bridge, clean up dirty records with a script, and flip to `strict`.

### C. The 2 `validationAction` Options

| Setting | Action on Violation | Log Output | Best Use Case |
| :--- | :--- | :--- | :--- |
| **`"error"`** *(Default)* | **Aborts write immediately!** Returns Error 121. | Standard error | Hard enforcement once apps are certified. |
| **`"warn"`** | **Write succeeds to disk!** | Writes violation to server log (`mongod.log` / container stdout) | Dry-run audit for 14 days before hard cutover. |

### D. What `$jsonSchema` Cannot Do (Engine Boundaries)

1. **No Cross-Collection Foreign Keys:** `$jsonSchema` evaluates a single document in isolation; it cannot query another collection (e.g. `teams`) to verify that an ID exists. Referential integrity across collections must be enforced in the application layer.
2. **No Cross-Document Uniqueness:** `$jsonSchema` cannot verify whether another document already claims a value. Cross-document uniqueness is enforced by **Unique Indexes** (`db.collection.createIndex({ key: 1 }, { unique: true })`).
3. **No Multi-Document Assertions:** Cannot validate cross-document aggregations or rolling sums.

---

## 6. How to Read Error 121 (`DocumentValidationFailure`)

When a write violates schema rules, MongoDB 7.0 returns a forensic JSON payload:

*(Example: Submitting a maintenance ticket with negative `estimated_cost: -150.00`)*

```javascript
MongoServerError: Document failed validation
details: {
  operatorName: "$jsonSchema",
  schemaRulesNotSatisfied: [
    {
      operatorName: "properties",
      propertiesNotSatisfied: [
        {
          propertyName: "estimated_cost",     // <-- 1. Failing property name
          description: "Estimated cost cannot be negative",
          details: [
            {
              operatorName: "minimum",        // <-- 2. Violated rule (minimum: 0)
              specifiedAs: { minimum: 0 },
              reason: "comparison failed",
              consideredValue: -150           // <-- 3. Offending value sent by app
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 7. Execution Best Practices (`mongosh` & VS Code)

### A. MongoDB Playgrounds (VS Code)
1. Open your solution file (`lab_solutions.mongodb.js` or `hw_solutions.mongodb.js`).
2. Highlight your command and press **`Ctrl + Alt + S`** (or right-click $\rightarrow$ **Run Selected Lines From Playground**).
3. To run all commands: Click the green **Play (▶)** button in the top-right corner.
4. Save the side-by-side `Results.json` tab for submission!

### B. Terminal Execution (`mongosh`)
```bash
# Connect to interactive database shell
mongosh sports_db_nosql

# Run a solution script directly from terminal
mongosh sports_db_nosql < week12/lab_solutions.mongodb.js

# Reset collection to clean Week 11 baseline if needed:
mongosh sports_db_nosql < week11/seed_live_game_logs.js
```
