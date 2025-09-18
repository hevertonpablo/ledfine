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

# Make entrypoint executable and create directories
RUN chmod +x /var/www/scripts/entrypoint-simple.sh \
 && chmod +x /var/www/scripts/entrypoint-minimal.sh \
 && chmod +x /var/www/scripts/entrypoint-fast.sh \
 && mkdir -p /var/www/app/storage/logs \
 && mkdir -p /var/www/app/storage/framework/{cache,sessions,views} \
 && mkdir -p /var/www/app/bootstrap/cache

USER www-data

# Install dependencies and setup application
WORKDIR /var/www/app
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set proper permissions for Laravel directories
USER root
RUN chown -R www-data:www-data /var/www/app/storage /var/www/app/bootstrap/cache \
 && chmod -R 775 /var/www/app/storage /var/www/app/bootstrap/cache

USER www-data

# Default command - use the fast entrypoint
CMD ["bash", "/var/www/scripts/entrypoint-fast.sh"]
