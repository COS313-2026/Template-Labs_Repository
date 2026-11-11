# COS313: Document Databases & MongoDB Reference Sheet

This syntax and architecture reference serves as the standard guide for **Week 11 (Lab & Homework)**. It provides MongoDB grammar, `mongosh` operational commands, query and update operators, array manipulation rules, and the Week 11 NoSQL Data Dictionary without disclosing assignment solutions.

---

## 1. Week 11 Schema & Data Dictionary (`sports_db_nosql.live_game_logs`)

All Week 11 lab tickets and homework tasks operate against the `live_game_logs` collection within the `sports_db_nosql` database.

### Collection Schema Overview
Each document in `live_game_logs` represents a single sports match (soccer or basketball) undergoing live tracking or completed play:

```json
{
  "_id": ObjectId("..."),
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
      "actor_user_id": 1024,
      "details": "Left-footed volley from outside penalty box"
    },
    {
      "elapsed_minute": 38,
      "period": "1H",
      "event_type": "yellow_card",
      "actor_user_id": 1088,
      "details": "Tactical foul breaking counter-attack"
    }
  ],
  "venue": {
    "facility_id": 12,
    "court_field": "Field 3",
    "city": "Maple Grove"
  },
  "metadata": {
    "schema_version": 2,
    "ingest_timestamp": ISODate("2026-10-18T14:00:00Z")
  }
}
```

### Data Dictionary

| Field Name | BSON / JSON Type | Description & Domain Rules |
| :--- | :--- | :--- |
| `_id` | `ObjectId` | MongoDB unique document identifier (automatically generated). |
| `game_id` | `Int32` | Unique game identifier matching league scheduling systems. |
| `sport_type` | `String` | Type of sport: `"soccer"` or `"basketball"`. |
| `match_status` | `String` | Lifecycle state: `"scheduled"`, `"in_progress"`, or `"completed"`. |
| `home_team_id` | `Int32` | Foreign identifier referencing the home team. |
| `home_team_name`| `String` | Human-readable name of the home team. |
| `away_team_id` | `Int32` | Foreign identifier referencing the away team. |
| `away_team_name`| `String` | Human-readable name of the away team. |
| `current_score` | `Embedded Document` | Real-time score object: `{ home: Int32, away: Int32 }`. |
| `timeline_events`| `Array of Documents`| Chronological log of in-game actions: `[{ elapsed_minute, period, event_type, actor_user_id, details }]`. |
| `venue` | `Embedded Document` | Facility location: `{ facility_id, court_field, city }`. |
| `metadata` | `Embedded Document` | Technical auditing data: `{ schema_version, ingest_timestamp }`. |

---

## 2. Connecting & Navigating `mongosh`

MongoDB uses the JavaScript-based interactive shell `mongosh`.

### Terminal Commands (Codespaces Environment)
```bash
# Connect to MongoDB in your Codespaces terminal (interactive shell)
mongosh

# Or connect directly to the course database:
mongosh sports_db_nosql

# Run a non-interactive script file directly into mongosh:
mongosh sports_db_nosql < script.js

# Or execute a JavaScript file using mongosh:
mongosh sports_db_nosql --file script.js
```

### Shell Navigation Commands
```javascript
// Display available databases
show dbs

// Switch to the target database
use sports_db_nosql

// Or programmatically select the database in JavaScript scripts:
db = db.getSiblingDB("sports_db_nosql");

// Display collections in the current database
show collections

// Count documents in a collection
db.live_game_logs.countDocuments();
```

---

## 3. Querying & Filtering Grammar (`db.collection.find()`)

### Basic Syntax
```javascript
db.collection.find( <filterCriteria>, <projection> )
```

### Comparison Query Operators

| Operator | Meaning | Example |
| :--- | :--- | :--- |
| `$eq` | Equal to (implicit when omitting operator) | `{ sport_type: "soccer" }` |
| `$ne` | Not equal to | `{ match_status: { $ne: "cancelled" } }` |
| `$gt` / `$gte` | Greater than / Greater than or equal to | `{ "current_score.home": { $gte: 3 } }` |
| `$lt` / `$lte` | Less than / Less than or equal to | `{ "current_score.away": { $lte: 1 } }` |
| `$in` | Matches any value in a specified array | `{ sport_type: { $in: ["soccer", "basketball"] } }` |
| `$nin` | Does not match any value in a specified array | `{ sport_type: { $nin: ["baseball", "hockey"] } }` |
| `$exists` | Checks whether a field exists in the document | `{ "timeline_events.actor_user_id": { $exists: true } }` |

