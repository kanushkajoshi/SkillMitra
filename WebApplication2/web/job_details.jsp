<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // 🔐 Session Check
  
if (session.getAttribute("jobseekerId") == null) {
    response.sendRedirect("login.jsp");
    return;
}




    int jobId = Integer.parseInt(request.getParameter("jobId"));

    Connection con = DBConnection.getConnection();

    String query = "SELECT * FROM jobs WHERE job_id=?";
    PreparedStatement ps = con.prepareStatement(query);
    ps.setInt(1, jobId);

    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
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

    <br>

    <form action="ApplyJobServlet" method="post">
        <input type="hidden" name="jobId" value="<%= jobId %>">
        <button type="submit" class="apply-btn">
            Apply Now
        </button>
    </form>

    <a href="jobseeker_dash.jsp" class="back-link">
        ← Back to Jobs
    </a>

</div>
</div>

</body>
</html>


<%
    } else {
        out.println("Job not found.");
    }

    con.close();
%>

       