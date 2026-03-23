<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="db.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="header.jsp" %>
<%
/* Prevent browser caching */
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

/* Optional: clear old registration session if exists */
if(session.getAttribute("user") != null){
    response.sendRedirect("dashboard.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>JobSeeker Registration - SkillMitra</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/jobseeker_register.css">
</head>

<body>

<header class="header">
    <div class="logo">
        <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
        SkillMitra
    </div>

    <button class="back-btn"
            onclick="window.location.href='home.jsp'">
        Back to Home
    </button>
</header>



<div class="container">

<form class="register-form"
      method="post"
      action="<%= request.getContextPath() %>/JobSeekerRegisterServlet"
      onsubmit="return validateForm()">
<% if(request.getAttribute("error")!=null){ %>
<p style="color:red;text-align:center;font-weight:600;">
    <%=request.getAttribute("error")%>
</p>
<% } %>
<% if("wrong".equals(request.getParameter("otp"))){ %>

<div id="popup"
     style="background:red;
            color:white;
            padding:12px;
            text-align:center;
            font-weight:bold;">

Wrong OTP! Please check your email and try again.

</div>

<script>
setTimeout(function(){
    document.getElementById("popup")
    .style.display="none";
},3000);
</script>

<% } %>

<h1>Register as Job Seeker</h1>

<!-- GRID START -->
<div class="form-grid">

    <!-- First Name -->
<div class="form-group">
    <label>First Name *</label>
    <input type="text"
           id="jfirstname"
           name="jfirstname"
           value="${param.jfirstname}"
           pattern="[A-Za-z ]+"
           required>
    <span id="fnameError" style="color:red;font-size:13px;"></span>
</div>

   <!-- Last Name -->
<div class="form-group">
    <label>Last Name *</label>
    <input type="text"
           id="jlastname"
           name="jlastname"
           value="${param.jlastname}"
           pattern="[A-Za-z ]+"
           required>
    <span id="lnameError" style="color:red;font-size:13px;"></span>
</div>

    <!-- Phone -->
    <div class="form-group">
        <label>Phone *</label>
        <input type="tel"
               name="jphone"
               value="${param.jphone}"
               pattern="[6-9][0-9]{9}"
               required>
    </div>

  <!-- EMAIL -->
<div class="form-group">
    <label>Email *</label>

    <input type="email"
           id="jemail"
           name="jemail"
           onkeyup="checkEmail()"
           value="${param.jemail != null ? param.jemail : oldEmail}"
           required>

    <!-- Real-time message -->
    <span id="emailMsg" style="font-size:13px;"></span>

    <!-- Backend error -->
    <span style="color:red; font-size:13px;">
        ${emailError}
    </span>
</div>



    <!-- Password -->
    <div class="form-group">
        <label>Password *</label>
        <input type="password"
               name="jpwd"
               required>
    </div>

    <!-- Education -->
    <div class="form-group">
        <label>Education *</label>
        <select name="jeducation" required>
            <option value="">Select</option>

            <option value="10th Pass"
                ${param.jeducation=="10th Pass"?"selected":""}>
               10th Pass
            </option>

            <option value="12th Pass"
                ${param.jeducation=="12th Pass"?"selected":""}>
                12th Pass
            </option>
            
            <option value="Graduate"
                ${param.jeducation=="Graduate"?"selected":""}>
                Graduate
            </option>
            <option value="Masters"
                ${param.jeducation=="Masters"?"selected":""}>
                Master
            </option>
        </select>
    </div>

    <!-- DOB -->
<div class="form-group">
    <label>DOB *</label>
    <input type="date"
           id="jdob"
           name="jdob"
           value="${param.jdob}"
           max="<%= java.time.LocalDate.now() %>"
           required>

    <span id="dobErrorMsg" style="color:red;font-size:13px;">
        ${dobError}
    </span>
</div>
    <!-- Gender -->
<!-- Gender -->
<div class="form-group">
    <label>Gender *</label>
    <select name="jgender" required>
        <option value="">Select</option>
        <option value="Male" ${param.jgender=="Male"?"selected":""}>Male</option>
        <option value="Female" ${param.jgender=="Female"?"selected":""}>Female</option>
    </select>
</div>
    <!-- Skill -->
    <div class="form-group">
        <label>Skill *</label>
        <select id="skill" name="skill"
        onchange="loadSubskills()" required>

            <option value="">Select Skill</option>

            <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                con = DBConnection.getConnection();

                ps = con.prepareStatement(
                    "SELECT skill_id, skill_name FROM skill ORDER BY skill_name"
                );

                rs = ps.executeQuery();

                while (rs.next()) {
            %>
                    <option value="<%= rs.getInt("skill_id") %>">
                        <%= rs.getString("skill_name") %>
                    </option>
            <%
                }

            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            }
            %>

            </select>

    </div>

    <!-- Subskills -->
<div class="form-group">
    <label>Subskills *</label>

    <div class="multi-select">

        <!-- Visible box -->
        <div class="select-box" onclick="toggleSubskill()">
            <span id="subskillText">Select Subskills</span>
        </div>

        <!-- Dropdown -->
        <div id="subskillDropdown" class="dropdown">

            <div id="subskillOptions">
                Select skill first
            </div>

            <button type="button"
                    class="ok-btn"
                    onclick="closeSubskill()">
                OK
            </button>

        </div>

    </div>

    <span style="color:red;">
        ${subskillError}
    </span>
</div>
    <!-- Zip -->
    <div class="form-group">
        <label>Zip *</label>
        <input type="text"
               id="jzip"
               name="jzip"
               value="${param.jzip}"
               maxlength="6"
               required>
    </div>

    <!-- Country -->
    <div class="form-group">
        <label>Country *</label>
        <input type="text"
               id="jcountry"
               name="jcountry"
               readonly
               required>
    </div>

    <!-- State -->
    <div class="form-group">
        <label>State *</label>
        <input type="text"
               id="jstate"
               name="jstate"
               readonly
               required>
    </div>

    <!-- District -->
    <div class="form-group">
        <label>District (City) *</label>
        <input type="text"
               id="jdistrict"
               name="jdistrict"
               readonly
               required>
    </div>

    <!-- Area -->
    <div class="form-group">
        <label>Area *</label>
        <select id="jarea"
                name="jarea"
                required>
            <option>Select Area</option>
        </select>
    </div>

</div>
<!-- GRID END -->

<button class="register-btn">
    Create Account
</button>
<div class="form-footer">
            or<br><br>
            Already have an account? <a href="login.jsp">Sign In</a>
        </div>

</form>
</div>

<!-- ZIPCODE SCRIPT -->
<script>
    function toggleSubskill(){
    let d=document.getElementById("subskillDropdown");
    d.style.display =
        d.style.display==="block"?"none":"block";
}

function closeSubskill(){
    document.getElementById("subskillDropdown").style.display="none";
    updateText();
}

function updateText(){
    let checks =
        document.querySelectorAll(
            'input[name="subskills"]:checked'
        );

    if(checks.length===0){
        subskillText.innerText="Select Subskills";
        return;
    }

    let names=[];
    checks.forEach(c=>{
        names.push(
            c.parentElement.textContent.trim()
        );
    });

    subskillText.innerText =
        names.join(", ");
}

/* Load subskills */
function loadSubskills(){

    const skillId =
        document.getElementById("skill").value;

    const box =
        document.getElementById("subskillOptions");

    if(!skillId){
        box.innerHTML="Select skill first";
        return;
    }

    fetch("GetSubskillsServlet?skillId="+skillId)
    .then(res => res.json())
    .then(data => {

        console.log("DATA:", data);

        box.innerHTML = "";

        data.forEach(s => {

            const label =
                document.createElement("label");

            label.style.display = "block";
            label.style.color = "black";
            label.style.fontSize = "14px";

            label.innerHTML =
                '<input type="checkbox" name="subskills" value="'+s.id+'"> '
                + s.name;

            box.appendChild(label);
        });

    });
}
 
 // FIRST NAME VALIDATION
document.getElementById("jfirstname").addEventListener("input", function(){
    let value = this.value;
    let error = document.getElementById("fnameError");

    if(!/^[A-Za-z ]*$/.test(value)){
        error.innerText = "Only alphabets allowed";
        this.style.border = "2px solid red";
    } else {
        error.innerText = "";
        this.style.border = "";
    }
});

// LAST NAME VALIDATION
document.getElementById("jlastname").addEventListener("input", function(){
    let value = this.value;
    let error = document.getElementById("lnameError");

    if(!/^[A-Za-z ]*$/.test(value)){
        error.innerText = "Only alphabets allowed";
        this.style.border = "2px solid red";
    } else {
        error.innerText = "";
        this.style.border = "";
    }
});

// DOB VALIDATION (PROFESSIONAL)
document.getElementById("jdob").addEventListener("change", function(){

    let dob = new Date(this.value);
    let today = new Date();

    let age = today.getFullYear() - dob.getFullYear();
    let m = today.getMonth() - dob.getMonth();

    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
        age--;
    }

    let errorSpan = document.getElementById("dobErrorMsg");

    if(age < 18){
        errorSpan.innerText = "You must be at least 18 years old.";
        this.style.border = "2px solid red";
    } else {
        errorSpan.innerText = "";
        this.style.border = "";
    }

});

    //Zipcode
