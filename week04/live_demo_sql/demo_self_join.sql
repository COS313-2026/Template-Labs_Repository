CREATE TEMP TABLE employees (emp_id INT, name VARCHAR(50), manager_id INT);
INSERT INTO employees VALUES (1, 'Alice (CEO)', NULL), (2, 'Bob', 1), (3, 'Charlie', 1);

-- all employees
SELECT * FROM employees;

-- Find employees and the name of their manager
SELECT e.name AS employee, m.name AS manager
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id;
