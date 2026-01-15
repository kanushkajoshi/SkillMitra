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
<select id="jobSkill" name="jobSkill" onchange="loadJobSubskills()" required>
    <option value="">-- Select Skill --</option>

    <%
        List<String> skills = (List<String>) request.getAttribute("skills");
        if (skills != null) {
            for (String s : skills) {
    %>
        <option value="<%= s %>"><%= s %></option>
    <%
            }
        }
    %>
</select>


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
    const skill = document.getElementById("jobSkill").value;
    const sub = document.getElementById("jobSubskill");

    sub.innerHTML = '<option value="">-- Select Subskill --</option>';
    if (!skill) return;

    fetch("<%= request.getContextPath() %>/GetSubskillsServlet?skill="
        + encodeURIComponent(skill))
        .then(res => res.json())
        .then(data => {
            data.forEach(s => {
                let opt = document.createElement("option");
                opt.value = s;
                opt.textContent = s;
                sub.appendChild(opt);
            });
        })
        .catch(err => console.error(err));
}
</script>

</body>
</html>
