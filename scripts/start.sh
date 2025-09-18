#!/bin/bash

# Application initialization script

echo "Initializing Ledfine application..."

# Wait for database to be ready
echo "Waiting for database connection..."
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 2
done

echo "Database is ready!"

# Run the deploy script
if [ -f "/var/www/scripts/deploy.sh" ]; then
    echo "Running deploy script..."
    cd /var/www/app
    bash /var/www/scripts/deploy.sh
fi

echo "Application initialized successfully!"

# Start PHP-FPM
exec php-fpm
