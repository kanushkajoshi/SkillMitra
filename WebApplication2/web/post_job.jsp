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
        <textarea name="job_description" rows="4" required></textarea>

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

        <label>Required skills *</label>
<select id="jobSubskill" name="jobSubskill" required>
    <option value="">-- Select Subskill --</option>
</select>


        <button type="submit">Post Job</button>

    </form>
</div>
<script>
function loadJobSubskills() {
    const skillSelect = document.getElementById("jobSkill");
    const skillId = skillSelect.value;

    console.log("Selected skillId =", skillId);

    if (!skillId) return;

    // set job title
    const skillName =
        skillSelect.options[skillSelect.selectedIndex].dataset.name;
    document.getElementById("jobTitle").value = skillName;

    const sub = document.getElementById("jobSubskill");
    sub.innerHTML = '<option value="">-- Select Subskill --</option>';

    fetch("<%= request.getContextPath() %>/GetSubskillsServlet?skillId=" + skillId)
        .then(res => res.json())
        .then(data => {
            console.log("Subskills:", data);
            data.forEach(s => {
                const opt = document.createElement("option");
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