### Dot Notation for Embedded Documents
To filter on properties nested inside an embedded subdocument, use dot notation.
> [!IMPORTANT]
> **Quotation Rule:** Any property path containing a dot **MUST** be enclosed in quotation marks:
> * Correct: `db.live_game_logs.find({ "current_score.home": { $gte: 3 } })`
> * Syntax Error: `db.live_game_logs.find({ current_score.home: { $gte: 3 } })`

### Field Projections
Projections control which fields are returned from matching documents.
- `1` includes a field.
- `0` excludes a field.
- **The `_id` Suppression Rule:** MongoDB includes `_id` by default in all query results. To omit `_id`, you must explicitly pass `_id: 0`.

```javascript
// Return only game_id, sport_type, and current_score (suppressing _id)
db.live_game_logs.find(
  { match_status: "completed" },
  { game_id: 1, sport_type: 1, current_score: 1, _id: 0 }
);
```

---

## 4. Querying Arrays & The `$elemMatch` Operator

Querying documents with array fields requires understanding how MongoDB evaluates array criteria.

### The Independent Dot-Notation Trap (Multi-Condition Arrays)
When querying an array of documents using dot notation without `$elemMatch`, MongoDB matches if **ANY** element satisfies condition 1 AND **ANY** element satisfies condition 2, even if they belong to completely different elements!

```javascript
// BEWARE: THE TRAP!
// Matches documents where ANY event is a red_card AND ANY event occurred at >= 45.
// A game with a red card in minute 18 and a substitution in minute 62 WILL MATCH!
db.live_game_logs.find({
  "timeline_events.event_type": "red_card",
  "timeline_events.elapsed_minute": { $gte: 45 }
});
```

### The Correct Isolated Query (`$elemMatch`)
Use `$elemMatch` when you require multiple criteria to be satisfied by the **exact same single element** in the array:

```javascript
// CORRECT: Both conditions must hold on the SAME timeline event
db.live_game_logs.find({
  timeline_events: {
    $elemMatch: {
      event_type: "red_card",
      elapsed_minute: { $gte: 45 }
    }
  }
});
```

---

## 5. Cursor Modifiers (`sort` & `limit`)

Cursors returned by `.find()` can be chained with modifiers:

```javascript
// Sort by home score descending (-1), then limit to top 5 results
db.live_game_logs.find(
  { match_status: "completed" },
  { game_id: 1, "current_score.home": 1, _id: 0 }
)
.sort({ "current_score.home": -1 })
.limit(5);
```
- `1` = Ascending order (lowest to highest, A to Z).
- `-1` = Descending order (highest to lowest, Z to A).

---

## 6. Document Mutation Operators (`updateOne`, `$set`, `$push`)

MongoDB modifies existing documents in place using atomic update operators.

### Updating Fields with `$set`
`$set` replaces or adds specific field values without modifying other fields in the document:

```javascript
db.live_game_logs.updateOne(
  { game_id: 4055 },
  { $set: { "current_score.away": 2 } }
);
```

### Appending to Arrays with `$push`
`$push` appends a new element to the end of an existing array field:

```javascript
db.live_game_logs.updateOne(
  { game_id: 4055 },
  {
    $push: {
      timeline_events: {
        elapsed_minute: 88,
        period: "2H",
        event_type: "substitution",
        actor_user_id: 1042,
        details: "Late tactical substitution: J. Hanson for D. Miller"
      }
    }
  }
);
```

### Combining Operators in a Single Atomic Update
You can combine `$set` and `$push` within the same update command:

```javascript
db.live_game_logs.updateOne(
  { game_id: 4055 },
  {
    $set: { "current_score.away": 2 },
    $push: {
      timeline_events: {
        elapsed_minute: 88,
        period: "2H",
        event_type: "substitution",
        actor_user_id: 1042,
        details: "Late tactical substitution: J. Hanson for D. Miller"
      }
    }
  }
);
```

> [!WARNING]
> **Avoid Blind Updates without Operators:** Passing a plain document `{ current_score: { away: 2 } }` without `$set` in replacement methods will overwrite the entire document, erasing all other fields (`sport_type`, `timeline_events`, `venue`, etc.)! Always use atomic operators (`$set`, `$push`, `$inc`) when performing partial document mutations.
