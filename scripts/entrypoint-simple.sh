#!/bin/bash
set -e

echo "🚀 Starting Laravel Application..."
echo "📍 Current directory: $(pwd)"
echo "📁 Contents: $(ls -la)"

# Change to app directory and verify
cd /var/www/app
echo "📍 Changed to: $(pwd)"

# Check if artisan exists
if [ ! -f "artisan" ]; then
  echo "❌ Artisan file not found!"
  echo "📁 App directory contents:"
  ls -la
  echo "⚠️  Starting PHP-FPM without Laravel setup..."
  exec php-fpm
fi

echo "✅ Artisan found!"

# Try database connection (but don't fail)
echo "⏳ Testing database connection..."
DB_READY=false
for i in {1..15}; do
  if php artisan migrate:status >/dev/null 2>&1; then
    echo "✅ Database ready!"
    DB_READY=true
    break
  fi
  echo "🔄 Attempt $i/15 - Database not ready, waiting..."
  sleep 2
done

# Setup Laravel (don't fail on errors)
echo "🔧 Setting up Laravel..."
php artisan config:clear 2>/dev/null || echo "⚠️  Config clear failed"
php artisan cache:clear 2>/dev/null || echo "⚠️  Cache clear failed"
php artisan route:clear 2>/dev/null || echo "⚠️  Route clear failed"
php artisan view:clear 2>/dev/null || echo "⚠️  View clear failed"

# Run migrations only if database is ready
if [ "$DB_READY" = "true" ]; then
  echo "🗃️  Running migrations..."
  php artisan migrate --force 2>/dev/null || echo "⚠️  Migrations failed"
  
  # Create storage link
  if [ ! -L "public/storage" ]; then
    php artisan storage:link 2>/dev/null || echo "⚠️  Storage link failed"
  fi
else
  echo "⚠️  Database not ready, skipping migrations"
fi

echo "🎉 Starting PHP-FPM..."
exec php-fpm
