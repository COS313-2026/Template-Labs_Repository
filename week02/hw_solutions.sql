-- ==========================================
-- STUDENT NAME: [First Last]
-- STUDENT ID: [ID Number]
-- ==========================================

/*
## Task 1: Price Extremes
**The Business Problem:** The equipment manager suspects we are being overcharged for cleats by some vendors and undercharged by others.
**The Task:** Find the maximum (`MAX`) and minimum (`MIN`) `fee_amount` paid specifically where the `gear_item` is exactly `'Cleats'`.
**Required Output Columns:** `max`, `min`
*/
-- Write your query below:


/*
## Task 2: Accounts Receivable
**The Business Problem:** The accounting department needs to see the total amount of money sitting in each payment status bucket (e.g., how much money is 'unpaid'?).
**The Task:** Calculate the total `SUM(fee_amount)` grouped by the `payment_status` column.
**Required Output Columns:** `payment_status`, `sum`
*/
-- Write your query below:


/*
## Task 3: Low-Volume Gear
**The Business Problem:** The logistics team wants to stop offering gear items that aren't selling well to save warehouse space.
**The Task:** Use `GROUP BY` and `HAVING` to find which `gear_item`s have a total sum of `gear_quantity` less than 18,900 across the entire league.
**Required Output Columns:** `gear_item`, `sum`
*/
-- Write your query below:
