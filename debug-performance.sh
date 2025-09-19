#!/bin/bash

echo "=== Bagisto Performance Debug Script ==="
echo "Run this script in your Coolify terminal to diagnose issues"
echo ""

# Get container ID
CONTAINER_ID=$(docker ps -q | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ No running containers found"
    exit 1
fi

echo "🐳 Container ID: $CONTAINER_ID"
echo ""

# 1. Check container status
echo "=== 1. Container Status ==="
docker ps
echo ""

# 2. Check services status
echo "=== 2. Services Status ==="
docker exec -it $CONTAINER_ID ps aux | grep -E "(nginx|php-fpm|supervisord)"
echo ""

# 3. Test Laravel performance
echo "=== 3. Laravel Performance Test ==="
echo "Testing basic Laravel command speed..."
start_time=$(date +%s)
docker exec -it $CONTAINER_ID sh -c 'cd /var/www/html && php artisan --version' 2>&1
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "⏱️  Laravel command took: ${duration} seconds"
echo ""

# 4. Check if caches are built
echo "=== 4. Production Cache Status ==="
docker exec -it $CONTAINER_ID sh -c 'ls -la /var/www/html/bootstrap/cache/' 2>&1
echo ""

# 5. Test Redis connectivity
echo "=== 5. Redis Connection Test ==="
docker exec -it $CONTAINER_ID sh -c 'cd /var/www/html && php artisan tinker --execute="Cache::put(\"test\", \"working\"); echo \"Redis test: \" . Cache::get(\"test\");"' 2>&1
echo ""

# 6. Check PHP-FPM configuration
echo "=== 6. PHP-FPM Status ==="
docker exec -it $CONTAINER_ID sh -c 'cat /etc/php83/php-fpm.d/www.conf | grep -E "(pm\.|request_terminate_timeout|slowlog)"'
echo ""

# 7. Check recent slowlog entries
echo "=== 7. PHP-FPM Slowlog (last 10 entries) ==="
docker exec -it $CONTAINER_ID sh -c 'tail -10 /var/log/php83/slow.log 2>/dev/null || echo "No slowlog entries found"'
echo ""

# 8. Check Nginx error log
echo "=== 8. Nginx Error Log (last 10 entries) ==="
docker exec -it $CONTAINER_ID sh -c 'tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No nginx errors found"'
echo ""

# 9. Check application logs
echo "=== 9. Laravel Log (last 5 entries) ==="
docker exec -it $CONTAINER_ID sh -c 'tail -5 /var/www/html/storage/logs/laravel.log 2>/dev/null || echo "No Laravel errors found"'
echo ""

# 10. Check memory usage
echo "=== 10. Memory Usage ==="
docker exec -it $CONTAINER_ID sh -c 'free -h'
echo ""

# 11. Test a simple HTTP request internally
echo "=== 11. Internal HTTP Test ==="
docker exec -it $CONTAINER_ID sh -c 'curl -s -w "Response Time: %{time_total}s\nHTTP Code: %{http_code}\n" http://localhost/ -o /dev/null'
echo ""

echo "=== Debug Complete ==="
echo ""
echo "💡 Analysis Tips:"
echo "- Laravel command should take < 5 seconds"
echo "- Cache files should exist in bootstrap/cache/"
echo "- Redis test should return 'Redis test: working'"
echo "- HTTP response should be < 10 seconds for 200 code"
echo "- Check slowlog for queries taking > 5 seconds"
echo ""
echo "🔧 If still slow, try:"
echo "1. Restart services: supervisorctl restart all"
echo "2. Clear and rebuild caches:"
echo "   php artisan config:clear && php artisan config:cache"
echo "   php artisan route:clear && php artisan route:cache"
echo "   php artisan view:clear && php artisan view:cache"