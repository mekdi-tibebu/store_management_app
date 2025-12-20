#!/usr/bin/env bash
# Render build script for Django deployment

set -o errexit  # Exit on error

echo "🔧 Installing Python dependencies..."
pip install -r requirements.txt

echo "🗄️  Running database migrations..."
python manage.py migrate --noinput

echo "📦 Collecting static files..."
python manage.py collectstatic --noinput

echo "👤 Ensuring admin user exists..."
python manage.py ensure_admin

echo "✅ Build completed successfully!"
