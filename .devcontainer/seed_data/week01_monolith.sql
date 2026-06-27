-- C0S313 WEEK 1 MASTER UNNORMALIZED SPORTS MONOLITH
CREATE TABLE IF NOT EXISTS master_registration_dump (
    registration_id INT,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    birthdate DATE,
    parent_email VARCHAR(255),
    assigned_role VARCHAR(50),
    team_name VARCHAR(100),
    age_group VARCHAR(20),
    fee_amount NUMERIC(10,2),
    payment_status VARCHAR(50),
    gear_item VARCHAR(100),
    gear_size VARCHAR(20),
    gear_quantity INT,
    registered_at TIMESTAMP
);

-- RECONCILIATION DATA FLIGHT CHECK SEED DATA
INSERT INTO master_registration_dump VALUES 
(5001, 'coach.dan@gmail.com', 'Daniel', 'Oakley', '555-0199', '1985-05-12', NULL, 'coach', 'U10 Storm', 'U10', 150.00, 'paid', 'Jersey', 'M', 1, '2026-06-01 10:00:00'),
(5002, 'kid1.dan@gmail.com', 'Timmy', 'Oakley', '555-0199', '2017-08-14', 'coach.dan@gmail.com', 'player', 'U10 Storm', 'U10', 150.00, 'paid', 'Jersey', 'YM', 1, '2026-06-01 10:15:00'),
(5003, 'kid2.dan@gmail.com', 'Sarah', 'Oakley', '555-0199', '2015-03-22', 'coach.dan@gmail.com', 'player', 'U12 Lightning', 'U12', 150.00, 'paid', 'Jersey', 'YL', 1, '2026-06-01 10:20:00'),
(5004, 'rogue.player@yahoo.com', 'Alex', 'Vance', '555-4321', '2014-11-05', NULL, 'player', 'U10 Storm', 'U10', 150.00, 'unpaid', 'Jersey', 'YM', 1, '2026-06-02 09:00:00'),
(5005, 'typo.user@hotmail.com', 'Marcus', 'Brodie', '555-9876', '1988-01-15', NULL, 'coachh', 'U14 Cobras', 'U14', 0.00, 'unpaid', 'Jersey', 'XL', 1, '2026-06-02 11:30:00'),
(5006, 'wholesale.parent@corp.io', 'Grace', 'Hopper', '555-1122', '2018-09-30', 'parent.hopper@corp.io', 'player', 'U10 Storm', 'U10', 75.00, 'paid', 'Jersey', 'YS', 3, '2026-06-03 14:00:00');
