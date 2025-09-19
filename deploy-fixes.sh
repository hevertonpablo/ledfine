#!/bin/bash

echo "🔍 Bagisto Commit Analysis & Fix Deployment"
echo "============================================"
echo ""

echo "📋 Commit History Analysis:"
echo "✅ bc05460 - Working but no images"
echo "❌ 028def5 - Current with 500 errors"
echo ""

echo "🛠️  Issues Found in Logs:"
echo "1. ❌ Class 'Redis' not found"
echo "2. ❌ Duplicate foreign key constraint 'sample_translations_sample_id_foreign'"
echo "3. ❌ Unknown column 'code' in attribute_groups table"
echo ""

echo "🔧 Fixes Applied:"
echo "✅ Added Redis PHP extension via PECL"
echo "✅ Improved migration conflict handling"
echo "✅ Added FORCE_FRESH_INSTALL option"
echo "✅ Better error recovery in database setup"
echo ""

echo "🚀 Deploying fixes now..."

# Deploy the fixes
cd /home/hevertonpablo/project/laravel/ledfine-bagisto

git add .
git commit -m "Fix Redis extension and database migration conflicts

- Add Redis PHP extension via PECL
- Handle duplicate foreign key constraints
- Add FORCE_FRESH_INSTALL option for clean database setup
- Improve migration error recovery"

git push origin main

echo ""
echo "✅ Fixes deployed! Coolify will rebuild in ~2-3 minutes"
echo ""
echo "📊 Monitoring commands for Coolify terminal:"
echo ""
echo "# 1. Check Redis is working:"
echo "docker exec -it \$(docker ps -q) php -m | grep redis"
echo ""
echo "# 2. Test Redis connection:"
echo "docker exec -it \$(docker ps -q) php -r \"echo (class_exists('Redis') ? 'Redis OK' : 'Redis FAIL') . PHP_EOL;\""
echo ""
echo "# 3. Check database setup:"
echo "docker exec -it \$(docker ps -q) php artisan migrate:status"
echo ""
echo "# 4. If you need fresh database (only if issues persist):"
echo "# Set FORCE_FRESH_INSTALL=true in Coolify environment variables"
echo ""

# Wait for deployment and test
echo "⏱️  Waiting 3 minutes for deployment..."
sleep 180

echo "🧪 Testing application..."
for i in {1..3}; do
    echo "Test $i/3..."
    response=$(curl -s -w "HTTP:%{http_code}|TIME:%{time_total}" "http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io" -o /dev/null)
    
    http_code=$(echo $response | cut -d'|' -f1 | cut -d':' -f2)
    time_total=$(echo $response | cut -d'|' -f2 | cut -d':' -f2)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ SUCCESS! Application working - HTTP 200 in ${time_total}s"
        echo ""
        echo "🎉 Your Bagisto store is ready!"
        echo "🔗 Store: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io"
        echo "🔗 Admin: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io/admin"
        exit 0
    else
        echo "⚠️  HTTP $http_code (${time_total}s) - still deploying..."
        sleep 30
    fi
done

echo ""
echo "📋 If still having issues, check these in Coolify terminal:"
echo "1. Container logs: docker logs \$(docker ps -q) | tail -50"
echo "2. Laravel logs: docker exec -it \$(docker ps -q) tail -20 /var/www/html/storage/logs/laravel.log"
echo "3. Migration status: docker exec -it \$(docker ps -q) php artisan migrate:status"