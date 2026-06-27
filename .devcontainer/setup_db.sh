#!/bin/bash

echo "Installing minimal database client utility tools..."
sudo apt-get update && sudo apt-get install -y postgresql-client

echo "Waiting for isolated PostgreSQL instance to initialize..."
until pg_isready -h localhost -p 5432 -U admin; do
  sleep 1
done

# Check if data already exists before forcing a re-seed
TABLE_CHECK=$(psql -h localhost -p 5432 -U admin -d sports_db -t -c "SELECT to_regclass('master_registration_dump');" | tr -d '[:space:]')

if [ "$TABLE_CHECK" = "master_registration_dump" ]; then
  echo "Database structure already present. Skipping initialization."
else
  echo "Seeding Master Registration Monolith Dump..."
  psql -h localhost -p 5432 -U admin -d sports_db -f .devcontainer/seed_data/week01_monolith.sql
  echo "Database environment compiled successfully!"
fi

