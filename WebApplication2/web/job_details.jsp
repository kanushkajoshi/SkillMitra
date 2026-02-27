<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // 🔐 Session Check
    if (session.getAttribute("jobseekerId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int jobseekerId = (Integer) session.getAttribute("jobseekerId");
    int jobId = Integer.parseInt(request.getParameter("jobId"));

    Connection con = DBConnection.getConnection();

    // 🔹 Check if already applied
    String checkApplied = "SELECT status FROM applications WHERE job_id=? AND jobseeker_id=?";
    PreparedStatement psCheck = con.prepareStatement(checkApplied);
    psCheck.setInt(1, jobId);
    psCheck.setInt(2, jobseekerId);
    ResultSet rsCheck = psCheck.executeQuery();

    boolean alreadyApplied = false;
    String applicationStatus = "";

    if(rsCheck.next()){
        alreadyApplied = true;
        applicationStatus = rsCheck.getString("status");
    }

    // 🔹 Fetch Job Details
    String query = "SELECT * FROM jobs WHERE job_id=?";
    PreparedStatement ps = con.prepareStatement(query);
    ps.setInt(1, jobId);
    ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Job Details | SkillMitra</title>
    <link rel="stylesheet" href="job_details.css">
</head>

<body>

<div class="navbar">
    SkillMitra
</div>

<div class="details-container">

<div class="job-details-card">

<%
if (rs.next()) {
%>

    <div class="job-title">
        <%= rs.getString("title") %>
    </div>

    <div class="salary">
        ₹<%= rs.getString("salary") %>
    </div>

    <div class="section">
        <span class="label">Description:</span><br>
        <%= rs.getString("description") != null ? rs.getString("description") : "No description provided." %>
    </div>

    <div class="section">
        <span class="label">Location:</span><br>
        <%= rs.getString("locality") %>,
        <%= rs.getString("city") %>,
        <%= rs.getString("state") %>,
        <%= rs.getString("country") %> -
        <%= rs.getString("zip") %>
    </div>

    <div class="section">
        <span class="label">Job Type:</span>
        <%= rs.getString("job_type") %>
    </div>

    <div class="section">
        <span class="label">Experience Level:</span>
        <%= rs.getString("experience_level") != null ? rs.getString("experience_level") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Experience Required:</span>
        <%= rs.getString("experience_required") != null ? rs.getString("experience_required") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Workers Required:</span>
        <%= rs.getString("workers_required") != null ? rs.getString("workers_required") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Working Hours:</span>
        <%= rs.getString("working_hours") != null ? rs.getString("working_hours") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Gender Preference:</span>
        <%= rs.getString("gender_preference") != null ? rs.getString("gender_preference") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Languages Preferred:</span>
        <%= rs.getString("languages_preferred") != null ? rs.getString("languages_preferred") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Minimum Salary:</span>
        ₹<%= rs.getString("min_salary") != null ? rs.getString("min_salary") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Expiry Date:</span>
        <%= rs.getString("expiry_date") != null ? rs.getString("expiry_date") : "Not specified" %>
    </div>

    <div class="section">
        <span class="label">Posted On:</span>
        <%= rs.getString("created_at") %>
    </div>

    <br>

    <!-- 🔥 Apply Button Section -->
    <% if(alreadyApplied){ %>
        <button class="apply-btn" disabled style="background:#cccccc;">
            ✓ <%= applicationStatus %>
        </button>
        <p style="color:green;margin-top:10px;">
            You have already applied for this job.
        </p>
    <% } else { %>
        <form action="ApplyJobServlet" method="post">
            <input type="hidden" name="jobId" value="<%= jobId %>">
            <button type="submit" class="apply-btn">
                Apply Now
            </button>
        </form>
    <% } %>

    <a href="jobseeker_dash.jsp?section=applied" class="back-link">
        ← Back to Applied Jobs
    </a>

<%
} else {
    out.println("Job not found.");
}
%>

</div> <!-- job-details-card -->
</div> <!-- details-container -->

</body>
</html>

<%
    // 🔹 Close Resources
    rsCheck.close();
    psCheck.close();
    rs.close();
    ps.close();
    con.close();
%>