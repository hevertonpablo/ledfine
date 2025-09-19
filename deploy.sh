#!/bin/bash

# Deploy script for Coolify
set -e

echo "🚀 Starting Bagisto deployment..."

# Generate application key if not exists
if [ -z "$APP_KEY" ]; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force
fi

# Cache configurations
echo "⚙️ Caching configurations..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# Create storage link
echo "🔗 Creating storage link..."
php artisan storage:link

# Install Bagisto if not already installed
if ! php artisan bagisto:version 2>/dev/null; then
    echo "📦 Installing Bagisto..."
    php artisan bagisto:install --skip-env-check --force
else
    echo "✅ Bagisto already installed"
fi

# Clear and cache everything
echo "🧹 Clearing caches..."
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Deployment completed successfully!"
