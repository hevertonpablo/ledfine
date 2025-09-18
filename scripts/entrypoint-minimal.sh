#!/bin/bash
set -e

echo "🚀 Starting PHP-FPM Container..."
echo "📍 Working directory: $(pwd)"

# Go to app directory
cd /var/www/app || {
    echo "❌ Cannot change to /var/www/app"
    echo "📁 Available directories in /var/www:"
    ls -la /var/www/
    cd /var/www
}

echo "📍 Current directory: $(pwd)"
echo "📁 Directory contents:"
ls -la

# Always start PHP-FPM regardless of Laravel setup
echo "🎉 Starting PHP-FPM..."
exec php-fpm
