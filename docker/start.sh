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
    
    # Check if this is a forced fresh install
    if [ "${FORCE_FRESH_INSTALL:-false}" = "true" ]; then
        echo "FORCE_FRESH_INSTALL=true detected, performing fresh database installation..."
        rm -f /var/www/html/storage/installed
        echo "Running fresh migration with seed..."
        php /var/www/html/artisan migrate:fresh --force --seed || {
            echo "Fresh migration failed, trying alternative approach..."
            php /var/www/html/artisan migrate:reset --force || true
            php /var/www/html/artisan migrate --force || true
            php /var/www/html/artisan db:seed --force || true
        }
    else
        # Check if admins table exists and has data
        ADMIN_COUNT=$(php /var/www/html/artisan tinker --execute="try { echo \DB::table('admins')->count(); } catch(Exception \$e) { echo '0'; }" 2>/dev/null || echo "0")
        
        if [ "$ADMIN_COUNT" = "0" ]; then
            echo "No admins found, running database setup..."
            # Try regular migration first, if it fails due to conflicts, use fresh
            if ! php /var/www/html/artisan migrate --force 2>/dev/null; then
                echo "Migration conflicts detected, running fresh migration..."
                php /var/www/html/artisan migrate:fresh --force --seed || true
            else
                echo "Running database seeders..."
                php /var/www/html/artisan db:seed --force || true
            fi
        else
            echo "Database already configured with $ADMIN_COUNT admin(s)"
        fi
    fi
    
    # Always run configuration setup
    echo "Setting up Bagisto configuration..."
    php /var/www/html/artisan vendor:publish --tag=bagisto-config --force || true
    php /var/www/html/artisan optimize:clear || true
    
    echo "Bagisto setup completed successfully!"
    
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
