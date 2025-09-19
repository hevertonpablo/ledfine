#!/bin/bash

echo "🔧 Critical Fix Deployed!"
echo "WORKDIR is now correctly set to /var/www/html in the Dockerfile"
echo ""
echo "⏱️  Waiting for Coolify to rebuild the container (2-3 minutes)..."
echo ""

# Wait for deployment
sleep 120

echo "🧪 Testing the fix..."

# Test the application
for i in {1..5}; do
    echo "Test $i/5 - $(date)"
    
    response=$(curl -s -w "HTTP:%{http_code}|TIME:%{time_total}" "http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io" -o /dev/null)
    
    http_code=$(echo $response | cut -d'|' -f1 | cut -d':' -f2)
    time_total=$(echo $response | cut -d'|' -f2 | cut -d':' -f2)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ SUCCESS! HTTP 200 in ${time_total}s"
        echo ""
        echo "🎉 Your Bagisto store is now working!"
        echo "🔗 Store: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io"
        echo "🔗 Admin: http://ncgcs4wg8gk4ggcocs00skos.212.85.23.44.sslip.io/admin"
        echo ""
        echo "Default admin credentials (if seeded):"
        echo "Email: admin@example.com"
        echo "Password: admin123"
        exit 0
    elif [ "$http_code" = "502" ]; then
        echo "⚠️  Still getting 502 - container may still be starting..."
    else
        echo "⚠️  HTTP $http_code in ${time_total}s"
    fi
    
    if [ $i -lt 5 ]; then
        echo "Waiting 30 seconds..."
        sleep 30
    fi
done

echo ""
echo "❌ Still having issues. Please run these commands in Coolify terminal:"
echo ""
echo "# Check if artisan is now accessible:"
echo "docker exec -it \$(docker ps -q) php artisan --version"
echo ""
echo "# Check current directory:"
echo "docker exec -it \$(docker ps -q) pwd"
echo ""
echo "# Check if files exist:"
echo "docker exec -it \$(docker ps -q) ls -la artisan"