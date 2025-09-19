#!/bin/bash

echo "🚨 AGGRESSIVE DATABASE RESET SOLUTION"
echo "====================================="
echo ""
echo "❌ Problem: migrate:fresh is not working properly"
echo "❌ Still getting: Table 'ledfinebooking_product_appointment_slots' already exists"
echo "❌ Database is in corrupted state"
echo ""

echo "🔧 SOLUTION: Manual Database Drop + Recreate"
echo ""
echo "Run these commands in Coolify Terminal:"
echo ""

echo "# Step 1: Stop the application"
echo "docker stop \$(docker ps --filter name=app -q)"
echo ""

echo "# Step 2: Connect to MySQL and drop database completely"
echo "docker exec -it \$(docker ps --filter name=mysql -q) mysql -u ledfine_user_wagner -pledfine_Danydryan12* -e \"DROP DATABASE IF EXISTS ledfine_db; CREATE DATABASE ledfine_db;\""
echo ""

echo "# Step 3: Alternative approach if above doesn't work"
echo "docker exec -it \$(docker ps --filter name=mysql -q) bash"
echo "# Then inside MySQL container:"
echo "mysql -u ledfine_user_wagner -pledfine_Danydryan12*"
echo "DROP DATABASE IF EXISTS ledfine_db;"
echo "CREATE DATABASE ledfine_db;"
echo "FLUSH PRIVILEGES;"
echo "exit"
echo "exit"
echo ""

echo "# Step 4: Restart application container"
echo "docker start \$(docker ps -a --filter name=app -q)"
echo ""

echo "# Step 5: Monitor logs"
echo "docker logs -f \$(docker ps --filter name=app -q)"
echo ""

echo "🎯 ALTERNATIVE: Use Fresh Database Name"
echo "======================================="
echo "If the above is too complex, just change in Coolify:"
echo "DB_DATABASE=ledfine_db_v2"
echo ""
echo "This creates a completely new database, avoiding all conflicts."
echo ""

echo "✅ Expected Result:"
echo "- Clean database installation"
echo "- No more 'table already exists' errors"
echo "- Application should reach HTTP 200"
echo ""

echo "⚠️  This will DELETE ALL DATA! Make backup if needed:"
echo "docker exec \$(docker ps --filter name=mysql -q) mysqldump -u ledfine_user_wagner -pledfine_Danydryan12* ledfine_db > backup_\$(date +%Y%m%d_%H%M%S).sql"