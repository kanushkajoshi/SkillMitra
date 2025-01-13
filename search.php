<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find Your Job</title>
</head>
<body>
    <h1>Find Your Job</h1>
    <form action="search.php" method="get">
        <label for="skills">Enter your skills:</label>
        <input type="text" id="skills" name="skills" placeholder="e.g., Tailor" required>
        <button type="submit">Search</button>
    </form>

    <?php
    if (isset($_GET['skills'])) {
        $skills = $_GET['skills'];

        // Database connection
        $servername = "localhost";
        $username = "root";
        $password = ""; // Empty password
        $dbname = "worker";

        $conn = new mysqli($servername, $username, $password, $dbname);

        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

        // Fetch matching jobs
        $sql = "SELECT * FROM hirers WHERE skills_required LIKE '%$skills%'";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            echo "<h2>Jobs Found:</h2>";
            echo "<ul>";
            while ($row = $result->fetch_assoc()) {
                echo "<li><strong>" . $row['job_title'] . "</strong>: " . $row['description'] . "<br>Contact: " . $row['contact_email'] . "</li>";
            }
            echo "</ul>";
        } else {
            echo "<p>No jobs found for the skill '$skills'.</p>";
        }

        $conn->close();
    }
    ?>
</body>
</html>
