<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
<title>Post Application | SkillMitra</title>
<link rel="stylesheet" href="post_job.css">
</head>

<body>

<header class="header">
    <div class="logo">SkillMitra</div>
    <button onclick="window.location.href='jobseeker_dash.jsp'">Back</button>
</header>

<div class="container">
<form class="post-job-form" action="PostApplicationServlet" method="post">

<h2>Post Application</h2>

<label>Select Job*</label>
<select name="job_id" required>
<option value="">Select Job</option>

<%
List<Map<String,Object>> jobs = (List<Map<String,Object>>)request.getAttribute("jobs");
for(Map<String,Object> j: jobs){
%>
<option value="<%= j.get("id") %>"><%= j.get("title") %></option>
<% } %>
</select>

<label>Write why you are suitable *</label>
<textarea name="message" rows="4" required></textarea>

<button type="submit">Submit Application</button>

</form>
</div>

</body>
</html>
