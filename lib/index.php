<?php
$host = 'localhost'; 
$user = 'root'; // Your MySQL username
$password = ''; // Your MySQL password
$database = 'notes_appp';

// Create a connection to the database
$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle POST request (Add Note)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = $_POST['title'];
    $content = $_POST['content'];

    $sql = "INSERT INTO notes (title, content) VALUES ('$title', '$content')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(['message' => 'Note created successfully']);
    } else {
        echo json_encode(['error' => 'Error: ' . $conn->error]);
    }
}

// Handle GET request (Fetch All Notes)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM notes";
    $result = $conn->query($sql);

    $notes = [];
    while ($row = $result->fetch_assoc()) {
        $notes[] = $row;
    }

    echo json_encode($notes);
}

// Handle DELETE request (Delete Note)
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    parse_str(file_get_contents("php://input"), $_DELETE);
    $id = $_DELETE['id'];
    
    $sql = "DELETE FROM notes WHERE id = $id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(['message' => 'Note deleted successfully']);
    } else {
        echo json_encode(['error' => 'Error: ' . $conn->error]);
    }
}

// Handle PUT request (Update Note)
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    parse_str(file_get_contents("php://input"), $_PUT);
    $id = $_PUT['id'];
    $title = $_PUT['title'];
    $content = $_PUT['content'];

    $sql = "UPDATE notes SET title='$title', content='$content' WHERE id=$id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(['message' => 'Note updated successfully']);
    } else {
        echo json_encode(['error' => 'Error: ' . $conn->error]);
    }
}

$conn->close();
?>
