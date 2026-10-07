<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';

use App\Database;

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("CLI only\n");
}

[$script, $username, $fullName, $email, $password] = array_pad($argv, 5, null);
if (!$username || !$fullName || !$email || !$password) {
    exit("Usage: php bin/create-admin.php <username> <full_name> <email> <password>\n");
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) exit("Invalid email\n");
if (strlen($password) < 12) exit("Password must be at least 12 characters\n");

$pdo = Database::connection();
$stmt = $pdo->prepare('INSERT INTO users (username, full_name, email, password_hash, role, is_active) VALUES (:username, :full_name, :email, :password_hash, :role, 1)');
$stmt->execute([
    'username' => $username,
    'full_name' => $fullName,
    'email' => $email,
    'password_hash' => password_hash($password, PASSWORD_DEFAULT),
    'role' => 'super_admin',
]);
echo "Super admin created.\n";
