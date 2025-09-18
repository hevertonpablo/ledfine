<?php
echo "PHP is working correctly!";
echo "\nTimestamp: " . date('Y-m-d H:i:s');
echo "\nServer: " . $_SERVER['HTTP_HOST'] ?? 'Unknown';
phpinfo();
?>
