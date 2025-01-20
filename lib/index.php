<?php
// Database configuration
$host = 'localhost'; 
$user = 'root'; // Your MySQL username
$password = ''; // Your MySQL password
$database = 'notes_appp';

// Create a PDO connection to the database
try {
    $pdo = new PDO("mysql:host=$host;dbname=$database", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); // Enable exceptions for errors
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

// Handle POST request (Add Note)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = filter_input(INPUT_POST, 'title', FILTER_SANITIZE_STRING);
    $content = filter_input(INPUT_POST, 'content', FILTER_SANITIZE_STRING);

    if (!$title || !$content) {
        http_response_code(400);
        echo json_encode(['error' => 'Title and content are required']);
        exit;
    }

    $sql = "INSERT INTO notes (title, content) VALUES (:title, :content)";
    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':title' => $title, ':content' => $content]);

        echo json_encode(['message' => 'Note created successfully']);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
    }
}

// Handle GET request (Fetch All Notes)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM notes";
    try {
        $stmt = $pdo->query($sql);
        $notes = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($notes);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
    }
}

// Handle PUT request (Edit Note)
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Read the raw input (as form-encoded data) and parse it into $_POST
    parse_str(file_get_contents("php://input"), $_POST);

    // Now $_POST should contain the form data
    $id = filter_var($_POST['id'], FILTER_VALIDATE_INT);
    $title = filter_var($_POST['title'], FILTER_SANITIZE_STRING);
    $content = filter_var($_POST['content'], FILTER_SANITIZE_STRING);

    // Check if the required data is present
    if (!$id || !$title || !$content) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid request data']);
        exit;
    }

    // Prepare the SQL query to update the note
    $sql = "UPDATE notes SET title = :title, content = :content WHERE id = :id";
    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':id' => $id, ':title' => $title, ':content' => $content]);

        // Check if any rows were affected (i.e., note exists and was updated)
        if ($stmt->rowCount()) {
            echo json_encode(['message' => 'Note updated successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Note not founds']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
    }
}

?>
