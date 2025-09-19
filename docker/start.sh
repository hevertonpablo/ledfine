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

# Wait for database to be ready
echo "Waiting for database to be ready..."
timeout=60
while ! php /var/www/html/artisan db:show > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 2
    timeout=$((timeout - 2))
    if [ $timeout -le 0 ]; then
        echo "Database connection timeout!"
        break
    fi
done

# Run migrations and setup if database is available
if php /var/www/html/artisan db:show > /dev/null 2>&1; then
    echo "Database is ready, checking installation status..."
    
    # Check if this is a fresh install or forced fresh install
    if [ ! -f "/var/www/html/storage/installed" ] || [ "${FORCE_FRESH_INSTALL:-false}" = "true" ]; then
        if [ "${FORCE_FRESH_INSTALL:-false}" = "true" ]; then
            echo "FORCE_FRESH_INSTALL=true detected, performing fresh installation..."
            rm -f /var/www/html/storage/installed
        else
            echo "Fresh installation detected, setting up database..."
        fi
        
        # Try migrations first, if they fail due to conflicts, reset and retry
        echo "Running database migrations..."
        if ! php /var/www/html/artisan migrate --force 2>/dev/null; then
            echo "Migration conflicts detected, performing fresh migration..."
            php /var/www/html/artisan migrate:fresh --force --seed || {
                echo "Fresh migration failed, trying migrate:reset..."
                php /var/www/html/artisan migrate:reset --force || true
                php /var/www/html/artisan migrate --force || true
                php /var/www/html/artisan db:seed --force || true
            }
        else
            echo "Running database seeders..."
            php /var/www/html/artisan db:seed --force || true
        fi
        
        echo "Setting up Bagisto configuration..."
        php /var/www/html/artisan vendor:publish --tag=bagisto-config --force || true
        php /var/www/html/artisan optimize:clear || true
        
        echo "Bagisto setup completed successfully!"
    else
        echo "Installation marker found, skipping database setup"
    fi
    
    # Always mark installation as completed
    echo "Marking Bagisto as installed..."
    touch /var/www/html/storage/installed
    chown www-data:www-data /var/www/html/storage/installed
    chmod 644 /var/www/html/storage/installed
    
    # Debug: Verify the file
    echo "Installation marker created: $(ls -la /var/www/html/storage/installed)"
    
    echo "Database setup completed successfully!"
else
    echo "Database not available, skipping database setup"
fi

# Optimize application for production (after database is ready)
echo "Optimizing application for production..."
php /var/www/html/artisan config:clear || true
php /var/www/html/artisan cache:clear || true
php /var/www/html/artisan view:clear || true
php /var/www/html/artisan route:clear || true

echo "Caching configuration for production..."
php /var/www/html/artisan config:cache || true
php /var/www/html/artisan route:cache || true
php /var/www/html/artisan view:cache || true

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
