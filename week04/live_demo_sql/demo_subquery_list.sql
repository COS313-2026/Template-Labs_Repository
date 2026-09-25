CREATE TEMP TABLE active_teams (team_id INT);
INSERT INTO active_teams VALUES (1), (2);
CREATE TEMP TABLE users_demo (name VARCHAR(50), team_id INT);
INSERT INTO users_demo VALUES ('Alice', 1), ('Bob', 2), ('Charlie', 99);

-- all active teams
SELECT * FROM active_teams;

-- all users
SELECT * FROM users_demo;

-- Find active users (IN/NOT IN from list)
SELECT name 
FROM users_demo 
WHERE team_id IN (
	SELECT team_id FROM active_teams
);

