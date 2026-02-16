<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="db.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

<!-- Error Messages -->
<% if (request.getAttribute("emailError") != null) { %>
    <p style="color:red;text-align:center;">
        <%= request.getAttribute("emailError") %>
    </p>
<% } %>

<% if (request.getAttribute("dobError") != null) { %>
    <p style="color:red;text-align:center;">
        <%= request.getAttribute("dobError") %>
    </p>
<% } %>

<div class="container">

<form class="register-form"
      method="post"
      action="<%= request.getContextPath() %>/JobSeekerRegisterServlet">
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
               name="jfirstname"
               value="${param.jfirstname}"
               required>
    </div>

    <!-- Last Name -->
    <div class="form-group">
        <label>Last Name *</label>
        <input type="text"
               name="jlastname"
               value="${param.jlastname}"
               required>
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

    <!-- Email -->
    <div class="form-group">
        <label>Email *</label>
        <input type="email"
               name="jemail"
               value="${param.jemail}"
               required>
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

            <option value="Graduate"
                ${param.jeducation=="Graduate"?"selected":""}>
                Graduate
            </option>

            <option value="Diploma"
                ${param.jeducation=="Diploma"?"selected":""}>
                Diploma
            </option>

            <option value="ITI"
                ${param.jeducation=="ITI"?"selected":""}>
                ITI
            </option>
        </select>
    </div>

    <!-- DOB -->
    <div class="form-group">
        <label>DOB *</label>
        <input type="date"
               name="jdob"
               value="${param.jdob}"
               required>
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

</body>
</html>
