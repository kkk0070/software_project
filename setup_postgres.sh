#!/bin/bash

# EcoRide PostgreSQL Setup Script (macOS)

echo "🐘 Starting PostgreSQL Setup..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check/Install PostgreSQL via Homebrew
if command_exists psql; then
    echo "✅ PostgreSQL is already installed."
else
    echo "📦 PostgreSQL not found. Installing via Homebrew..."
    if command_exists brew; then
        brew install postgresql
    else
        echo "❌ Homebrew is not installed! Please install Homebrew first: https://brew.sh/"
        exit 1
    fi
fi

# 2. Start PostgreSQL Service
echo "🔄 Checking PostgreSQL service status..."
if brew services list | grep -q "postgresql"; then
    echo "✅ PostgreSQL service is registered."
    brew services start postgresql
else
    echo "🚀 Starting PostgreSQL service..."
    brew services start postgresql
    # Give it a moment to start
    sleep 5
fi

# 3. Create User and Database
# Read .env variables if available
DB_USER="postgres"
DB_PASS="postgres" # Default locally often doesn't require password or is peer auth
DB_NAME="ecoride_db"

if [ -f backend/.env ]; then
    # Simple grep to extract values (not robust but sufficient for simple .env)
    DB_USER=$(grep DB_USER backend/.env | cut -d '=' -f2)
    DB_PASS=$(grep DB_PASSWORD backend/.env | cut -d '=' -f2)
    DB_NAME=$(grep DB_NAME backend/.env | cut -d '=' -f2)
fi

echo "👤 Creating Database User: $DB_USER"
# Check if user exists, if not create
if psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
    echo "✅ User '$DB_USER' already exists."
else
    echo "🆕 Creating user '$DB_USER'..."
    createuser -s "$DB_USER"
fi

# Set password (optional, often local dev uses trust auth, but good to have)
if [ -n "$DB_PASS" ]; then
    echo "🔐 Setting password for '$DB_USER'..."
    psql postgres -c "ALTER USER \"$DB_USER\" WITH PASSWORD '$DB_PASS';"
fi

echo "🗄️ Creating Database: $DB_NAME"
# Check if db exists, if not create
if psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "✅ Database '$DB_NAME' already exists."
else
    echo "🆕 Creating database '$DB_NAME'..."
    createdb -O "$DB_USER" "$DB_NAME"
fi

echo ""
echo "✅ PostgreSQL Setup Complete!"
echo "   Connection String: postgres://$DB_USER:*****@localhost:5432/$DB_NAME"
echo ""
