#!/bin/sh

echo "Starting Bagisto application initialization..."

# Create cache directories if they don't exist
echo "Creating cache directories..."
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/bootstrap/cache

# Set proper permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Generate application key if not exists
if ! grep -q "APP_KEY=base64:" /var/www/html/.env; then
    echo "Generating application key..."
    php /var/www/html/artisan key:generate --force
fi

# Now clear caches safely
echo "Clearing application caches..."
php /var/www/html/artisan config:clear || true
php /var/www/html/artisan cache:clear || true
php /var/www/html/artisan view:clear || true
php /var/www/html/artisan route:clear || true

# Run migrations if needed
echo "Checking database connection..."
php /var/www/html/artisan migrate:status || true

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
