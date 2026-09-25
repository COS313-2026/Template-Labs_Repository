CREATE TEMP TABLE group_a (name VARCHAR(50));
INSERT INTO group_a VALUES ('Alice'), ('Bob'), ('Charlie');
CREATE TEMP TABLE group_b (name VARCHAR(50));
INSERT INTO group_b VALUES ('Charlie'), ('David'), ('Eve');

-- all group a
SELECT * FROM group_a;

-- all group b
SELECT * FROM group_b;


-- UNION ALL (Notice 'Charlie' appears twice!)
SELECT name FROM group_a 
UNION ALL 
SELECT name FROM group_b;

