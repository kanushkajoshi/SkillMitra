<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html>
<head>
    <title>Post Job | SkillMitra</title>
    <link rel="stylesheet" href="post_job.css">
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
    <option value="">-- Select Skill --</option>

    <%
        List<Map<String, Object>> skills =
            (List<Map<String, Object>>) request.getAttribute("skills");

        for (Map<String, Object> s : skills) {
    %>
        <option 
            value="<%= s.get("id") %>" 
            data-name="<%= s.get("name") %>">
            <%= s.get("name") %>
        </option>
    <%
        }
    %>
</select>

<!-- ✅ Hidden field that will store job title -->
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


        <label>Locality / Area *</label>
        <input type="text" name="job_location" required>

        <div class="row">
            <div>
                <label>City *</label>
                <input type="text" name="job_city" required>
            </div>
            <div>
                <label>State *</label>
                <input type="text" name="job_state" required>
            </div>
        </div>

        <div class="row">
            <div>
                <label>Country *</label>
                <input type="text" name="job_country" required>
            </div>
            <div>
                <label>Zip *</label>
                <input type="text" name="zip" required>
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

<select id="subskillSelect" onchange="addSubskill(this)">
    <option value="">-- Select Subskill --</option>
</select>

<div id="selectedSkills" class="selected-skills"></div>

<input type="hidden" name="selectedSubskills" id="selectedSubskills">
<script>
    let selectedSubskills = [];

function addSubskill(select) {
    const id = select.value;
    const name = select.options[select.selectedIndex].text;

    if (!id) return;

    if (selectedSubskills.includes(id)) {
        alert("Already added");
        return;
    }

    selectedSubskills.push(id);

    renderSkills();

    select.value = "";
}

function removeSkill(id) {
    selectedSubskills = selectedSubskills.filter(s => s !== id);
    renderSkills();
}

function renderSkills() {
    const container = document.getElementById("selectedSkills");
    container.innerHTML = "";

    selectedSubskills.forEach(id => {

        const option = document.querySelector(
            '#subskillSelect option[value="' + id + '"]'
        );

        const tag = document.createElement("div");
        tag.className = "skill-tag";
        tag.innerHTML = option.text +
            ' <span onclick="removeSkill(\'' + id + '\')">✖</span>';

        container.appendChild(tag);
    });

    document.getElementById("selectedSubskills").value =
        selectedSubskills.join(",");
}

    </script>
        
<!--        NEW CODE-->
        <label>Experience Required *</label>
<select name="experience_required" required>
    <option value="">Select</option>
    <option>Fresher</option>
    <option>0-1 Years</option>
    <option>1-3 Years</option>
    <option>3+ Years</option>
</select>
<label>Languages Preferred</label>

<div class="checkbox-group">
    <label><input type="checkbox" name="languages_preferred" value="Hindi"> Hindi</label>
    <label><input type="checkbox" name="languages_preferred" value="English"> English</label>
    <label><input type="checkbox" name="languages_preferred" value="Bhojpuri"> Bhojpuri</label>
    <label><input type="checkbox" name="languages_preferred" value="Bengali"> Bengali</label>
    <label><input type="checkbox" name="languages_preferred" value="Marathi"> Marathi</label>
    <label><input type="checkbox" name="languages_preferred" value="Tamil"> Tamil</label>
</div>



<label>Number of Workers Required *</label>
<input type="number" name="workers_required" required>

<label>Working Hours *</label>
<input type="text" name="working_hours" placeholder="9 AM - 6 PM" required>

<label>Gender Preference</label>
<select name="gender_preference">
    <option value="">No Preference</option>
    <option>Male</option>
    <option>Female</option>
</select>

<label>Expiry Date *</label>
<input type="date" name="expiry_date" required>



        <button type="submit">Post Job</button>

    </form>
</div>
<script>
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

            const sub = document.getElementById("subskillSelect"); // ✅ CORRECT ID
            sub.innerHTML = '<option value="">-- Select Subskill --</option>';

            data.forEach(s => {
                const opt = document.createElement("option");
                opt.value = s.id;
                opt.textContent = s.name;
                sub.appendChild(opt);
            });
        });
}

function updateCounter(el) {
    const count = el.value.length;
    document.getElementById("descCounter").innerText =
        count + " / 500 characters";
}

</script>


</body>
</html>
