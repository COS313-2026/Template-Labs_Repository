CREATE TEMP TABLE items (item_name VARCHAR(50), price INT);
INSERT INTO items VALUES ('Ball', 15), ('Bat', 45), ('Glove', 30);

-- all items
SELECT * FROM items;

-- Find items with price > average (scalar)
SELECT item_name 
FROM items 
WHERE price > (
	SELECT AVG(price) FROM items
);