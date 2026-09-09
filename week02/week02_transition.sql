\echo '======================================================='
\echo 'Starting Week 2 Database Transition...'
\echo '======================================================='

\echo 'Wiping table to remove any test rows or duplicates...'
TRUNCATE TABLE master_registration_dump;

\echo 'Importing the full production dataset...'
\copy master_registration_dump FROM '.devcontainer/seed_data/master_registration_dump.csv' WITH (FORMAT csv, HEADER true);

\echo 'Verifying row count:'
SELECT COUNT(*) AS total_rows_loaded FROM master_registration_dump;

\echo '======================================================='
\echo 'Week 2 Transition Complete! You are ready for the lab.'
\echo '======================================================='
