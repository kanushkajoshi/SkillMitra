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
        <button class="back-btn" onclick="window.location.href='home.jsp'">← Back to Home</button>
    </header>

    <div class="container">
<form class="register-form" method="post" action="<%= request.getContextPath() %>/EmployerRegisterServlet">

                <h1>Register as Employer</h1>

                <div class="form-grid">

            <div class="form-group">
                <label for="first_name">First Name *</label>
                <input type="text" id="first_name" name="first_name"
                       placeholder="Enter your first name" required>
            </div>

            <div class="form-group">
                <label for="last_name">Last Name *</label>
                <input type="text" id="last_name" name="last_name"
                       placeholder="Enter your last name" required>
            </div>

            <div class="form-group">
                <label for="phone">Phone Number *</label>
                <input type="tel" id="phone" name="phone"
                       placeholder="Enter your phone number (e.g. +91)" required>
            </div>

            <div class="form-group">
                <label for="email">Email ID *</label>
                <div class="email-container">
                <input type="email" id="email" name="email"
                       placeholder="Enter your email ID" required>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password *</label>
                <div class="password-container">
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password" required>
                    <button type="button" class="password-toggle"
                            onclick="togglePassword()">👁️</button>
                </div>
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
            Already have an account? <a href="#login">Sign In</a>
        </div>

    </form>

    </div>

    <script>
//        function handleSubmit(event) {
//            event.preventDefault();
//
//            const formData = new FormData(event.target);
//            const data = Object.fromEntries(formData.entries());
//
//            if (!data.first_name || !data.last_name || !data.phone ||
//!data.country || !data.state || !data.city) {
//                alert('Please fill in all required fields marked with *');
//                return;
//            }
//
//            if (data.phone.length < 10) {
//                alert('Please enter a valid phone number');
//                return;
//            }
//
//            alert('Registration successful! Welcome to SkillMitra!');
//            console.log('Registration data:', data);
//        }

        function togglePassword() {
            const passwordInput = document.getElementById('password');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
            } else {
                passwordInput.type = 'password';
            }
        }

        // Remove or update the input focus effects
        document.querySelectorAll('input, textarea, select').forEach(field => {
            field.addEventListener('focus', function() {
                // Remove the transform effect
                this.style.transform = 'none';
            });

            field.addEventListener('blur', function() {
                // Remove the transform effect
                this.style.transform = 'none';
            });
        });
    </script>
    
    



  
    
</body>
</html>


