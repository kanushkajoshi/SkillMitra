<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Jobseeker Login</title>
    <link rel="stylesheet" href="login.css">
</head>

<body>

    <header class="navbar">
    <nav class="nav-container">
        <div class="logo">
            <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
            SkillMitra
        </div>
    </nav>
</header>


    <!-- LOGIN CARD -->
    <div class="login-container">
        <h2 class="title">Login</h2>
        <p class="subtitle">Choose your account type and login</p>

        <!-- Toggle -->
        <div class="toggle">
            <button id="empBtn" class="active">Employer</button>
            <button id="wrkBtn">Jobseeker</button>
        </div>

        <form>
            <label>Email</label>
            <input type="email" placeholder="example@email.com" required>

            <label>Password</label>
            <input type="password" placeholder="Enter password" required>

            <button type="submit" id="loginBtn" class="loginBtn">Login</button>

            <p class="signup">
                Don’t have an account? <a href="register.jsp">Sign Up</a>
            </p>
        </form>
    </div>

    <script>
        const empBtn = document.getElementById("empBtn");
        const wrkBtn = document.getElementById("wrkBtn");
        const loginBtn = document.getElementById("loginBtn");

        empBtn.onclick = () => {
            empBtn.classList.add("active");
            wrkBtn.classList.remove("active");
            loginBtn.textContent = "Login";
        };

        wrkBtn.onclick = () => {
            wrkBtn.classList.add("active");
            empBtn.classList.remove("active");
            loginBtn.textContent = "Login";
        };
    </script>

</body>
</html>
