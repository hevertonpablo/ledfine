#!/bin/sh

echo "=== BAGISTO 502 DEBUG SCRIPT ==="
echo "Run this inside the container to debug 502 issues"
echo ""

echo "1. Checking process status:"
ps aux | grep -E "(nginx|php-fpm)" | grep -v grep

echo ""
echo "2. Checking PHP-FPM listening:"
netstat -ln | grep 9000

echo ""
echo "3. Testing PHP-FPM directly:"
echo "<?php phpinfo(); ?>" | php

echo ""
echo "4. Checking Nginx error logs:"
tail -10 /var/log/supervisor/nginx-error.log 2>/dev/null || echo "No nginx error log found"

echo ""
echo "5. Checking PHP-FPM logs:"
tail -10 /var/log/supervisor/php-fpm.log 2>/dev/null || echo "No PHP-FPM log found"

echo ""
echo "6. Testing Laravel bootstrap:"
php /var/www/html/artisan --version

echo ""
echo "7. Checking file permissions:"
ls -la /var/www/html/public/index.php

echo ""
echo "8. Checking if Laravel can load:"
cd /var/www/html && php -r "
try {
    require 'vendor/autoload.php';
    \$app = require_once 'bootstrap/app.php';
    echo 'Laravel bootstrapped successfully';
} catch (Exception \$e) {
    echo 'Laravel bootstrap failed: ' . \$e->getMessage();
}
"