<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - SkillMitra</title>
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

<div class="login-container">
    <h2 class="title">Login</h2>
    <p class="subtitle">Choose your account type and login</p>

    <!-- Toggle -->
    <div class="toggle">
        <button type="button" id="empBtn" class="active">Employer</button>
        <button type="button" id="wrkBtn">JobSeeker</button>
    </div>

    <!-- LOGIN FORM -->
    <form method="post" id="loginForm"
          action="<%= request.getContextPath() %>/EmployerLoginServlet">
        <%
    String error = request.getParameter("error");
    if ("invalid".equals(error)) {
%>
    <p style="color:red; margin-bottom:10px;">
        Invalid email or password
    </p>
<%
    }
%>

        <label>Email</label>
        <input type="email" name="email" required>

        <label>Password</label>
        <input type="password" name="password" required>

        <button type="submit" id="loginBtn" class="loginBtn">Login</button>

        <p class="signup">
            Don’t have an account?
            <a href="register.jsp">Sign Up</a>
        </p>
    </form>
</div>

<script>
    const empBtn = document.getElementById("empBtn");
    const wrkBtn = document.getElementById("wrkBtn");
    const loginForm = document.getElementById("loginForm");
    const emailInput = document.querySelector('input[name="email"]');
    const passwordInput = document.querySelector('input[name="password"]');

    function clearFields() {
        emailInput.value = "";
        passwordInput.value = "";
    }

    empBtn.addEventListener("click", () => {
        empBtn.classList.add("active");
        wrkBtn.classList.remove("active");
        loginForm.action = "<%= request.getContextPath() %>/EmployerLoginServlet";
        clearFields();
    });

    wrkBtn.addEventListener("click", () => {
        wrkBtn.classList.add("active");
        empBtn.classList.remove("active");
        loginForm.action = "<%= request.getContextPath() %>/JobSeekerLoginServlet";
        clearFields();
    });
</script>



</body>
</html>
