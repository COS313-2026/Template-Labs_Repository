-- ==========================================
-- STUDENT NAME: [First Last]
-- STUDENT ID: [ID Number]
-- ==========================================

/*
## Ticket 1: The Revenue Audit
**The Business Problem:** The Chief Financial Officer wants to know exactly how much gross revenue the league has collected across all 50,000 registrations.
**The Task:** Calculate the absolute total sum (`SUM`) of the `fee_amount` column.
**Required Output Columns:** `sum` (of fee_amount)
*/
-- Write your query below:


/*
## Ticket 2: Team Roster Counts
**The Business Problem:** The league commissioner needs a headcount of how many players are assigned to each unique team.
**The Task:** Generate a list of every `team_name` and the `COUNT(*)` of users whose `assigned_role` is `'player'`. Order the results from largest team to smallest team (`DESC`).
**Required Output Columns:** `team_name`, `count`
*/
-- Write your query below:


/*
## Ticket 3: Financials by Age
**The Business Problem:** The marketing team wants to know if parents pay more on average for older children compared to younger children.
**The Task:** Calculate the average (`AVG`) `fee_amount` paid, grouped by the `age_group` column. Sort the output alphabetically by `age_group`.
**Required Output Columns:** `age_group`, `avg`
*/
-- Write your query below:


/*
## Ticket 4: Overcrowded Teams
**The Business Problem:** The safety committee mandates that no team can have more than 2,000 players assigned to it in this monolith database.
**The Task:** Write a query using `GROUP BY` and the `HAVING` clause to find only those teams where the `COUNT(*)` of players is strictly greater than 2000.
**Required Output Columns:** `team_name`, `count`
*/
-- Write your query below:
