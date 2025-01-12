<?php
// Mock data (replace with database query later)
$workers = [
    [
        "name" => "John Doe",
        "skills" => "Carpenter",
        "dob" => "1990-01-01",
        "contact" => "1234567890",
        "email" => "john@example.com",
        "pincode" => "560001",
        "city" => "Bangalore",
        "state" => "Karnataka",
        "gender" => "Male",
        "wage" => "500"
    ],
    [
        "name" => "Jane Smith",
        "skills" => "Electrician",
        "dob" => "1992-02-02",
        "contact" => "9876543210",
        "email" => "jane@example.com",
        "pincode" => "400001",
        "city" => "Mumbai",
        "state" => "Maharashtra",
        "gender" => "Female",
        "wage" => "700"
    ]
];

header('Content-Type: application/json');
echo json_encode($workers);
?>
