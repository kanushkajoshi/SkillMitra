<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="db.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
       <button class="back-btn" onclick="window.location.href='home.jsp'">Back to Home</button>

    </header>

    <div class="container">
    <form class="register-form" method="post"
      action="<%= request.getContextPath() %>/JobSeekerRegisterServlet">


    <h1>Register as Job Seeker</h1>

    <div class="form-grid">

        <div class="form-group">
            <label for="jfirstname">First Name *</label>
            <input type="text"
                   id="jfirstname"
                   name="jfirstname"
                   placeholder="Enter your first name"
                   required>
        </div>

        <div class="form-group">
            <label for="jlastname">Last Name *</label>
            <input type="text"
                   id="jlastname"
                   name="jlastname"
                   placeholder="Enter your last name"
                   required>
        </div>

        <div class="form-group">
            <label for="jphone">Phone Number *</label>
            <input type="tel"
                   id="jphone"
                   name="jphone"
                   value="${param.jphone}"
                   pattern="[6-9][0-9]{9}"
                   title="Enter a valid 10-digit Indian mobile number"
                   required>
            <span style="color:red;">${phoneError}</span>
        </div>

        <div class="form-group">
            <label for="jemail">Email ID *</label>
            <input type="email"
                   id="jemail"
                   name="jemail"
                   value="${param.jemail}"
                   autocomplete="off"
                   required>
            <span class="error-msg">${emailError}</span>
        </div>

        <div class="form-group">
            <label for="jpwd">Password *</label>
            <div class="password-container">
                <input type="password"
                       id="jpwd"
                       name="jpwd"
                       autocomplete="new-password"
                       pattern="(?=.*[A-Za-z])(?=.*[0-9]).{6,}"
                       title="Password must contain letters and numbers (min 6 characters)"
                       required>
                <i class="fa-regular fa-eye password-toggle"
                   onclick="togglePassword()"></i>
            </div>
            <span style="color:red;">${passwordError}</span>
        </div>
        <div class="form-group">
            <label for="jeducation">Highest Education Level *</label>
            <select id="jeducation" name="jeducation" required>
                <option value="">-- Select Education --</option>
                <option value="No formal education">No formal education</option>
                <option value="Primary (up to 5th)">Primary (up to 5th)</option>
                <option value="Secondary (10th pass)">Secondary (10th pass)</option>
                <option value="Higher Secondary (12th pass)">Higher Secondary (12th pass)</option>
                <option value="ITI">ITI</option>
                <option value="Diploma">Diploma</option>
                <option value="Graduate">Graduate</option>
            </select>
        </div>

        <div class="form-group">
    <label for="jdob">Date of Birth *</label>
    <input type="date"
           id="jdob"
           name="jdob"
           required>
</div>

        <div class="form-group">
    <label for="skill">Skill *</label>

    <select id="skill" name="skill" onchange="loadSubskills()" required>
    <option value="">-- Select Skill --</option>

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

        <div class="form-group">
            <label for="subskill">Subskill *</label>
            <select id="subskill" name="subskill" required>
                <option value="">-- Select Subskill --</option>
            </select>
        </div>



        <div class="form-group">
            <label for="jcountry">Country *</label>
            <input type="text"
                   id="jcountry"
                   name="jcountry"
                   placeholder="Enter your country"
                   required>
        </div>

        <div class="form-group">
            <label for="jstate">State *</label>
            <input type="text"
                   id="jstate"
                   name="jstate"
                   placeholder="Enter your state"
                   required>
        </div>

        <div class="form-group">
            <label for="jcity">City *</label>
            <input type="text"
                   id="jcity"
                   name="jcity"
                   placeholder="Enter your city"
                   required>
        </div>

        <div class="form-group">
            <label for="jzip">Zipcode *</label>
            <input type="text"
                   id="jzip"
                   name="jzip"
                   placeholder="Enter zipcode"
                   required>
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
    function filterSkills() {
    const input = document.getElementById("skillSearch").value.toLowerCase();
    const select = document.getElementById("skill");
    const options = select.options;

    for (let i = 1; i < options.length; i++) { // skip first option
        const text = options[i].text.toLowerCase();
        options[i].style.display = text.includes(input) ? "" : "none";
    }
}
function loadSubskills() {
    const skillId = document.getElementById("skill").value;
    const sub = document.getElementById("subskill");

    sub.innerHTML = '<option value="">-- Select Subskill --</option>';
    if (!skillId) return;

    fetch("<%= request.getContextPath() %>/GetSubskillsServlet?skillId="
        + encodeURIComponent(skillId))
        .then(res => res.json())
        .then(data => {
            data.forEach(s => {
                let opt = document.createElement("option");
                opt.value = s.id;
                opt.textContent = s.name;
                sub.appendChild(opt);
            });
        })
        .catch(err => console.error(err));
}


</script>

</body>
</html>
