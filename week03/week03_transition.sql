-- =================================================================
-- WEEK 3 TRANSITION SCRIPT
-- 
-- The Business Scenario: A third-party equipment vendor has sent us
-- their internal shipping logs as a new table.
-- We are loading this vendor data into our database so we can JOIN 
-- it against our legacy master_registration_dump table.
-- =================================================================

-- 1. Create the vendor table
DROP TABLE IF EXISTS vendor_gear_shipments;

CREATE TABLE vendor_gear_shipments (
    shipment_id SERIAL PRIMARY KEY,
    registration_id INT,
    shipped_item VARCHAR(100),
    shipped_quantity INT,
    shipment_date DATE
);

-- 2. Populate the vendor table from our monolith, BUT simulate a massive
-- shipping error by deliberately excluding all gear for players on the 'U10 Storm' team.
-- This creates our "orphaned" records!

INSERT INTO vendor_gear_shipments (registration_id, shipped_item, shipped_quantity, shipment_date)
SELECT 
    registration_id, 
    gear_item, 
    gear_quantity,
    CURRENT_DATE - (random() * 30)::int
FROM master_registration_dump
WHERE gear_item IS NOT NULL
  AND team_name != 'U10 Storm';
