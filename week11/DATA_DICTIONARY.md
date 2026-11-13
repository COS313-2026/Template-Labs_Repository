# Week 11 Data Dictionary: Youth Sports Document Store

**Course:** COS 313: Database Systems (Fall 2026, Bethel University)  
**Database:** `sports_db_nosql`  
**Collection:** `live_game_logs` *(20 pre-populated match documents)*  
**Context:** This data dictionary documents the document structure, BSON data types, embedded subdocuments, arrays, and business rules for the NoSQL document store used in Week 11.

---

## 1. Document Architecture & Mental Model

In a relational database (PostgreSQL), data is normalized across 4+ tables (`games`, `teams`, `venues`, `game_events`) linked by foreign keys and joined at runtime. 

In a **Document Database (MongoDB)**, there are no separate entity tables or relational joins. A sports match is stored as a **single, self-contained BSON document** on disk. Nested subdocuments (1:1) and chronological play-by-play events (1:many) are physically embedded directly within the document.

### Annotated BSON Document Archetype

Below is the concrete physical blueprint of a match document as stored in the `live_game_logs` collection:

```javascript
{
  // --- TOP-LEVEL SCALAR ATTRIBUTES ---
  "_id": ObjectId("6af4a692..."),             // 12-byte unique BSON identifier (Primary Key)
  "game_id": 4001,                            // Int32: Natural league identifier
  "sport_type": "soccer",                     // String: 'soccer' | 'basketball'
  "match_status": "completed",                // String: 'scheduled' | 'in_progress' | 'completed'

  // --- DENORMALIZED ATTRIBUTES (avoids relational joins to teams table) ---
  "home_team_id": 101,                        // Int32: Foreign reference to league team
  "home_team_name": "Maple Grove United",     // String: Denormalized display name
  "away_team_id": 102,                        // Int32: Foreign reference to league team
  "away_team_name": "Blaine Fire",            // String: Denormalized display name

  // --- 1:1 EMBEDDED SUBDOCUMENT (Queried using dot-notation: "current_score.home") ---
  "current_score": {
    "home": 3,                                // Int32: Points/goals scored (>= 0)
    "away": 2                                 // Int32: Points/goals scored (>= 0)
  },

  // --- 1:1 EMBEDDED SUBDOCUMENT (Queried using dot-notation: "venue.city") ---
  "venue": {
    "facility_id": 12,                        // Int32: Facility complex ID
    "court_field": "Field 3",                 // String: Pitch or court
    "city": "Maple Grove"                     // String: Municipality
  },

  // --- 1:N EMBEDDED ARRAY (Requires $elemMatch when querying multiple attributes) ---
  "timeline_events": [
    {
      "elapsed_minute": 14,                   // Int32: Official game minute (90+ = stoppage time)
      "period": "1H",                         // String: '1H', '2H', 'ET', 'Q1', 'Q2', etc.
      "event_type": "goal",                   // String: 'goal', 'foul', 'yellow_card', 'red_card'
      "actor_user_id": 1024,                  // Int32 / null: Player reference
      "details": "Header off corner kick"     // String: Play narrative
    },
    {
      "elapsed_minute": 92,
      "period": "2H",
      "event_type": "goal",
      "actor_user_id": 1088,
      "details": "Stoppage time winner"
    }
  ],

  // --- TECHNICAL AUDITING SUBDOCUMENT ---
  "metadata": {
    "schema_version": 2,                      // Int32: Document schema version
    "ingest_timestamp": ISODate("2026-10-18T14:00:00Z") // UTC ingestion timestamp
  }
}
```

---

## 2. Top-Level Document Schema (`live_game_logs`)

Each document represents a single athletic contest (soccer or basketball) undergoing real-time tracking or archived post-game.

| Field Name | BSON / JSON Type | Constraint / Requirement | Description & Business Rules | Example Value |
| :--- | :--- | :--- | :--- | :--- |
| **`_id`** | `ObjectId` | **PRIMARY KEY** (Auto) | Unique 12-byte BSON identifier assigned automatically by MongoDB. | `ObjectId("6af4a692...")` |
| **`game_id`** | `Int32` | `REQUIRED, UNIQUE` | Natural game identifier matching league scheduling and referee rosters. | `4001` |
| **`sport_type`** | `String` | `REQUIRED` | Type of sport: `'soccer'` or `'basketball'`. Determines allowable periods and scoring scales. | `"soccer"` |
| **`match_status`** | `String` | `REQUIRED` | Lifecycle state of match: `'scheduled'`, `'in_progress'`, or `'completed'`. | `"completed"` |
| **`home_team_id`** | `Int32` | `REQUIRED` | Foreign reference to the home team in the relational league registry. | `101` |
| **`home_team_name`**| `String` | `REQUIRED` | Denormalized display name of the home team (avoids multi-table relational joins). | `"Maple Grove United"` |
| **`away_team_id`** | `Int32` | `REQUIRED` | Foreign reference to the visiting/away team. | `102` |
| **`away_team_name`**| `String` | `REQUIRED` | Denormalized display name of the visiting/away team. | `"Blaine Fire"` |
| **`current_score`** | `Embedded Document`| `REQUIRED` | Real-time score snapshot object. See Section 3. | `{ home: 3, away: 2 }` |
| **`timeline_events`**| `Array of Objects` | `REQUIRED` | Chronological array of in-game plays, goals, and disciplinary actions. See Section 4. | `[ { ... }, { ... } ]` |
| **`venue`** | `Embedded Document`| `REQUIRED` | Facility location details. See Section 5. | `{ facility_id: 12, ... }`|
| **`metadata`** | `Embedded Document`| `REQUIRED` | Technical audit trail and schema migration tracking. See Section 6. | `{ schema_version: 2, ... }`|

---

## 3. Embedded Subdocument: `current_score`

A nested 1:1 subdocument providing atomic reads and in-place updates (`$set`) for scoreboard feeds.

| Field Name | BSON Type | Constraint | Description | Example Value |
| :--- | :--- | :--- | :--- | :--- |
| **`home`** | `Int32` | `REQUIRED, >= 0` | Points or goals scored by the home team. Soccer ranges `0–5+`; Basketball ranges `50–100+`. | `3` |
| **`away`** | `Int32` | `REQUIRED, >= 0` | Points or goals scored by the away team. A value of `0` indicates a defensive clean sheet/shutout. | `2` |

* **Query Syntax Note:** Accessing nested score fields requires dot notation enclosed in quotes: `"current_score.home"` or `"current_score.away"`.

---

## 4. Array of Subdocuments: `timeline_events`

An embedded 1:many array representing chronological actions occurring on the pitch or court. Elements are ordered by `elapsed_minute` ascending.

| Field Name | BSON Type | Constraint | Description | Example Value |
| :--- | :--- | :--- | :--- | :--- |
| **`elapsed_minute`**| `Int32` | `REQUIRED, >= 0` | Official game clock minute when event occurred. Minutes `90+` represent stoppage time in soccer. | `92` |
| **`period`** | `String` | `REQUIRED` | Match regulation segment: <br>• Soccer: `'1H'` (First Half), `'2H'` (Second Half), `'ET'` (Extra Time)<br>• Basketball: `'Q1'`, `'Q2'`, `'Q3'`, `'Q4'`, `'OT'` (Overtime) | `"2H"` |
| **`event_type`** | `String` | `REQUIRED` | Action category code: <br>• Soccer: `'goal'`, `'foul'`, `'yellow_card'`, `'red_card'`, `'substitution'`<br>• Basketball: `'two_pointer'`, `'three_pointer'`, `'free_throw'`, `'foul'` | `"goal"` |
| **`actor_user_id`** | `Int32` | `OPTIONAL (Nullable)` | Foreign reference to player in relational `users` table. May be `null` for team or uncredited fouls. | `1024` |
| **`details`** | `String` | `OPTIONAL` | Free-form referee note or narrative description of the play. | `"Stoppage time header winner"` |

> [!IMPORTANT]
> **The Multi-Condition Array Rule (`$elemMatch`):**  
> Because `timeline_events` is an array of objects, filtering on multiple event fields (e.g., finding a `'red_card'` in minute `>= 45`) **requires** `$elemMatch`. Dot-notation without `$elemMatch` evaluates conditions independently across different elements in the array, resulting in false positives!

---

## 5. Embedded Subdocument: `venue`

Contains facility location data denormalized into the game log to accelerate stadium navigation and regional filtering.

| Field Name | BSON Type | Constraint | Description | Example Value |
| :--- | :--- | :--- | :--- | :--- |
| **`facility_id`** | `Int32` | `REQUIRED` | Foreign identifier referencing sports complexes in relational facility tables. | `12` |
| **`court_field`** | `String` | `REQUIRED` | Specific field, pitch, or hardwood court within the facility complex. | `"Field 3"` |
| **`city`** | `String` | `REQUIRED` | Municipality where the game is physically hosted. | `"Maple Grove"` |

---

## 6. Embedded Subdocument: `metadata`

Technical auditing attributes capturing system versioning and telemetry ingestion times.

| Field Name | BSON Type | Constraint | Description | Example Value |
| :--- | :--- | :--- | :--- | :--- |
| **`schema_version`** | `Int32` | `REQUIRED` | Document format revision number (currently `2`). Facilitates schema evolution. | `2` |
| **`ingest_timestamp`**| `ISODate` | `REQUIRED` | UTC timestamp when document was initialized in the NoSQL cluster. | `ISODate("2026-10-18T14:00:00Z")` |

---

## 7. Relational 3NF vs. NoSQL Document Architecture Comparison

| Architectural Dimension | Relational PostgreSQL (`sports_db`) | Document MongoDB (`sports_db_nosql`) |
| :--- | :--- | :--- |
| **Physical Storage Layout** | Normalized across 4+ tables (`games`, `teams`, `venues`, `game_events`). | Embedded into a single contiguous BSON document on disk per match. |
| **Read Characteristics** | Requires multiple relational `JOIN`s to assemble game scoreboard and events. | **Single Point Lookup:** Entire match state retrieved in sub-millisecond $O(1)$ read. |
| **Live In-Game Writes** | Requires multi-table transactions (`UPDATE games` + `INSERT INTO game_events`). | **Single-Document Atomicity:** Single `$set` and `$push` executes without multi-table locks. |
| **Schema Governance** | **Schema-on-Write:** Strict DDL, column types, and foreign keys enforced by database engine. | **Schema-on-Read:** High developer velocity; multi-sport formats (soccer vs basketball) coexist. |
| **Historical Aggregations** | Highly efficient for cross-season standings, playoff tiebreakers, and referee payroll. | Requires multi-stage Aggregation Pipelines (`$unwind`, `$group`), without relational foreign keys. |
