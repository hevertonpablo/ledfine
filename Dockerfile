FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxml2-dev \
    librabbitmq-dev \
    pkg-config \
    libssl-dev \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions required by Laravel/Bagisto
RUN docker-php-ext-configure intl \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    calendar \
    gd \
    intl \
    mbstring \
    pcntl \
    pdo_mysql \
    zip \
    opcache

# Install Composer
ENV COMPOSER_HOME=/tmp/composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Optimize PHP-FPM config a bit (optional sensible defaults)
RUN set -eux; \
  mkdir -p /usr/local/etc/php/conf.d; \
  echo 'memory_limit=512M'        >  /usr/local/etc/php/conf.d/custom.ini; \
  echo 'upload_max_filesize=64M'  >> /usr/local/etc/php/conf.d/custom.ini; \
  echo 'post_max_size=64M'        >> /usr/local/etc/php/conf.d/custom.ini; \
  echo 'max_execution_time=120'   >> /usr/local/etc/php/conf.d/custom.ini

# Ensure proper permissions for www-data
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data || true \
 && mkdir -p /tmp/composer \
 && chown -R www-data:www-data /var/www /tmp/composer

# Copy application files
COPY --chown=www-data:www-data . /var/www/

# Create a simple inline entrypoint that always works and auto-detects Laravel root
RUN echo '#!/bin/bash\n\
set -e\n\
ROOT=/var/www\n\
if [ -f "$ROOT/artisan" ]; then\n\
  cd "$ROOT"\n\
elif [ -f "$ROOT/app/artisan" ]; then\n\
  cd "$ROOT/app"\n\
else\n\
  # Fallback to /var/www if neither exists\n\
  cd "$ROOT"\n\
fi\n\
\n\
# Ensure composer dependencies exist when source is volume-mounted\n\
if [ -f composer.json ] && [ ! -f vendor/autoload.php ]; then\n\
  echo "📦 Composer autoload missing, installing…"\n\
  composer install --no-dev --optimize-autoloader --no-interaction || true\n\
fi\n\
\n\
echo "� Starting PHP-FPM..."\n\
exec php-fpm --nodaemonize' > /usr/local/bin/start-app.sh \
 && chmod +x /usr/local/bin/start-app.sh \
 && mkdir -p /var/www/app/storage/logs \
 && mkdir -p /var/www/app/storage/framework/{cache,sessions,views} \
 && mkdir -p /var/www/app/bootstrap/cache

USER www-data

# Install dependencies and setup application (set neutral working dir)
WORKDIR /var/www
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set proper permissions for Laravel directories
USER root
RUN chown -R www-data:www-data /var/www/app/storage /var/www/app/bootstrap/cache \
 && chmod -R 775 /var/www/app/storage /var/www/app/bootstrap/cache

USER www-data

# Use the inline entrypoint
CMD ["/usr/local/bin/start-app.sh"]
