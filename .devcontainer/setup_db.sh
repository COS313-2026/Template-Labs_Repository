#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing PostgreSQL client..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq postgresql-client

echo "Installing MongoDB Shell (mongosh)..."
curl -sLo /tmp/mongodb-mongosh.deb https://downloads.mongodb.com/compass/mongodb-mongosh_2.3.8_amd64.deb
sudo dpkg -i /tmp/mongodb-mongosh.deb
rm -f /tmp/mongodb-mongosh.deb

echo "Client tools installed successfully! You can now use 'psql' and 'mongosh' in the terminal."

echo "Configuring default psql connection settings..."
echo 'export PGHOST=localhost' >> ~/.bashrc
echo 'export PGPORT=5432' >> ~/.bashrc
echo 'export PGUSER=admin' >> ~/.bashrc
echo 'export PGPASSWORD=LeaguePassword2026' >> ~/.bashrc
echo 'export PGDATABASE=sports_db' >> ~/.bashrc
