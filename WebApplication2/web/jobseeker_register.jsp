<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>JobSeeker Registration - SkillMitra</title>
  <link rel="stylesheet" href="jobseeker_register.css">
</head>
<body>
    <header class="header">
        <div class="logo">
            <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
            SkillMitra
        </div>
       <button class="back-btn" onclick="window.location.href='home.jsp'">? Back to Home</button>

    </header>

    <div class="container">
    <form class="register-form" action="JobSeekerRegisterServlet" method="post">
    <h1>Register as JobSeeker</h1>

    <div class="form-grid">
        <div class="form-group">
            <label for="first_name">First Name *</label>
            <input type="text" id="first_name" name="first_name" required>
        </div>

        <div class="form-group">
            <label for="last_name">Last Name </label>
            <input type="text" id="last_name" name="last_name" required>
        </div>

        <div class="form-group">
            <label for="phone">Phone Number *</label>
            <input type="tel" id="phone" name="phone" required>
        </div>

        <div class="form-group">
            <label for="email">Email ID *</label>
            <input type="email" id="email" name="email" required>
        </div>

        <div class="form-group">
            <label for="password">Password *</label>
            <div class="password-container">
                <input type="password" id="password" name="password" required>
                <button type="button" class="password-toggle" onclick="togglePassword()">?</button>
            </div>
        </div>
    </div>

    <div class="form-grid">
        <div class="form-group">
            <label for="country">Country *</label>
            <input type="text" id="country" name="country" required>
        </div>

        <div class="form-group">
            <label for="state">State *</label>
            <input type="text" id="state" name="state" required>
        </div>

        <div class="form-group">
            <label for="city">City *</label>
            <input type="text" id="city" name="city" required>
        </div>

        <div class="form-group">
            <label for="zipcode">Zipcode *</label>
            <input type="text" id="zipcode" name="zipcode" required>
        </div>
    </div>

    <div class="form-grid">
        <div class="form-group">
            <label for="date_of_birth">Date of Birth</label>
            <input type="date" id="date_of_birth" name="date_of_birth">
        </div>

        <div class="form-group">
            <label for="languages_spoken">Languages Spoken</label>
            <input type="text" id="languages_spoken" name="languages_spoken">
        </div>

        <div class="form-group">
            <label for="qualifications">Education/Qualifications</label>
            <input type="text" id="qualifications" name="qualifications">
        </div>
    </div>

    <button type="submit" class="register-btn">Create Account</button>

    <div class="form-footer">
        Already have an account? <a href="login.jsp">Sign In</a>
    </div>
</form>

</div>
</body>
</html>
