#!/bin/bash

echo "🔧 Redis Extension Build Fix Monitor"
echo "===================================="
echo ""

echo "❌ Previous Error: 'Cannot find autoconf' during Redis compilation"
echo ""
echo "✅ Applied Fixes:"
echo "  - Added autoconf, gcc, g++, make, linux-headers"
echo "  - Added php83-redis Alpine package"
echo "  - Improved PECL Redis installation with fallback"
echo "  - Enabled FORCE_FRESH_INSTALL=true for clean database"
echo ""

echo "⏱️  Monitoring build progress..."
echo "Expected build time: ~4-5 minutes"
echo ""

# Monitor for 5 minutes
for i in {1..10}; do
    echo "Check $i/10 - $(date)"
    
    # Test if the site responds
    response=$(curl -s -w "HTTP:%{http_code}|TIME:%{time_total}" "http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io" -o /dev/null 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        http_code=$(echo $response | cut -d'|' -f1 | cut -d':' -f2)
        time_total=$(echo $response | cut -d'|' -f2 | cut -d':' -f2)
        
        if [ "$http_code" = "200" ]; then
            echo "✅ SUCCESS! Application working - HTTP 200 in ${time_total}s"
            echo ""
            echo "🧪 Testing Redis functionality..."
            echo "Run these in Coolify terminal to verify:"
            echo ""
            echo "# Check Redis extension:"
            echo "docker exec -it \$(docker ps -q) php -m | grep redis"
            echo ""
            echo "# Test Redis connection:"
            echo "docker exec -it \$(docker ps -q) php -r \"echo (class_exists('Redis') ? 'Redis extension loaded' : 'Redis not found') . PHP_EOL;\""
            echo ""
            echo "# Test Laravel cache:"
            echo "docker exec -it \$(docker ps -q) php artisan tinker --execute=\"Cache::put('test', 'working'); echo 'Cache test: ' . Cache::get('test');\""
            echo ""
            echo "🎉 Your Bagisto store should be working now!"
            echo "🔗 Store: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io"
            echo "🔗 Admin: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io/admin"
            exit 0
        elif [ "$http_code" = "502" ]; then
            echo "⚠️  Still building - HTTP 502"
        else
            echo "⚠️  HTTP $http_code (${time_total}s)"
        fi
    else
        echo "⚠️  Connection failed - container likely still building"
    fi
    
    if [ $i -lt 10 ]; then
        echo "   Waiting 30 seconds..."
        sleep 30
    fi
done

echo ""
echo "📋 If build is still failing, check Coolify logs for:"
echo "1. ✅ No more 'Cannot find autoconf' errors"
echo "2. ✅ Redis extension compilation success"
echo "3. ✅ Fresh database migration completion"
echo ""
echo "🛠️  If issues persist, try these in Coolify terminal:"
echo "docker logs \$(docker ps -q) | grep -E '(redis|autoconf|migration)'"