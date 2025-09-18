#!/bin/bash

echo "🚀 Starting PHP-FPM (Fast Mode)..."

# Go to app directory
cd /var/www/app

# Start PHP-FPM immediately
echo "🎉 Starting PHP-FPM..."
exec php-fpm --nodaemonize
