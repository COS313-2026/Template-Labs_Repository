#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing PostgreSQL client..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq postgresql-client

echo "Client installed successfully! You can now use 'psql' in the terminal."

echo "Configuring default psql connection settings..."
echo 'export PGHOST=localhost' >> ~/.bashrc
echo 'export PGPORT=5432' >> ~/.bashrc
echo 'export PGUSER=admin' >> ~/.bashrc
echo 'export PGPASSWORD=LeaguePassword2026' >> ~/.bashrc
echo 'export PGDATABASE=sports_db' >> ~/.bashrc
