<?php

// Simple health check endpoint for Docker/Coolify
header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate');

try {
    // Check if Laravel is working
    if (!file_exists(__DIR__ . '/../vendor/autoload.php')) {
        throw new Exception('Vendor autoload not found');
    }
    
    require_once __DIR__ . '/../vendor/autoload.php';
    
    $app = require_once __DIR__ . '/../bootstrap/app.php';
    
    // Try to boot the application
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    
    // Basic database connection test
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
        $dbStatus = 'connected';
    } catch (Exception $e) {
        $dbStatus = 'disconnected';
    }
    
    $response = [
        'status' => 'healthy',
        'timestamp' => date('c'),
        'services' => [
            'app' => 'running',
            'database' => $dbStatus
        ]
    ];
    
    http_response_code(200);
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    $response = [
        'status' => 'unhealthy',
        'timestamp' => date('c'),
        'error' => $e->getMessage()
    ];
    
    http_response_code(503);
    echo json_encode($response, JSON_PRETTY_PRINT);
}
?>
