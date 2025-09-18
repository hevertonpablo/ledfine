#!/bin/bash

# Deploy script for Ledfine Laravel application

echo "Starting deployment..."

# Clear Laravel caches
echo "Clearing application cache..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Cache configurations for production
echo "Caching configurations..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations if needed
echo "Running migrations..."
php artisan migrate --force

echo "Deployment completed!"
