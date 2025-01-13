<!DOCTYPE html>
<html>
<head>
    <title>Insert and Search Worker Data</title>
</head>
<body>
    <?php
    // Database connection
    $conn = new mysqli("localhost", "root", "", "worker");

    // Check connection
    if ($conn->connect_errno) {
        die("Failed to connect to MySQL: " . $conn->connect_error);
    }

    // Ensure required columns exist in the table
    $alter_sql = "ALTER TABLE signup_form 
                  ADD COLUMN IF NOT EXISTS date_of_birth DATE, 
                  ADD COLUMN IF NOT EXISTS contact_number VARCHAR(15),
                  ADD COLUMN IF NOT EXISTS pincode VARCHAR(10),
                  ADD COLUMN IF NOT EXISTS Expected_wage DECIMAL(10, 2)";
    if ($conn->query($alter_sql) !== TRUE) {
        echo "Error adding columns: " . $conn->error;
    }

    // Handle form submission for inserting worker data
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_worker'])) {
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
        $sql = "INSERT INTO signup_form (name, Skills, date_of_birth, contact_number, state, city, email, pincode, gender, Expected_wage) 
                VALUES ('$worker_name', '$worker_skills', '$worker_dob', '$worker_contact', '$worker_state', '$worker_city', '$worker_email', '$worker_pincode', '$worker_gender', '$worker_wage')";

        // Execute query
        if ($conn->query($sql) === TRUE) {
            echo "<h3>Data stored successfully. Check your database for updates.</h3>";

            // Display submitted data
            echo nl2br("<strong>Submitted Data:</strong>\n"
                . "Name: $worker_name\n"
                . "Skills: $worker_skills\n"
                . "Date of Birth: $worker_dob\n"
                . "Contact: $worker_contact\n"
                . "State: $worker_state\n"
                . "City: $worker_city\n"
                . "Email: $worker_email\n"
                . "Pincode: $worker_pincode\n"
                . "Gender: $worker_gender\n"
                . "Expected Wage: ₹$worker_wage\n");
        } else {
            echo "Error storing data: " . $conn->error;
        }
    }

    // Handle search functionality
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['search'])) {
        $searchTerm = $conn->real_escape_string($_POST['search']);

        // Search query for jobs
        $sql = "SELECT * FROM hirers 
                WHERE skills_required LIKE '%$searchTerm%' 
                OR job_title LIKE '%$searchTerm%'";

        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            echo "<h2>Search Results:</h2>";
            while ($row = $result->fetch_assoc()) {
                echo "<div style='border: 1px solid #ddd; padding: 10px; margin: 10px auto; width: 50%;'>";
                echo "<h3>" . htmlspecialchars($row['job_title']) . "</h3>";
                echo "<p>" . htmlspecialchars($row['description']) . "</p>";
                echo "<p><strong>Skills Required:</strong> " . htmlspecialchars($row['skills_required']) . "</p>";
                echo "<p><strong>Contact Email:</strong> " . htmlspecialchars($row['contact_email']) . "</p>";
                echo "</div>";
            }
        } else {
            echo "<p>No jobs found matching your search criteria.</p>";
        }
    }

    // Close database connection
    $conn->close();
    ?>
    <br>
    <!-- Search form -->
    <form method="post" action="submitworker.php">
        <h2>Search for Jobs</h2>
        <input type="text" name="search" placeholder="Enter skills or job title" required>
        <button type="submit">Search</button>
    </form>
</body>
</html>
