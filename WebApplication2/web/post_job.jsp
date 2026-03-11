<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ include file="header.jsp" %>
<%
/* 🔒 Prevent browser caching */
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

/* 🔒 SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("eemail") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Post Job | SkillMitra</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/post_job.css">
</head>

<body>

<header class="header">
    <div class="logo">SkillMitra</div>
    <button onclick="window.location.href='emp_dash.jsp'">← Back</button>
</header>

<div class="container">
<form class="post-job-form" action="PostJobServlet" method="post">

<h2>Post a New Job</h2>

<label>Job Title*</label>

<select id="jobSkill" name="skill_id" onchange="loadJobSubskills()" required>
<option value="">-- Select Job Title --</option>

<%
List<Map<String, Object>> skills =
(List<Map<String, Object>>) request.getAttribute("skills");

for (Map<String, Object> s : skills) {
%>

<option value="<%= s.get("id") %>"
data-name="<%= s.get("name") %>">

<%= s.get("name") %>

</option>

<% } %>

</select>

<!-- hidden title -->
<input type="hidden" name="job_title" id="jobTitle">


<label>Job Description *</label>

<textarea name="job_description"
rows="4"
maxlength="500"
required
oninput="updateCounter(this)"></textarea>

<div id="descCounter" style="font-size:12px;color:#777;">
0 / 500 characters
</div>


<!-- ZIPCODE FIRST -->

<label>Zipcode *</label>

<input type="text"
id="zipcode"
name="zip"
maxlength="6"
required>


<div class="row">

<div>

<label>Country *</label>

<input type="text"
id="country"
name="job_country"
readonly
required>

</div>

<div>

<label>State *</label>

<input type="text"
id="state"
name="job_state"
readonly
required>

</div>

</div>


<div class="row">

<div>

<label>District / City *</label>

<input type="text"
id="district"
name="job_city"
readonly
required>

</div>

<div>

<label>Locality / Area *</label>

<select id="area"
name="job_location"
required>

<option value="">Select area</option>

</select>

</div>

</div>


<div class="row">

<div>

<label>Daily Wage (₹) *</label>

<input type="number" name="wage" required>

</div>

<div>

<label>Max Salary (optional)</label>

<input type="number" name="max_salary">

</div>

</div>


<label>Job Type *</label>

<select name="job_type" required>

<option value="">Select</option>
<option>Full-Time</option>
<option>Part-Time</option>
<option>Daily</option>
<option>Contract</option>

</select>




<label>Required Subskills *</label>

<div class="multi-select">

    <!-- visible box -->
    <div class="select-box" onclick="toggleSubskills()">
        <span id="subskillText">Select Subskills</span>
    </div>

    <!-- dropdown -->
    <div id="subskillDropdown" class="dropdown">
        <div id="subskillOptions"></div>

        <button type="button"
                class="ok-btn"
                onclick="closeSubskills()">
            OK
        </button>
    </div>

</div>

<input type="hidden" name="selectedSubskills" id="selectedSubskills">


<script>

let selectedSubskills = [];

function toggleSubskills(){
    let d = document.getElementById("subskillDropdown");

    d.style.display =
        d.style.display === "block" ? "none" : "block";
}

function closeSubskills(){
    document.getElementById("subskillDropdown").style.display="none";
    updateSubskillText();
}

function updateSubskillText(){

    let checks =
        document.querySelectorAll(
            '#subskillOptions input[type="checkbox"]:checked'
        );

    let text =
        document.getElementById("subskillText");

    if(checks.length === 0){
        text.innerText = "Select Subskills";
        return;
    }

    let names = [];

    checks.forEach(c=>{
        names.push(c.parentElement.textContent.trim());
    });

    text.innerText = names.join(", ");

    let values = [];

    checks.forEach(c=>{
        values.push(c.value);
    });

    document.getElementById("selectedSubskills").value =
        values.join(",");
}
</script>


<label>Experience Required *</label>

<select name="experience_required" required>

<option value="">Select</option>
<option>Fresher</option>
<option>0-1 Years</option>
<option>1-3 Years</option>
<option>3+ Years</option>

</select>


<div class="form-group">
    <label>Languages Preferred</label>

    <div class="multi-select">

        <!-- Visible Box -->
        <div class="select-box" onclick="toggleLanguage()">
            <span id="languageText">Select Languages</span>
        </div>

        <!-- Dropdown -->
        <div id="languageDropdown" class="dropdown">

            <label>
                <input type="checkbox" name="languages_preferred" value="Hindi">
                Hindi
            </label>

            <label>
                <input type="checkbox" name="languages_preferred" value="English">
                English
            </label>

            <label>
                <input type="checkbox" name="languages_preferred" value="Bhojpuri">
                Bhojpuri
            </label>

            <label>
                <input type="checkbox" name="languages_preferred" value="Bengali">
                Bengali
            </label>

            <label>
                <input type="checkbox" name="languages_preferred" value="Marathi">
                Marathi
            </label>

            <label>
                <input type="checkbox" name="languages_preferred" value="Tamil">
                Tamil
            </label>

            <button type="button"
                    class="ok-btn"
                    onclick="closeLanguage()">
                OK
            </button>

        </div>

    </div>
</div>


<label>Number of Workers Required *</label>

<input type="number" name="workers_required" required>


<label>Working Hours *</label>

<input type="text"
name="working_hours"
placeholder="9 AM - 6 PM"
required>


<label>Gender Preference</label>

<select name="gender_preference">

<option value="">No Preference</option>
<option>Male</option>
<option>Female</option>
<option>Other</option>

</select>


<label>Expiry Date *</label>

<input type="date" name="expiry_date" required>


<button type="submit">Post Job</button>

</form>

</div>


<script>
function toggleLanguage(){
    let d = document.getElementById("languageDropdown");

    d.style.display =
        d.style.display === "block" ? "none" : "block";
}

function closeLanguage(){
    document.getElementById("languageDropdown").style.display="none";
    updateLanguageText();
}

function updateLanguageText(){

    let checks =
        document.querySelectorAll(
            'input[name="languages_preferred"]:checked'
        );

    let text =
        document.getElementById("languageText");

    if(checks.length === 0){
        text.innerText = "Select Languages";
        return;
    }

    let names = [];

    checks.forEach(c=>{
        names.push(
            c.parentElement.textContent.trim()
        );
    });

    text.innerText = names.join(", ");
}
function loadJobSubskills() {

const skillSelect = document.getElementById("jobSkill");
const skillId = skillSelect.value;

if (!skillId) return;

const skillName =
skillSelect.options[skillSelect.selectedIndex].dataset.name;

document.getElementById("jobTitle").value = skillName;

fetch("<%= request.getContextPath() %>/GetSubskillsServlet?skillId=" + skillId)

.then(res => res.json())

.then(data => {

const container =
document.getElementById("subskillOptions");

container.innerHTML = "";

data.forEach(s => {

const label = document.createElement("label");

label.innerHTML =
'<input type="checkbox" value="'+s.id+'" onchange="updateSubskillText()"> '
+ s.name;

container.appendChild(label);

});

});

}


function updateCounter(el) {

const count = el.value.length;

document.getElementById("descCounter").innerText =
count + " / 500 characters";

}



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

if (data[0].Status === "Success") {

let po = data[0].PostOffice;

district.value = po[0].District;

state.value = po[0].State;

country.value = po[0].Country;

areaSelect.innerHTML = "";

po.forEach(p => {

let opt = document.createElement("option");

opt.value = p.Name;

opt.textContent = p.Name;

areaSelect.appendChild(opt);

});

}

else {

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

</script>


</body>
</html>