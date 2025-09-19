#!/bin/bash

echo "🔄 Reverting to Working Configuration"
echo "===================================="
echo ""
echo "📋 Analysis Summary:"
echo "✅ Commit 028def5 WAS WORKING (only images missing)"
echo "❌ Subsequent commits broke the app with Redis/DB issues"
echo ""
echo "🔧 Reverted Configuration:"
echo "✅ Original working Dockerfile (WORKDIR /var/www/html)"
echo "✅ Simple database setup (no FORCE_FRESH_INSTALL complexity)"  
echo "✅ File-based cache/sessions (no Redis dependency)"
echo "✅ Original start.sh logic that was working"
echo ""
echo "🎯 Expected Result:"
echo "✅ Application should load properly"
echo "⚠️  Images may still not appear (next issue to fix)"
echo ""

echo "⏱️  Monitoring deployment..."

for i in {1..8}; do
    echo "Check $i/8 - $(date)"
    
    response=$(curl -s -w "HTTP:%{http_code}|TIME:%{time_total}" "http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io" -o /dev/null 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        http_code=$(echo $response | cut -d'|' -f1 | cut -d':' -f2)
        time_total=$(echo $response | cut -d'|' -f2 | cut -d':' -f2)
        
        if [ "$http_code" = "200" ]; then
            echo "✅ SUCCESS! Application is working again - HTTP 200 in ${time_total}s"
            echo ""
            echo "🎉 Bagisto store is functional!"
            echo "🔗 Store: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io"
            echo "🔗 Admin: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io/admin"
            echo ""
            echo "📋 Next Step: Fix Image Loading"
            echo "Most likely issues:"
            echo "1. Storage symlink not created"
            echo "2. Image permissions"
            echo "3. Asset URL configuration"
            echo ""
            echo "🧪 To test images in Coolify terminal:"
            echo "docker exec -it \$(docker ps -q) ls -la /var/www/html/storage/app/public"
            echo "docker exec -it \$(docker ps -q) ls -la /var/www/html/public/storage"
            echo "docker exec -it \$(docker ps -q) php artisan storage:link"
            exit 0
        elif [ "$http_code" = "500" ]; then
            echo "❌ HTTP 500 - Still having server errors"
        elif [ "$http_code" = "502" ]; then
            echo "⚠️  HTTP 502 - Container still starting"
        else
            echo "⚠️  HTTP $http_code (${time_total}s)"
        fi
    else
        echo "⚠️  Connection failed - container likely building"
    fi
    
    if [ $i -lt 8 ]; then
        echo "   Waiting 45 seconds..."
        sleep 45
    fi
done

echo ""
echo "🔍 If still not working, check these in Coolify terminal:"
echo "1. Container status: docker ps"
echo "2. Application logs: docker logs \$(docker ps -q) | tail -30"
echo "3. Laravel artisan: docker exec -it \$(docker ps -q) php artisan --version"
echo "4. File permissions: docker exec -it \$(docker ps -q) ls -la /var/www/html/"