<?php
// Connect to the database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "worker";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve form data
$name = $_POST['worker-name'];
$skills = $_POST['worker-skills'] == 'Other' ? $_POST['other-skill-input'] : $_POST['worker-skills'];
$dob = $_POST['worker-dob'];
$contact = $_POST['worker-contact'];
$email = $_POST['worker-email'];
$password = $_POST['worker-password'];
$pincode = $_POST['worker-pincode'];
$city = $_POST['worker-city'];
$state = $_POST['worker-state'];
$gender = $_POST['worker-gender'] == 'Other' ? $_POST['other-gender-input'] : $_POST['worker-gender'];
$wage = $_POST['worker-wage'];

// Insert data into the database
$sql = "INSERT INTO workers (name, skills, dob, contact, email, password, pincode, city, state, gender, wage) 
        VALUES ('$name', '$skills', '$dob', '$contact', '$email', '$password', '$pincode', '$city', '$state', '$gender', '$wage')";

if ($conn->query($sql) === TRUE) {
    // Redirect to confirmation page
    header("Location: worker_confirmation.html");
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
