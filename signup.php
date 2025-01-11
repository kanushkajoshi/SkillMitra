<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// Database connection
$host = "localhost"; // Replace with your host
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password
$database = "your_database_name"; // Replace with your database name

$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch form data
$name = $_POST['worker-name'];
$skills = $_POST['worker-skills'];
$other_skill = isset($_POST['other-skill-input']) ? $_POST['other-skill-input'] : null;
$other_info = isset($_POST['worker-other-info']) ? $_POST['worker-other-info'] : null;
$dob = $_POST['worker-dob'];
$contact_number = $_POST['worker-contact'];
$email = $_POST['worker-email'];
$gender = $_POST['worker-gender'];
$other_gender = isset($_POST['other-gender-input']) ? $_POST['other-gender-input'] : null;
$expected_wage = $_POST['worker-wage'];

// Set skill to "Other" if additional skill provided
if (!empty($other_skill)) {
    $skills = $other_skill;
}

// Set gender to "Other" if additional gender provided
if (!empty($other_gender)) {
    $gender = $other_gender;
}

// Prepare and bind SQL statement
$stmt = $conn->prepare("INSERT INTO workers (Name, Skills, If_other_then_specify, Date_of_birth, Contact_number, Email, Gender, Expected_Wage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssissi", $name, $skills, $other_info, $dob, $contact_number, $email, $gender, $expected_wage);

// Execute statement
if ($stmt->execute()) {
    echo "Registration successful!";
} else {
    echo "Error: " . $stmt->error;
}

// Close connection
$stmt->close();
$conn->close();
?>
