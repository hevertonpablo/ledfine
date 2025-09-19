# Build stage
FROM php:8.3-fpm-alpine AS builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    icu-dev \
    mysql-client \
    nodejs \
    npm \
    libzip-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    calendar \
    zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application code first (needed for Bagisto packages)
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts \
    && composer dump-autoload --optimize

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Install npm dependencies and build assets
RUN npm install \
    && npm run build \
    && rm -rf node_modules

# Production stage
FROM nginx:alpine AS production

# Install PHP and necessary extensions
RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-pdo_mysql \
    php83-mbstring \
    php83-exif \
    php83-pcntl \
    php83-bcmath \
    php83-gd \
    php83-intl \
    php83-calendar \
    php83-session \
    php83-tokenizer \
    php83-xml \
    php83-ctype \
    php83-json \
    php83-curl \
    php83-zip \
    php83-openssl \
    php83-dom \
    php83-xmlreader \
    php83-xmlwriter \
    php83-simplexml \
    php83-fileinfo \
    php83-iconv \
    supervisor \
    && adduser -u 82 -D -S -G www-data www-data 2>/dev/null || true

# Copy PHP configuration
COPY docker/php/php.ini /etc/php83/php.ini
COPY docker/php/www.conf /etc/php83/php-fpm.d/www.conf

# Copy Nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy Supervisor configuration
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy startup script
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Copy application from builder stage
COPY --from=builder --chown=www-data:www-data /var/www/html /var/www/html

# Create necessary directories
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/log/supervisor \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port
EXPOSE 80

# Start with initialization script
CMD ["/usr/local/bin/start.sh"]
