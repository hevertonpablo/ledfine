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
    echo "Database is ready, checking migrations..."
    
    # Check if admins table exists and has data
    ADMIN_COUNT=$(php /var/www/html/artisan tinker --execute="try { echo \DB::table('admins')->count(); } catch(Exception \$e) { echo '0'; }" 2>/dev/null || echo "0")
    
    if [ "$ADMIN_COUNT" = "0" ]; then
        echo "Running database migrations..."
        php /var/www/html/artisan migrate --force || true
        
        echo "Running database seeders..."
        php /var/www/html/artisan db:seed --force || true
        
        echo "Setting up Bagisto configuration..."
        php /var/www/html/artisan vendor:publish --tag=bagisto-config --force || true
        php /var/www/html/artisan optimize:clear || true
        
        echo "Bagisto setup completed successfully!"
    else
        echo "Database already configured with $ADMIN_COUNT admin(s)"
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

# Clear caches safely (after database is ready)
echo "Clearing application caches..."
php /var/www/html/artisan config:clear || true
php /var/www/html/artisan cache:clear || true
php /var/www/html/artisan view:clear || true
php /var/www/html/artisan route:clear || true

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
