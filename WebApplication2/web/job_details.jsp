<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="header.jsp" %>

<%

/* 🔒 Prevent browser caching */
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

/* 🔒 SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("jobseekerId") == null) {
    response.sendRedirect("login.jsp");
    return;
}

int jobseekerId = (Integer) currentSession.getAttribute("jobseekerId");
int jobId = Integer.parseInt(request.getParameter("jobId"));

Connection con = DBConnection.getConnection();

/* 🔹 Check if already placed bid */
String checkBid = "SELECT bid_status,bid_amount FROM bids WHERE job_id=? AND job_seeker_id=?";
PreparedStatement psCheck = con.prepareStatement(checkBid);
psCheck.setInt(1, jobId);
psCheck.setInt(2, jobseekerId);
ResultSet rsCheck = psCheck.executeQuery();

boolean alreadyBid = false;
String bidStatus = "";
int bidAmount = 0;

if(rsCheck.next()){
    alreadyBid = true;
    bidStatus = rsCheck.getString("bid_status");
    bidAmount = rsCheck.getInt("bid_amount");
}

/* 🔹 Fetch Job Details */
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

    <div class="nav-left">
        SkillMitra
    </div>

    <div class="nav-right">
        <a href="jobseeker_dash.jsp?section=applied" class="back-btn">
            ← Back
        </a>
    </div>

</div>

<div class="details-container">

<div class="job-details-card">

<%
if (rs.next()) {
%>

<div class="job-header">

    <div>
        <h2 class="job-title"><%= rs.getString("title") %></h2>
        <p class="job-location">
            📍 <%= rs.getString("locality") %>, <%= rs.getString("city") %>
        </p>
    </div>

    <div class="salary">
        ₹<%= rs.getString("salary") %>
    </div>

</div>

<div class="job-grid">

    <div class="job-box">
        <span>Description</span>
        <p><%= rs.getString("description") != null ? rs.getString("description") : "No description provided." %></p>
    </div>

    <div class="job-box">
        <span>Job Type</span>
        <p><%= rs.getString("job_type") %></p>
    </div>
      
    <div class="job-box">
    <span>Location</span>
    <p>
        <%= rs.getString("locality") %>, 
        <%= rs.getString("city") %>, 
        <%= rs.getString("state") %>, 
        <%= rs.getString("country") %> - 
        <%= rs.getString("zip") %>
    </p>
    </div>
    <div class="job-box">
        <span>Experience Level</span>
        <p><%= rs.getString("experience_level") != null ? rs.getString("experience_level") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Experience Required</span>
        <p><%= rs.getString("experience_required") != null ? rs.getString("experience_required") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Workers Required</span>
        <p><%= rs.getString("workers_required") != null ? rs.getString("workers_required") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Working Hours</span>
        <p><%= rs.getString("working_hours") != null ? rs.getString("working_hours") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Gender Preference</span>
        <p><%= rs.getString("gender_preference") != null ? rs.getString("gender_preference") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Languages</span>
        <p><%= rs.getString("languages_preferred") != null ? rs.getString("languages_preferred") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Maximum Salary</span>
        <p>₹<%= rs.getString("min_salary") != null ? rs.getString("min_salary") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Expiry Date</span>
        <p><%= rs.getString("expiry_date") != null ? rs.getString("expiry_date") : "Not specified" %></p>
    </div>

    <div class="job-box">
        <span>Posted On</span>
        <p><%= rs.getString("created_at") %></p>
    </div>

</div>
<br>

<div class="job-actions">

<!-- DIRECT APPLY -->

<form action="ApplyJobServlet" method="post" style="margin-bottom:15px;">

<input type="hidden" name="jobId" value="<%= jobId %>">

<button type="submit" class="apply-btn" style="background:#28a745;">
Apply Now
</button>

</form>


<!--<hr style="margin:20px 0 -->


<!-- BID SYSTEM -->

<% if(alreadyBid){ %>

<button class="apply-btn" disabled style="background:#cccccc;">
✓ <%= bidStatus %>
</button>

<p style="color:green;margin-top:10px;">
You placed a bid of ₹<%= bidAmount %>
</p>

<% } else { %>

<form action="PlaceBidServlet" method="post">

<input type="hidden" name="jobId" value="<%= jobId %>">

<label style="font-weight:bold;">Place Your Bid (₹)</label>

<input type="number" name="bidAmount" required
style="width:100%;padding:10px;margin-top:8px;margin-bottom:12px;">

<button type="submit" class="apply-btn">
Place Bid
</button>

</form>

<% } %>

</div>



<%
} else {
out.println("Job not found.");
}
%>

</div>
</div>

</body>
</html>

<%

rsCheck.close();
psCheck.close();
rs.close();
ps.close();
con.close();

%>