document.getElementById("jzip")
.addEventListener("keyup", function () {

    let pin = this.value;

    if (pin.length === 6) {

        fetch("https://api.postalpincode.in/pincode/" + pin)
        .then(r => r.json())
        .then(d => {

            if (d[0].Status === "Success") {

                let po = d[0].PostOffice;

                // ? GET ELEMENTS FIRST
                const district =
                    document.getElementById("jdistrict");

                const state =
                    document.getElementById("jstate");

                const country =
                    document.getElementById("jcountry");

                const area =
                    document.getElementById("jarea");

                // ? FILL VALUES
                district.value = po[0].District;
                state.value    = po[0].State;
                country.value  = po[0].Country;

                // AREA DROPDOWN
                area.innerHTML =
                    "<option>Select Area</option>";

                po.forEach(p => {

                    let opt =
                        document.createElement("option");

                    opt.value = p.Name;
                    opt.textContent = p.Name;

                    area.appendChild(opt);
                });

            } else {

                alert("Invalid Pincode");

            }

        })
        .catch(err => {
            console.log(err);
            alert("Error fetching pincode");
        });

    }

});


</script>
<script>
let emailValid = false;

function checkEmail() {
    let email = document.getElementById("jemail").value;
    let msg = document.getElementById("emailMsg");

    let emailPattern = /^[^ ]+@[^ ]+\.[a-z]{2,3}$/;

    if(email.length === 0){
        msg.innerHTML = "";
        emailValid = false;
        return;
    }

    // ❌ Invalid format
    if(!emailPattern.test(email)){
        msg.innerHTML = "Invalid email format!";
        msg.style.color = "red";
        emailValid = false;
        return;
    }

    // ✅ DB CHECK
    fetch("<%= request.getContextPath() %>/JobSeekerRegisterServlet?email=" + email)
    .then(res => res.text())
    .then(data => {
        if(data === "exists"){
            msg.innerHTML = "Email already registered!";
            msg.style.color = "red";
            emailValid = false;
        } else {
            msg.innerHTML = "✓ Email available";
            msg.style.color = "green";
            emailValid = true;
        }
    });
}

function validateForm(){
    if(!emailValid){
        alert("Please enter a valid and unique email!");
        return false;
    }
    return true;
}
</script>

</body>
</html>
