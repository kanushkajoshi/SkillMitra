
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Employer Login</title>
         <link rel="stylesheet" href="jobseeker_login.css">
    </head>
    <body>
        <header class="header">
        <nav class="nav-container">
            <div class="logo">
                <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
               
                SkillMitra
            </div>
           
        </nav>
    </header>

    <main class="main-content">
        <div class="login-container">
            <h1 class="login-title">Login as Employer</h1>
            
            <form id="loginForm">
                <div class="form-group">
                    <label for="email" class="form-label">Email</label>
                    <input 
                        type="email" 
                        id="email" 
                        name="email" 
                        class="form-input" 
                        placeholder="Enter your email address"
                        required
                    >
                </div>
  <div class="form-group">
                    <label for="password" class="form-label">Password</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        class="form-input" 
                        placeholder="Enter your password"
                        required
                    >
                </div>

                <button type="submit" class="login-btn">Login</button>
            </form>

            <div class="form-footer">
                <a href="#forgot">Forgot Password?</a>
                <div class="divider">or</div>
                <a href="emp_dash.jsp">Don't have an account? Sign Up</a>
            </div>
        </div>
    </main>

    </body>
</html>
