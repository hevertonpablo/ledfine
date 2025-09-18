<?php
// Simple test file to verify PHP is working
echo "PHP is working!<br>";
echo "Time: " . date('Y-m-d H:i:s') . "<br>";
echo "PHP Version: " . PHP_VERSION . "<br>";
echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
echo "Script: " . $_SERVER['SCRIPT_NAME'] . "<br>";
echo "Server: " . ($_SERVER['HTTP_HOST'] ?? 'Unknown') . "<br>";

if (file_exists('../vendor/autoload.php')) {
    echo "✅ Laravel vendor folder found<br>";
} else {
    echo "❌ Laravel vendor folder not found<br>";
}

if (file_exists('../artisan')) {
    echo "✅ Artisan file found<br>";
} else {
    echo "❌ Artisan file not found<br>";
}

echo "<br>Directory contents:<br>";
echo "<pre>";
print_r(scandir('.'));
echo "</pre>";
?>
