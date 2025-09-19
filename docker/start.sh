#!/bin/sh

echo "Starting Bagisto application initialization..."

# Set proper permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Generate application key if not exists
if ! grep -q "APP_KEY=base64:" /var/www/html/.env; then
    echo "Generating application key..."
    php /var/www/html/artisan key:generate --force
fi

# Clear caches
echo "Clearing application caches..."
php /var/www/html/artisan config:clear
php /var/www/html/artisan cache:clear
php /var/www/html/artisan view:clear
php /var/www/html/artisan route:clear

# Run migrations if needed
echo "Checking database connection..."
php /var/www/html/artisan migrate:status || true

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
