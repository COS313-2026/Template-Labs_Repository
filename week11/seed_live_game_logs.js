// ==============================================================================
// COS313: Week 11 MongoDB Seed Script
// Database: sports_db_nosql
// Collection: live_game_logs
// ==============================================================================

db = db.getSiblingDB("sports_db_nosql");

// Drop previous collection if it exists to ensure idempotent re-runs
db.live_game_logs.drop();

print("Seeding sports_db_nosql.live_game_logs...");

const seedData = [
  {
    game_id: 4001,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 101,
    home_team_name: "Maple Grove United",
    away_team_id: 102,
    away_team_name: "Blaine Fire",
    current_score: { home: 3, away: 2 },
    timeline_events: [
      { elapsed_minute: 14, period: "1H", event_type: "goal", actor_user_id: 1012, details: "Opening strike from top of the box" },
      { elapsed_minute: 28, period: "1H", event_type: "foul", actor_user_id: 1055, details: "Tripping outside penalty area" },
      { elapsed_minute: 41, period: "1H", event_type: "goal", actor_user_id: 1033, details: "Header from corner kick" },
      { elapsed_minute: 55, period: "2H", event_type: "yellow_card", actor_user_id: 1055, details: "Persistent infringement" },
      { elapsed_minute: 70, period: "2H", event_type: "goal", actor_user_id: 1012, details: "Rebound off crossbar" },
      { elapsed_minute: 92, period: "2H", event_type: "goal", actor_user_id: 1024, details: "Stoppage time header winner" }
    ]
  },
  {
    game_id: 4002,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 103,
    home_team_name: "Centennial Strikers",
    away_team_id: 104,
    away_team_name: "Wayzata SC",
    current_score: { home: 4, away: 0 },
    timeline_events: [
      { elapsed_minute: 8, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Early breakaway finish" },
      { elapsed_minute: 33, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Penalty kick conversion" },
      { elapsed_minute: 60, period: "2H", event_type: "goal", actor_user_id: 1081, details: "Volley from 18 yards" },
      { elapsed_minute: 75, period: "2H", event_type: "goal", actor_user_id: 1070, details: "Hat-trick completion" }
    ]
  },
  {
    game_id: 4003,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 105,
    home_team_name: "Minnetonka Thunder",
    away_team_id: 106,
    away_team_name: "Plymouth Raptors",
    current_score: { home: 1, away: 2 },
    timeline_events: [
      { elapsed_minute: 22, period: "1H", event_type: "goal", actor_user_id: 1092, details: "Curling shot into top corner" },
      { elapsed_minute: 49, period: "2H", event_type: "goal", actor_user_id: 1104, details: "Counter-attack strike" },
      { elapsed_minute: 80, period: "2H", event_type: "goal", actor_user_id: 1095, details: "Late consolation goal" }
    ]
  },
  {
    game_id: 4004,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 101,
    home_team_name: "Maple Grove United",
    away_team_id: 105,
    away_team_name: "Minnetonka Thunder",
    current_score: { home: 2, away: 1 },
    timeline_events: [
      { elapsed_minute: 19, period: "1H", event_type: "foul", actor_user_id: 1015, details: "Slide tackle from behind" },
      { elapsed_minute: 37, period: "1H", event_type: "goal", actor_user_id: 1012, details: "Chip over advancing keeper" },
      { elapsed_minute: 58, period: "2H", event_type: "goal", actor_user_id: 1092, details: "Tap-in from cross" },
      { elapsed_minute: 72, period: "2H", event_type: "red_card", actor_user_id: 1015, details: "Violent conduct / serious foul play" },
      { elapsed_minute: 84, period: "2H", event_type: "goal", actor_user_id: 1019, details: "10-man game winner" }
    ]
  },
  {
    game_id: 4005,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 102,
    home_team_name: "Blaine Fire",
    away_team_id: 103,
    away_team_name: "Centennial Strikers",
    current_score: { home: 3, away: 3 },
    timeline_events: [
      { elapsed_minute: 11, period: "1H", event_type: "goal", actor_user_id: 1033, details: "Header off set piece" },
      { elapsed_minute: 29, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Low drive into left corner" },
      { elapsed_minute: 51, period: "2H", event_type: "goal", actor_user_id: 1035, details: "Deflected free kick" },
      { elapsed_minute: 68, period: "2H", event_type: "goal", actor_user_id: 1074, details: "Quick turn and volley" },
      { elapsed_minute: 82, period: "2H", event_type: "goal", actor_user_id: 1033, details: "Brace on corner kick" },
      { elapsed_minute: 89, period: "2H", event_type: "goal", actor_user_id: 1070, details: "Late equalizer" }
    ]
  },
  {
    game_id: 4006,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 104,
    home_team_name: "Wayzata SC",
    away_team_id: 106,
    away_team_name: "Plymouth Raptors",
    current_score: { home: 1, away: 1 },
    timeline_events: [
      { elapsed_minute: 34, period: "1H", event_type: "goal", actor_user_id: 1062, details: "Far post header" },
      { elapsed_minute: 65, period: "2H", event_type: "goal", actor_user_id: 1104, details: "Direct free kick" },
      { elapsed_minute: 91, period: "2H", event_type: "substitution", actor_user_id: 1065, details: "Tactical stoppage time sub" }
    ]
  },
  {
    // CRITICAL TRAP GAME: Red card at minute 18, Yellow card at minute 62!
    // Dot-notation matches (red_card exists, minute >= 45 exists independently).
    // $elemMatch correctly REJECTS because red_card was at minute 18!
    game_id: 4007,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 106,
    home_team_name: "Plymouth Raptors",
    away_team_id: 101,
    away_team_name: "Maple Grove United",
    current_score: { home: 0, away: 2 },
    timeline_events: [
      { elapsed_minute: 18, period: "1H", event_type: "red_card", actor_user_id: 1109, details: "Denial of obvious goal scoring opportunity" },
      { elapsed_minute: 25, period: "1H", event_type: "goal", actor_user_id: 1012, details: "Penalty kick" },
      { elapsed_minute: 62, period: "2H", event_type: "yellow_card", actor_user_id: 1014, details: "Dissent towards referee" },
      { elapsed_minute: 78, period: "2H", event_type: "goal", actor_user_id: 1018, details: "Counter-attack strike" }
    ]
  },
  {
    game_id: 4008,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 102,
    home_team_name: "Blaine Fire",
    away_team_id: 104,
    away_team_name: "Wayzata SC",
    current_score: { home: 2, away: 0 },
    timeline_events: [
      { elapsed_minute: 16, period: "1H", event_type: "goal", actor_user_id: 1033, details: "First time finish" },
      { elapsed_minute: 54, period: "2H", event_type: "goal", actor_user_id: 1037, details: "Header from deep cross" }
    ]
  },
  {
    game_id: 4009,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 103,
    home_team_name: "Centennial Strikers",
    away_team_id: 105,
    away_team_name: "Minnetonka Thunder",
    current_score: { home: 3, away: 0 },
    timeline_events: [
      { elapsed_minute: 20, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Left foot drive" },
      { elapsed_minute: 44, period: "1H", event_type: "goal", actor_user_id: 1074, details: "Pushed past keeper" },
      { elapsed_minute: 81, period: "2H", event_type: "goal", actor_user_id: 1078, details: "Sealing header" }
    ]
  },
  {
    game_id: 4010,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 104,
    home_team_name: "Wayzata SC",
    away_team_id: 101,
    away_team_name: "Maple Grove United",
    current_score: { home: 1, away: 3 },
    timeline_events: [
      { elapsed_minute: 12, period: "1H", event_type: "goal", actor_user_id: 1012, details: "Breakaway" },
      { elapsed_minute: 39, period: "1H", event_type: "goal", actor_user_id: 1062, details: "Equalizing free kick" },
      { elapsed_minute: 64, period: "2H", event_type: "goal", actor_user_id: 1014, details: "Long range effort" },
      { elapsed_minute: 87, period: "2H", event_type: "goal", actor_user_id: 1019, details: "Clincher" }
    ]
  },
  {
    game_id: 4011,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 105,
    home_team_name: "Minnetonka Thunder",
    away_team_id: 102,
    away_team_name: "Blaine Fire",
    current_score: { home: 0, away: 1 },
    timeline_events: [
      { elapsed_minute: 31, period: "1H", event_type: "goal", actor_user_id: 1033, details: "Header off corner" },
      { elapsed_minute: 85, period: "2H", event_type: "red_card", actor_user_id: 1098, details: "Spitting at opponent / violent conduct" }
    ]
  },
  {
    game_id: 4012,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 106,
    home_team_name: "Plymouth Raptors",
    away_team_id: 103,
    away_team_name: "Centennial Strikers",
    current_score: { home: 2, away: 2 },
    timeline_events: [
      { elapsed_minute: 15, period: "1H", event_type: "goal", actor_user_id: 1104, details: "Solo run" },
      { elapsed_minute: 40, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Tap-in" },
      { elapsed_minute: 67, period: "2H", event_type: "goal", actor_user_id: 1106, details: "Deflected strike" },
      { elapsed_minute: 79, period: "2H", event_type: "goal", actor_user_id: 1072, details: "Equalizer" }
    ]
  },
  {
    game_id: 4013,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 101,
    home_team_name: "Maple Grove United",
    away_team_id: 103,
    away_team_name: "Centennial Strikers",
    current_score: { home: 3, away: 1 },
    timeline_events: [
      { elapsed_minute: 17, period: "1H", event_type: "goal", actor_user_id: 1012, details: "One-timer inside box" },
      { elapsed_minute: 43, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Direct free kick" },
      { elapsed_minute: 61, period: "2H", event_type: "goal", actor_user_id: 1016, details: "Rebound strike" },
      { elapsed_minute: 83, period: "2H", event_type: "goal", actor_user_id: 1012, details: "Brace on breakaway" }
    ]
  },
  {
    game_id: 4014,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 102,
    home_team_name: "Blaine Fire",
    away_team_id: 106,
    away_team_name: "Plymouth Raptors",
    current_score: { home: 2, away: 2 },
    timeline_events: [
      { elapsed_minute: 27, period: "1H", event_type: "goal", actor_user_id: 1033, details: "Header" },
      { elapsed_minute: 53, period: "2H", event_type: "goal", actor_user_id: 1104, details: "Low drive" },
      { elapsed_minute: 71, period: "2H", event_type: "goal", actor_user_id: 1038, details: "Turnaround shot" },
      { elapsed_minute: 94, period: "2H", event_type: "goal", actor_user_id: 1088, details: "Equalizer off corner kick" }
    ]
  },
  {
    game_id: 4015,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 104,
    home_team_name: "Wayzata SC",
    away_team_id: 105,
    away_team_name: "Minnetonka Thunder",
    current_score: { home: 2, away: 0 },
    timeline_events: [
      { elapsed_minute: 23, period: "1H", event_type: "goal", actor_user_id: 1062, details: "Penalty" },
      { elapsed_minute: 69, period: "2H", event_type: "goal", actor_user_id: 1064, details: "Curler" }
    ]
  },
  {
    game_id: 4016,
    sport_type: "basketball",
    match_status: "completed",
    home_team_id: 201,
    home_team_name: "North Metro Ballers",
    away_team_id: 202,
    away_team_name: "Twin Cities Hoops",
    current_score: { home: 78, away: 71 },
    timeline_events: [
      { elapsed_minute: 10, period: "1Q", event_type: "point", actor_user_id: 2011, details: "3-point jumper" },
      { elapsed_minute: 24, period: "2Q", event_type: "foul", actor_user_id: 2022, details: "Personal foul on drive" },
      { elapsed_minute: 38, period: "4Q", event_type: "point", actor_user_id: 2014, details: "Fastbreak dunk" }
    ]
  },
  {
    game_id: 4017,
    sport_type: "basketball",
    match_status: "completed",
    home_team_id: 203,
    home_team_name: "Lakeville Lakers",
    away_team_id: 204,
    away_team_name: "Eden Prairie Wolves",
    current_score: { home: 65, away: 69 },
    timeline_events: [
      { elapsed_minute: 12, period: "1Q", event_type: "point", actor_user_id: 2035, details: "Midrange jump shot" },
      { elapsed_minute: 46, period: "4Q", event_type: "point", actor_user_id: 2042, details: "Clutch free throws" }
    ]
  },
  {
    game_id: 4018,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 103,
    home_team_name: "Centennial Strikers",
    away_team_id: 101,
    away_team_name: "Maple Grove United",
    current_score: { home: 1, away: 1 },
    timeline_events: [
      { elapsed_minute: 30, period: "1H", event_type: "goal", actor_user_id: 1070, details: "Header" },
      { elapsed_minute: 48, period: "2H", event_type: "red_card", actor_user_id: 1076, details: "Second yellow resulting in red" },
      { elapsed_minute: 74, period: "2H", event_type: "goal", actor_user_id: 1012, details: "Equalizing free kick" }
    ]
  },
  {
    game_id: 4019,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 105,
    home_team_name: "Minnetonka Thunder",
    away_team_id: 104,
    away_team_name: "Wayzata SC",
    current_score: { home: 1, away: 0 },
    timeline_events: [
      { elapsed_minute: 57, period: "2H", event_type: "goal", actor_user_id: 1092, details: "Solo strike" }
    ]
  },
  {
    // GAME 4055: The Scorekeeper Correction Lab Target!
    // Starts with away: 1, missing a late substitution at minute 88.
    game_id: 4055,
    sport_type: "soccer",
    match_status: "completed",
    home_team_id: 101,
    home_team_name: "Maple Grove United",
    away_team_id: 102,
    away_team_name: "Blaine Fire",
    current_score: { home: 3, away: 1 },
    timeline_events: [
      { elapsed_minute: 14, period: "1H", event_type: "goal", actor_user_id: 1012, details: "Strike from 20 yards" },
      { elapsed_minute: 36, period: "1H", event_type: "goal", actor_user_id: 1033, details: "Header" },
      { elapsed_minute: 59, period: "2H", event_type: "goal", actor_user_id: 1012, details: "Rebound off crossbar" },
      { elapsed_minute: 77, period: "2H", event_type: "goal", actor_user_id: 1019, details: "Chip shot" }
    ]
  }
];

db.live_game_logs.insertMany(seedData);

const count = db.live_game_logs.countDocuments();
print(`Successfully inserted ${count} documents into sports_db_nosql.live_game_logs.`);
