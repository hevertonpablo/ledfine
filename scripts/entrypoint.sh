#!/bin/bash

# Entrypoint script for Laravel application in Docker
set -e

echo "🚀 Starting Laravel Application..."

# Change to application directory
cd /var/www/app

# Function to wait for database
wait_for_db() {
    echo "⏳ Waiting for database connection..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if php artisan migrate:status >/dev/null 2>&1; then
            echo "✅ Database connection established!"
            return 0
        fi
        echo "🔄 Attempt $attempt/$max_attempts - Database not ready, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ Failed to connect to database after $max_attempts attempts"
    exit 1
}

# Function to setup Laravel application
setup_laravel() {
    echo "🔧 Setting up Laravel application..."
    
    # Clear all caches
    echo "🧹 Clearing caches..."
    php artisan config:clear || true
    php artisan cache:clear || true
    php artisan route:clear || true
    php artisan view:clear || true
    
    # Generate application key if not exists
    if [ -z "$APP_KEY" ]; then
        echo "🔑 Generating application key..."
        php artisan key:generate --force
    fi
    
    # Create storage link if it doesn't exist
    if [ ! -L "/var/www/app/public/storage" ]; then
        echo "🔗 Creating storage symlink..."
        php artisan storage:link || true
    fi
    
    # Run migrations
    echo "🗃️ Running database migrations..."
    php artisan migrate --force
    
    # Cache configurations for production
    if [ "$APP_ENV" = "production" ]; then
        echo "📦 Caching configurations for production..."
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
    fi
    
    echo "✅ Laravel application setup completed!"
}

# Main execution
echo "🏃 Starting application initialization..."

# Wait for database
wait_for_db

# Setup Laravel
setup_laravel

echo "🎉 Application ready! Starting PHP-FPM..."

# Start PHP-FPM
exec php-fpm
