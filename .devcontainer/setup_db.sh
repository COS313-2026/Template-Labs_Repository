#!/bin/bash
echo "Waiting for isolated PostgreSQL instance to initialize..."
until pg_isready -h localhost -p 5432 -U admin; do
  sleep 1
done

echo "Seeding Master Registration Monolith Dump..."
psql -h localhost -p 5432 -U admin -d sports_db -f .devcontainer/seed_data/week01_monolith.sql
echo "Database environment compiled successfully! Sandbox ready for Lab 1 execution."
