#!/bin/bash

echo "=== DEBUG SCRIPT FOR BAGISTO CONTAINER ==="
echo "Execute this inside the container to check logs and configurations"
echo ""

echo "1. Check Laravel logs:"
echo "tail -50 /var/www/html/storage/logs/laravel.log"
echo ""

echo "2. Check PHP-FPM logs:"
echo "tail -50 /var/log/supervisor/php-fpm.log"
echo ""

echo "3. Check Nginx logs:"
echo "tail -50 /var/log/supervisor/nginx.log"
echo ""

echo "4. Check file permissions:"
echo "ls -la /var/www/html/storage/"
echo "ls -la /var/www/html/bootstrap/cache/"
echo ""

echo "5. Check environment file:"
echo "cat /var/www/html/.env | head -20"
echo ""

echo "6. Check if application key is set:"
echo "grep APP_KEY /var/www/html/.env"
echo ""

echo "7. Test database connection:"
echo "php /var/www/html/artisan migrate:status"
echo ""

echo "8. Check PHP configuration:"
echo "php -v"
echo "php -m | grep -E '(mysql|pdo|mbstring|openssl|tokenizer|xml|ctype|json|bcmath|ctype|fileinfo|gd|intl|zip)'"
echo ""
