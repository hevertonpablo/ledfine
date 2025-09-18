<?php
header('Content-Type: text/plain');
echo "PHP is working!\n";
echo "Timestamp: " . date('Y-m-d H:i:s') . "\n";
echo "PHP Version: " . PHP_VERSION . "\n";
echo "Server: " . ($_SERVER['HTTP_HOST'] ?? 'Unknown') . "\n";
echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "\n";
echo "Script: " . $_SERVER['SCRIPT_NAME'] . "\n";

// Test database connection
try {
    $pdo = new PDO(
        sprintf('mysql:host=%s;port=%s;dbname=%s', 
            $_ENV['DB_HOST'] ?? 'db',
            $_ENV['DB_PORT'] ?? '3306', 
            $_ENV['DB_DATABASE'] ?? 'ledfine_db'
        ),
        $_ENV['DB_USERNAME'] ?? 'ledfine_user',
        $_ENV['DB_PASSWORD'] ?? ''
    );
    echo "Database: Connected\n";
} catch (Exception $e) {
    echo "Database: Failed - " . $e->getMessage() . "\n";
}
?>
