<!DOCTYPE html>
<html>
<head>
    <title>Insert Page</title>
</head>
<body>
    <?php
    // Database connection
    $conn = new mysqli("localhost", "root", "", "worker");

    // Check connection
    if ($conn->connect_errno) {
        die("Failed to connect to MySQL: " . $conn->connect_error);
    }

    // Add the 'date_of_birth', 'contact_number', 'pincode', and 'Expected_wage' columns if they do not exist
    $alter_sql = "ALTER TABLE signup_form ADD COLUMN IF NOT EXISTS date_of_birth DATE, 
                  ADD COLUMN IF NOT EXISTS contact_number VARCHAR(15),
                  ADD COLUMN IF NOT EXISTS pincode VARCHAR(10),
                  ADD COLUMN IF NOT EXISTS Expected_wage DECIMAL(10, 2)";
    if ($conn->query($alter_sql) !== TRUE) {
        echo "Error adding columns: " . $conn->error;
    }

    // Taking values from the form data (input)
    $worker_name = $_REQUEST['worker-name'] ?? '';
    $worker_skills = $_REQUEST['worker-skills'] ?? '';
    $worker_dob = $_REQUEST['worker-dob'] ?? '';
    $worker_contact = $_REQUEST['worker-contact'] ?? '';
    $worker_state = $_REQUEST['worker-state'] ?? '';
    $worker_city = $_REQUEST['worker-city'] ?? '';
    $worker_email = $_REQUEST['worker-email'] ?? '';
    $worker_pincode = $_REQUEST['worker-pincode'] ?? '';
    $worker_gender = $_REQUEST['worker-gender'] ?? '';
    $worker_wage = $_REQUEST['worker-wage'] ?? '';

    // Insert query
    $sql = "INSERT INTO signup_form (name, Skills , date_of_birth, contact_number, state, city, email, pincode, gender, Expected_wage) 
            VALUES ('$worker_name', '$worker_skills', '$worker_dob', '$worker_contact', '$worker_state', '$worker_city', '$worker_email', '$worker_pincode', '$worker_gender', '$worker_wage')";

    // Execute query
    if ($conn->query($sql) === TRUE) {
        echo "<h3>Data stored in the database successfully. Please browse your localhost phpMyAdmin to view the updated data.</h3>";

        // Display submitted data
        echo nl2br("Worker Name: $worker_name\n"
            . "Skills: $worker_skills\n"
            . "date_of_birth: $worker_dob\n"
            . "Contact Number: $worker_contact\n"
            . "State: $worker_state\n"
            . "City: $worker_city\n"
            . "Email: $worker_email\n"
            . "Pincode: $worker_pincode\n"
            . "Gender: $worker_gender\n"
            . "Expected_Wage: ₹$worker_wage");
    } else {
        echo "ERROR: Could not execute query. " . $conn->error;
    }

    // Check if form is submitted for search
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['search'])) {
        $searchTerm = $conn->real_escape_string($_POST['search']);

        // Query to search for jobs
        $sql = "SELECT * FROM jobs WHERE skills_required LIKE '%$searchTerm%' OR job_title LIKE '%$searchTerm%'";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            echo "<h2>Search Results:</h2>";
            while ($row = $result->fetch_assoc()) {
                echo "<div style='border: 1px solid #ddd; padding: 10px; margin: 10px auto; width: 50%;'>";
                echo "<h3>" . htmlspecialchars($row['job_title']) . "</h3>";
                echo "<p>" . htmlspecialchars($row['job_description']) . "</p>";
                echo "<p><strong>Skills Required:</strong> " . htmlspecialchars($row['skills_required']) . "</p>";
                echo "<p><strong>Expected Wage:</strong> ₹" . htmlspecialchars($row['expected_wage']) . "</p>";
                echo "<p><strong>Posted By:</strong> " . htmlspecialchars($row['recruiter_name']) . "</p>";
                echo "</div>";
            }
        } else {
            echo "<p>No jobs found matching your search.</p>";
        }
    }

    // Close connection
    $conn->close();
    ?>
</body>
</html>
