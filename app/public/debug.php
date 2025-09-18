<?php
header('Content-Type: text/plain');

echo "=== ENVIRONMENT VARIABLES ===\n";
echo "DB_HOST: " . ($_ENV['DB_HOST'] ?? 'NOT SET') . "\n";
echo "DB_PORT: " . ($_ENV['DB_PORT'] ?? 'NOT SET') . "\n";
echo "DB_DATABASE: " . ($_ENV['DB_DATABASE'] ?? 'NOT SET') . "\n";
echo "DB_USERNAME: " . ($_ENV['DB_USERNAME'] ?? 'NOT SET') . "\n";
echo "DB_PASSWORD: " . (isset($_ENV['DB_PASSWORD']) ? '[SET]' : 'NOT SET') . "\n";
echo "APP_ENV: " . ($_ENV['APP_ENV'] ?? 'NOT SET') . "\n";
echo "APP_KEY: " . (isset($_ENV['APP_KEY']) ? '[SET]' : 'NOT SET') . "\n";

echo "\n=== DATABASE CONNECTION TEST ===\n";

try {
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s', 
        $_ENV['DB_HOST'] ?? 'db',
        $_ENV['DB_PORT'] ?? '3306', 
        $_ENV['DB_DATABASE'] ?? 'ledfine_db'
    );
    
    echo "DSN: $dsn\n";
    echo "Username: " . ($_ENV['DB_USERNAME'] ?? 'ledfine_user') . "\n";
    
    $pdo = new PDO(
        $dsn,
        $_ENV['DB_USERNAME'] ?? 'ledfine_user',
        $_ENV['DB_PASSWORD'] ?? 'ledfine_pass'
    );
    
    echo "✅ Database: Connected successfully!\n";
    
    // Test query
    $stmt = $pdo->query("SELECT 1 as test");
    $result = $stmt->fetch();
    echo "✅ Test query result: " . $result['test'] . "\n";
    
} catch (Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    
    // Try with different credentials
    echo "\n=== TRYING DEFAULT CREDENTIALS ===\n";
    try {
        $pdo = new PDO(
            "mysql:host=db;port=3306;dbname=ledfine_db",
            "ledfine_user",
            "ledfine_pass"
        );
        echo "✅ Connected with default credentials!\n";
    } catch (Exception $e2) {
        echo "❌ Default credentials also failed: " . $e2->getMessage() . "\n";
    }
}

echo "\n=== PHP INFO ===\n";
echo "PHP Version: " . PHP_VERSION . "\n";
echo "Current Directory: " . getcwd() . "\n";
echo "Script Path: " . __FILE__ . "\n";
?>
