<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="header.jsp" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Employer Registration - SkillMitra</title>
    <link rel="icon" href="skillmitralogo.jpg">
    <link rel="stylesheet" href="employer_register.css">
</head>

<body>

<header class="header">
    <div class="logo">
        <img src="skillmitralogo.jpg">
        SkillMitra
    </div>
    <button class="back-btn" onclick="window.location.href='home.jsp'">Back to Home</button>
</header>

<div class="container">

<form class="register-form"
      method="post"
      action="<%= request.getContextPath() %>/EmployerRegisterServlet"
      autocomplete="off">

<h1>Register as Employer</h1>

<div class="form-grid">

<!-- FIRST NAME -->
<div class="form-group">
<label>First Name *</label>
<input type="text"
       id="first_name"
       name="efirstname"
       value="${param.efirstname}"
       pattern="[A-Za-z ]+"
       required>

<span id="fnameError" style="color:red;font-size:13px;"></span>
</div>

<!-- LAST NAME -->
<div class="form-group">
<label>Last Name *</label>
<input type="text"
       id="last_name"
       name="elastname"
       value="${param.elastname}"
       pattern="[A-Za-z ]+"
       required>

<span id="lnameError" style="color:red;font-size:13px;"></span>
</div>

<!-- DOB -->
<div class="form-group">
<label>DOB *</label>

<input type="date"
       id="dob"
       name="edob"
       value="${param.edob}"
       max="<%= java.time.LocalDate.now() %>"
       required>

<span id="dobErrorMsg" style="color:red;font-size:13px;">
${dobError}
</span>
</div>

<!-- PHONE -->
<div class="form-group">
<label>Phone *</label>
<input type="tel"
       name="ephone"
       value="${param.ephone}"
       pattern="[6-9][0-9]{9}"
       required>
<span style="color:red;">${phoneError}</span>
</div>

<!-- EMAIL -->
<div class="form-group">
<label>Email *</label>

<input type="email"
       id="eemail"
       name="eemail"
       value="${not empty oldEmail ? oldEmail : param.eemail}"
       required>

<span style="color:red;font-size:13px;">
${emailError}
</span>
</div>

<!-- PASSWORD -->
<div class="form-group">
<label>Password *</label>

<div class="password-container">
<input type="password"
       id="password"
       name="epwd"
       pattern="(?=.*[A-Za-z])(?=.*[0-9]).{6,}"
       required>

<i class="fa-regular fa-eye password-toggle"
   onclick="togglePassword()"></i>
</div>

<span style="color:red;">${passwordError}</span>
</div>

<!-- COMPANY -->
<div class="form-group">
<label>Company Name *</label>
<input type="text"
       name="ecompanyname"
       value="${param.ecompanyname}"
       required>
</div>

<!-- WEBSITE -->
<div class="form-group">
<label>Website</label>
<input type="url"
       name="companywebsite"
       value="${param.companywebsite}">
</div>

<!-- ZIP -->
<div class="form-group">
<label>Zip *</label>
<input type="text"
       id="zipcode"
       name="zip"
       value="${param.zip}"
       maxlength="6"
       pattern="\d{6}"
       required>
</div>

<!-- LOCATION -->
<div class="form-group">
<label>Country *</label>
<input type="text" id="country" name="country" readonly required>
</div>

<div class="form-group">
<label>State *</label>
<input type="text" id="state" name="state" readonly required>
</div>

<div class="form-group">
<label>District *</label>
<input type="text" id="district" name="district" readonly required>
</div>

<div class="form-group">
<label>Area *</label>
<select id="area" name="area" required>
<option value="">Select</option>
</select>
</div>

</div>

<button class="register-btn">Create Account</button>

<div class="form-footer">
Already have an account? <a href="login.jsp">Sign In</a>
</div>

</form>
</div>

<script>

// PASSWORD TOGGLE
function togglePassword(){
    let p = document.getElementById("password");
    p.type = (p.type === "password") ? "text" : "password";
}

// NAME VALIDATION
document.getElementById("first_name").addEventListener("input", function(){
    let v = this.value;
    let e = document.getElementById("fnameError");

    if(!/^[A-Za-z ]*$/.test(v)){
        e.innerText = "Only alphabets allowed";
        this.style.border = "2px solid red";
    } else {
        e.innerText = "";
        this.style.border = "";
    }
});

document.getElementById("last_name").addEventListener("input", function(){
    let v = this.value;
    let e = document.getElementById("lnameError");

    if(!/^[A-Za-z ]*$/.test(v)){
        e.innerText = "Only alphabets allowed";
        this.style.border = "2px solid red";
    } else {
        e.innerText = "";
        this.style.border = "";
    }
});

// DOB VALIDATION
document.getElementById("dob").addEventListener("change", function(){

    let dob = new Date(this.value);
    let today = new Date();

    let age = today.getFullYear() - dob.getFullYear();
    let m = today.getMonth() - dob.getMonth();

    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;

    let err = document.getElementById("dobErrorMsg");

    if(age < 18){
        err.innerText = "You must be at least 18 years old.";
        this.style.border = "2px solid red";
    } else {
        err.innerText = "";
        this.style.border = "";
    }
});

// ZIPCODE AUTO
document.getElementById("zipcode").addEventListener("input", function(){

    let pin = this.value;

    if(pin.length === 6){

        fetch("https://api.postalpincode.in/pincode/" + pin)
        .then(r => r.json())
        .then(d => {

            if(d[0].Status === "Success"){

                let po = d[0].PostOffice;

                document.getElementById("district").value = po[0].District;
                document.getElementById("state").value = po[0].State;
                document.getElementById("country").value = po[0].Country;

                let area = document.getElementById("area");
                area.innerHTML = "";

                po.forEach(p=>{
                    let opt = document.createElement("option");
                    opt.value = p.Name;
                    opt.textContent = p.Name;
                    area.appendChild(opt);
                });

            } else {
                alert("Invalid Pincode");
            }

        });
    }
});

</script>

</body>
</html>