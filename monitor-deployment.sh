#!/bin/bash

echo "=== Bagisto Deployment Monitor ==="
echo "Waiting for Coolify deployment to complete..."
echo ""

# Function to check if the app is responding
check_app() {
    local url="$1"
    local start_time=$(date +%s)
    
    echo "Testing application response at: $url"
    
    # Test with curl and measure response time
    response=$(curl -s -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\nTIME_CONNECT:%{time_connect}\n" "$url" -o /dev/null)
    
    if [ $? -eq 0 ]; then
        echo "Response details:"
        echo "$response"
        echo ""
        
        http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
        time_total=$(echo "$response" | grep "TIME_TOTAL:" | cut -d: -f2)
        
        if [ "$http_code" = "200" ]; then
            echo "✅ Application is responding successfully!"
            echo "⏱️  Response time: ${time_total}s"
            return 0
        elif [ "$http_code" = "502" ]; then
            echo "❌ 502 Bad Gateway - Application still having issues"
            return 1
        else
            echo "⚠️  HTTP $http_code - Unexpected response"
            return 1
        fi
    else
        echo "❌ Connection failed"
        return 1
    fi
}

# Function to show helpful debugging commands
show_debug_info() {
    echo ""
    echo "=== Debugging Commands (run in Coolify terminal) ==="
    echo "1. Check container status:"
    echo "   docker ps"
    echo ""
    echo "2. Check PHP-FPM logs:"
    echo "   docker logs \$(docker ps --format 'table {{.Names}}' | grep -v NAMES | head -1) | tail -50"
    echo ""
    echo "3. Check application performance:"
    echo "   docker exec -it \$(docker ps -q) sh -c 'cd /var/www/html && time php artisan --version'"
    echo ""
    echo "4. Check if caching is working:"
    echo "   docker exec -it \$(docker ps -q) sh -c 'ls -la /var/www/html/bootstrap/cache/'"
    echo ""
    echo "5. Check PHP-FPM slowlog:"
    echo "   docker exec -it \$(docker ps -q) tail -20 /var/log/php83/slow.log"
    echo ""
    echo "6. Test Redis connection:"
    echo "   docker exec -it \$(docker ps -q) sh -c 'php /var/www/html/artisan tinker --execute=\"Cache::put(\\\"test\\\", \\\"working\\\"); echo Cache::get(\\\"test\\\");\"'"
}

# Wait a bit for deployment to start
echo "Waiting 30 seconds for deployment to begin..."
sleep 30

# Try to check the application multiple times
APP_URL="http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io"
max_attempts=10
attempt=1

echo "Starting health checks..."
echo ""

while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt/$max_attempts ($(date))"
    
    if check_app "$APP_URL"; then
        echo ""
        echo "🎉 Deployment successful! Application is running properly."
        echo "🔗 Access your Bagisto store at: $APP_URL"
        echo "🔗 Access admin panel at: $APP_URL/admin"
        exit 0
    fi
    
    echo "Waiting 60 seconds before next check..."
    sleep 60
    ((attempt++))
done

echo ""
echo "❌ Application is still not responding properly after $max_attempts attempts."
echo "This suggests the performance optimizations may need more time or additional tuning."

show_debug_info

echo ""
echo "💡 Recommended next steps:"
echo "1. Use the debugging commands above in Coolify terminal"
echo "2. Check if the new caching optimizations are working"
echo "3. Monitor PHP-FPM slowlog for remaining bottlenecks"
echo "4. Consider increasing PHP memory_limit if needed"