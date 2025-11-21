<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - SkillMitra</title>

    <link rel="stylesheet" href="register.css">  <!-- Use your CSS file name -->
</head>

<body>

    <!-- HEADER -->
    <header class="header">
        <div class="logo">
            <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
            SkillMitra
        </div>
        <button class="back-btn" onclick="window.location.href='index.jsp'">← Back to Home</button>
    </header>

    <!-- MAIN CARD -->
    <div class="container">
        <div class="register-form" style="max-width: 450px; text-align:center;">

            <h1 style="font-size:24px; margin-bottom:10px;">Register</h1>
            <p style="color:#555; margin-bottom:25px;">Choose your account type to continue</p>

            <!-- Employer Button -->
            <button class="register-btn" 
                    onclick="window.location.href='employer_register.jsp'" 
                    style="margin-bottom:15px;">
                Register as Employer
            </button>

            <!-- Jobseeker Button -->
            <button class="register-btn" 
                    onclick="window.location.href='jobseeker_register.jsp'">
                Register as Jobseeker
            </button>

            <div class="form-footer" style="margin-top:20px;">
                Already have an account? <a href="login.jsp">Sign In</a>
            </div>
        </div>
    </div>

</body>
</html>
