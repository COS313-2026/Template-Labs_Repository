#!/bin/bash
set -e

echo "Installing PostgreSQL database engine..."
sudo apt-get update
sudo apt-get install -y postgresql postgresql-client

echo "Starting local PostgreSQL engine..."
sudo service postgresql start

echo "Configuring secure user access..."
sudo -u postgres psql -c "CREATE USER admin WITH SUPERUSER PASSWORD 'LeaguePassword2026';" || true
sudo -u postgres psql -c "CREATE DATABASE sports_db OWNER admin;" || true

echo "Seeding Master Registration Monolith Dump..."
PGPASSWORD=LeaguePassword2026 psql -h localhost -U admin -d sports_db -f .devcontainer/seed_data/week1_monolith.sql

echo "Database sandbox environment compiled successfully!"


