<%-- 
    Document   : employee_register
    Created on : 21 Nov, 2025, 11:53:56 PM
    Author     : hp
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        
        
    <title>Employer Registration - SkillMitra</title>
     <link rel="icon" href="skillmitralogo.jpg" type="image/x-icon">
     <link rel="stylesheet" href="employer_register.css">
    </head>
   <body>
    <header class="header">
        <div class="logo">
            <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
            SkillMitra
        </div>
        <button class="back-btn" onclick="window.location.href='home.jsp'">Back to Home</button>
    </header>


    <div class="container">
    <form class="register-form" method="post" action="<%= request.getContextPath() %>/EmployerRegisterServlet"  autocomplete="off">

                <h1>Register as Employer</h1>

                <div class="form-grid">

            <div class="form-group">
                <label for="first_name">First Name *</label>
                <input type="text" id="first_name" name="first_name" placeholder="Enter your first name" required>
            </div>

            <div class="form-group">
                <label for="last_name">Last Name *</label>
                <input type="text" id="last_name" name="last_name"
                       placeholder="Enter your last name" required>
            </div>

       <div class="form-group">
    <label for="phone">Phone Number *</label>
    <input type="tel" id="phone" name="phone" value="${param.phone}" pattern="[6-9][0-9]{9}" title="Enter a valid 10-digit Indian mobile number" required>
<span style="color:red;">
    ${phoneError}
</span>

</div>
      <div class="form-group">
      <label for="email">Email ID *</label>
      <input type="email" id="email" name="email"
           value="${param.email}" autocomplete="off" required>

    <span class="error-msg">${emailError}</span>
</div>

      <div class="form-group">
    <label for="password">Password *</label>
    <div class="password-container">
        <input type="password"
               id="password"
               name="password"
               autocomplete="new-password"
               pattern="(?=.*[A-Za-z])(?=.*[0-9]).{6,}"
               title="Password must contain letters and numbers (min 6 characters)"
               required>
        <i class="fa-regular fa-eye password-toggle" onclick="togglePassword()"></i>

    </div>
    <span style="color:red;">
        ${passwordError}
    </span>
</div>

            <div class="form-group">
                <label for="company_name">Company Name</label>
                <input type="text" id="company_name" name="company_name"
                       placeholder="Enter your company name">
            </div>

            <div class="form-group">
                <label for="website">Company Website</label>
                <input type="url" id="website" name="website"
                       placeholder="Enter company website">
            </div>

            <div class="form-group">
                <label for="country">Country *</label>
                <input type="text" id="country" name="country"
                       placeholder="Enter your country" required>
            </div>

            <div class="form-group">
                <label for="state">State *</label>
                <input type="text" id="state" name="state"
                       placeholder="Enter your state" required>
            </div>

            <div class="form-group">
                <label for="city">City *</label>
                <input type="text" id="city" name="city"
                       placeholder="Enter your city" required>
            </div>

            <div class="form-group">
                <label for="zipcode">Zipcode *</label>
                <input type="text" id="zipcode" name="zipcode"
                       placeholder="Enter zipcode" required>
            </div>

        </div>

        <button type="submit" class="register-btn">Create Account</button>

        <div class="form-footer">
            or<br><br>
            Already have an account? <a href="login.jsp">Sign In</a>
        </div>

    </form>

    </div>

    <script>
//       

        function togglePassword() {
            const passwordInput = document.getElementById('password');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
            } else {
                passwordInput.type = 'password';
            }
        }

        // Remove or update the input focus effects
        document.addEventListener("DOMContentLoaded", function () {

    document.querySelectorAll('input, textarea, select').forEach(field => {
        field.addEventListener('focus', function() {
            this.style.transform = 'none';
        });

        field.addEventListener('blur', function() {
            this.style.transform = 'none';
        });
    });

});
    </script>
    
    



  
    
</body>
</html>


