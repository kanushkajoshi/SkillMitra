<%-- 
    Document   : employee_register
    Created on : 21 Nov, 2025, 11:53:56 PM
    Author     : hp
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


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

<% if (request.getAttribute("error") != null) { %>
    <p style="color:red;"><%= request.getAttribute("error") %></p>
<% } %>

    <div class="container">
    <form class="register-form" method="post" action="<%= request.getContextPath() %>/EmployerRegisterServlet" autocomplete="off" onsubmit="return validateEmail();">

                <h1>Register as Employer</h1>

                <div class="form-grid">

            <div class="form-group">
                <label for="first_name">First Name *</label>
                <input type="text" id="first_name" name="firstname"
       value="${param.firstname}"
       placeholder="Enter your first name" required>

            </div>

            <div class="form-group">
                <label for="last_name">Last Name *</label>
                <input type="text" id="last_name" name="lastname"
       value="${param.lastname}"
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
                <input type="text" id="company_name" name="companyname"
       value="${param.companyname}"
       placeholder="Enter your company name">

            </div>

            <div class="form-group">
                <label for="website">Company Website</label>
                <input type="url" id="website" name="companywebsite"
       value="${param.companywebsite}"
       placeholder="Enter company website">

            </div>
            <div class="form-group">
                <label for="zipcode">Zipcode *</label>
                <input type="text" id="zipcode" name="zip"
       value="${param.zip}"
       maxlength="6" pattern="\d{6}" required>

            </div>
    
            <div class="form-group">
                <label for="country">Country *</label>
                <input type="text" id="country" name="country" required readonly>
            </div>

            <div class="form-group">
                <label for="state">State *</label>
                <input type="text" id="state" name="state" required readonly>
            </div>

            <div class="form-group">
                <label for="district">District (City) *</label>
                <input type="text" id="district" name="district" required readonly>
            </div>
    
            <div class="form-group">
                <label for="area">Locality/Area *</label>
                <select id="area" name="area" required>
    <option value="">Select area</option>
    <c:if test="${not empty param.area}">
        <option value="${param.area}" selected>
            ${param.area}
        </option>
    </c:if>
</select>

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

            document.querySelectorAll('input, textarea, select').forEach(field => {field.addEventListener('focus', function() {
                    this.style.transform = 'none';
                });

                field.addEventListener('blur', function() { this.style.transform = 'none';});
            });
        });
        //Zipcode
        document.addEventListener("DOMContentLoaded", function () {

    const zipInput = document.getElementById("zipcode");
    const district = document.getElementById("district");
    const state = document.getElementById("state");
    const country = document.getElementById("country");
    const areaSelect = document.getElementById("area");

    zipInput.addEventListener("input", function () {

        let pincode = this.value.trim();

        if (pincode.length === 6 && /^\d{6}$/.test(pincode)) {

            fetch("https://api.postalpincode.in/pincode/" + pincode)
            .then(res => res.json())
            .then(data => {

                console.log(data); // debug

                if (data[0].Status === "Success") {

                    let po = data[0].PostOffice;

                    // Fill fields
                    district.value = po[0].District;
                    state.value = po[0].State;
                    country.value = po[0].Country;

                    // Fill area dropdown
                    areaSelect.innerHTML = "";

                    po.forEach(p => {
                        let opt = document.createElement("option");
                        opt.value = p.Name;
                        opt.textContent = p.Name;
                        areaSelect.appendChild(opt);
                    });

                } else {
                    alert("Invalid Pincode");

                    district.value = "";
                    state.value = "";
                    country.value = "";
                    areaSelect.innerHTML =
                        "<option value=''>Select area</option>";
                }
            })
            .catch(err => console.log(err));
        }
    });

});


    //VALID EMAIL
    function validateEmail() 
    {
        const email = document.getElementById("email").value;
        const errorSpan = document.getElementById("emailError");

        // Strong email regex 
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

        if (!emailPattern.test(email)) {
            errorSpan.innerText = "❌ Invalid email address. Please enter a valid email (example@gmail.com)";
            return false;
        } else {
            errorSpan.innerText = "";
            return true;
        }
    }
    </script>
    
    



  
    
</body>
</html>


