<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%
    // 🔐 Prevent browser cache (Back button protection)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 🔐 Check if employer is logged in
   HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("eid") == null) {
    response.sendRedirect("login.jsp");
    return;
}


//String email = (String) currentSession.getAttribute("eemail");

%>


<%
//String email = (String) session.getAttribute("eemail");

try {
    
    Connection con = DBConnection.getConnection();

   Integer employerId = (Integer) currentSession.getAttribute("eid");

PreparedStatement ps = con.prepareStatement(
    "SELECT efirstname, elastname, ecompanyname FROM employer WHERE eid = ?");
ps.setInt(1, employerId);


    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        currentSession.setAttribute("efirstname", rs.getString("efirstname"));
        currentSession.setAttribute("elastname", rs.getString("elastname"));
        currentSession.setAttribute("ecompanyname", rs.getString("ecompanyname"));
    }
    con.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

<%
    String successMsg = (String) currentSession.getAttribute("jobSuccess");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Employer Dashboard | SkillMitra</title>
    <link rel="stylesheet" href="emp_dash.css">
    
    <style>
.section-container{
max-width:950px;
margin:auto;
}

.job-group{
border:1px solid #e6e6e6;
border-radius:10px;
padding:20px;
margin-top:25px;
background:#fff;
box-shadow:0 2px 6px rgba(0,0,0,0.05);
}

.applications-list{
display:flex;
flex-direction:column;
gap:15px;
}

.review-card{
display:flex;
justify-content:space-between;
align-items:center;
border:1px solid #eee;
padding:15px;
border-radius:8px;
background:#fafafa;
}

.worker-details h4{
margin:0;
font-size:17px;
}

.worker-details p{
margin:3px 0;
color:#666;
font-size:14px;
}

.meta{
font-size:13px;
color:#777;
margin-top:4px;
}

.actions{
display:flex;
gap:10px;
}

.accept-btn{
background:#22c55e;
color:white;
padding:7px 14px;
border-radius:6px;
text-decoration:none;
}

.reject-btn{
background:#ef4444;
color:white;
padding:7px 14px;
border-radius:6px;
text-decoration:none;
}

.counter-btn{
background:#ff9800;
color:white;
border:none;
padding:6px 10px;
border-radius:5px;
}

.empty-msg{
color:#777;
font-size:14px;
margin-top:10px;
}
</style>

</head>



<body>
<%
if (successMsg != null) {
%>
<div id="successModal" class="modal-overlay">
    <div class="modal-box">
        <span class="close-btn" onclick="closeModal()">&times;</span>
        <h2>✅ Success</h2>
        <p><%= successMsg %></p>
    </div>
</div>
<%
    currentSession.removeAttribute("jobSuccess");
}
%>

<header>
    <div class="logo">SkillMitra</div>
    

   
    <div class="profile-dropdown">
        <%
String photo = (String) currentSession.getAttribute("ephoto");

String imgPath;

if(photo != null && !photo.trim().isEmpty()){
    imgPath = "uploads/" + photo;
}else{
    imgPath = "images/default-user.png";
}
%>

<img src="<%= imgPath %>" class="profile-icon" id="profileIcon">
        <div class="profile-menu" id="profileMenu">
            <div class="profile-name" style="background:none; color:#000; font-weight:600; border-bottom:none;">
                <%
    String fname = (String) currentSession.getAttribute("efirstname");
    String lname = (String) currentSession.getAttribute("elastname");
%>

<%= fname != null ? fname : "" %> <%= lname != null ? lname : "" %>

            </div>
            <a href="employer_profile.jsp">View Profile</a>
            <a href="LogoutServlet">Logout</a>
        </div>
    </div>
</header>

<div class="dashboard">
    <aside class="sidebar">
    <h2>Employer Dashboard</h2>
    <a class="active" href="#" onclick="showSection('dashboard')">Dashboard</a>
    <a href="#" onclick="showSection('manageJobs')">Manage Jobs</a>
    <a href="#" onclick="showSection('reviewApplications')">Review Applications</a>
    <a href="#" onclick="showSection('acceptedApplications')">Accepted Applications</a>
    <a href="#" onclick="showSection('rejectedApplications')">Rejected Applications</a>
    <a href="#" onclick="showSection('payments')">Payments</a>
    <a href="#">Rate & Review</a>
</aside>

    <main class="content">

     
 <div class="topbar">
        <div>
    Welcome,
    <b><%= currentSession.getAttribute("efirstname") %>
    <%= currentSession.getAttribute("elastname") %></b>
</div>

       
    </div>

        <div class="top-search">
            <input type="text" placeholder="Search workers by skill or location">
        </div>

        <!-- DASHBOARD SECTION -->
        <div id="dashboardSection">
            <div class="dashboard-header">
                <h2>Dashboard Overview</h2>
                <p>Welcome back! Here's what's happening.</p>
            </div>

            <div class="stats-cards">
                <div class="stats-card">
                    <span class="title">Active Jobs</span>
                    <span class="number">12</span>
                    <span class="change">+2 this week</span>
                </div>
                <div class="stats-card">
                    <span class="title">Total Applications</span>
                    <span class="number">48</span>
                    <span class="change">+12 this week</span>
                </div>
                <div class="stats-card">
                    <span class="title">Hired</span>
                    <span class="number">8</span>
                    <span class="change">+3 this month</span>
                </div>
                <div class="stats-card">
                    <span class="title">Total Spent</span>
                    <span class="number">$12,450</span>
                    <span class="change">+15% this month</span>
                </div>
            </div>

            <div class="lower-section">
                <div class="lower-card">
                    <h3>Recent Applications</h3>
                    <table>
                        <tr><th>Worker Name</th><th>Position</th><th>Date</th></tr>
                        <tr><td>Ramesh Kumar</td><td>Electrician</td><td>12 Jan 2026</td></tr>
                        <tr><td>Sunita Devi</td><td>House Maid</td><td>13 Jan 2026</td></tr>
                        <tr><td>Ajay Singh</td><td>Plumber</td><td>14 Jan 2026</td></tr>
                    </table>
                </div>

                <div class="lower-card">
                    <h3>Active Job Posts</h3>
                    <table>
                        <tr><th>Job Title</th><th>Location</th><th>Applicants</th></tr>
                        <tr><td>Electrician</td><td>Delhi</td><td>12</td></tr>
                        <tr><td>House Maid</td><td>Noida</td><td>8</td></tr>
                        <tr><td>Plumber</td><td>Gurgaon</td><td>5</td></tr>
                    </table>
                </div>
            </div>
        </div>

<!-- MANAGE JOBS SECTION -->
<div id="manageJobsSection" style="display:none; width:100%; max-width:900px;">
    

    <div class="manage-header">
        <h2>Manage Jobs</h2>
        <a href="<%= request.getContextPath() %>/post-job">
            <button class="post-job-btn">+ Post Job</button>
        </a>
    </div>
    <div class="cards-grid">
<%
Integer employerId = (Integer) currentSession.getAttribute("eid");

if(employerId != null){

    try{


        Connection con2 = DBConnection.getConnection();

        // ✅ FIXED QUERY (Distinct + Proper Grouping)
        PreparedStatement ps2 = con2.prepareStatement(
            "SELECT j.*, " +
            "GROUP_CONCAT(DISTINCT s.subskill_name SEPARATOR ', ') AS subskills " +
            "FROM jobs j " +
            "LEFT JOIN job_skills js ON j.job_id = js.job_id " +
            "LEFT JOIN subskill s ON js.subskill_id = s.subskill_id " +
            "WHERE j.eid = ? " +
            "GROUP BY j.job_id " +
            "ORDER BY j.job_id DESC"
        );

        ps2.setInt(1, employerId);

        ResultSet rs2 = ps2.executeQuery();

        boolean hasJobs = false;

        while(rs2.next()){
            hasJobs = true;
%>

    <!-- JOB CARD -->
    <div class="job-card">
        <div class="job-details">

            <h3><%= rs2.getString("title") %></h3>

            <p><strong>Description:</strong>
                <%= rs2.getString("description") %>
            </p>

            <!-- ✅ FIXED SUBSKILLS DISPLAY -->
            <p><strong>Required Subskills:</strong>
                <%
                String subs = rs2.getString("subskills");
                if(subs != null && !subs.trim().isEmpty()){
                    out.print(subs);
                } else {
                    out.print("Not specified");
                }
                %>
            </p>

            <p><strong>Location:</strong>
                <%= rs2.getString("locality") %>,
                <%= rs2.getString("city") %>,
                <%= rs2.getString("state") %>,
                <%= rs2.getString("country") %>
            </p>

            <p><strong>Salary:</strong>
                ₹<%= rs2.getString("salary") %>
            </p>

            <p><strong>Minimum Salary:</strong>
                ₹<%= rs2.getString("min_salary") %>
            </p>

            <p><strong>Experience Required:</strong>
                <%= rs2.getString("experience_required") %>
            </p>

            <p><strong>Workers Required:</strong>
                <%= rs2.getInt("workers_required") %>
            </p>

            <p><strong>Working Hours:</strong>
                <%= rs2.getString("working_hours") %>
            </p>

            <p><strong>Gender Preference:</strong>
                <%= rs2.getString("gender_preference") %>
            </p>

            <p><strong>Expiry Date:</strong>
                <%= rs2.getDate("expiry_date") %>
            </p>
            <p><strong>Status:</strong>
<%
java.sql.Date expiry = rs2.getDate("expiry_date");
java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

String status = "ACTIVE";

if(expiry != null && expiry.before(today)){
    status = "EXPIRED";
}
String color = "#6c757d";

if("ACTIVE".equals(status)){
    color = "#28a745";
}else if("EXPIRED".equals(status)){
    color = "#dc3545";
}
%>

<span style="padding:4px 10px;border-radius:12px;font-size:13px;color:white;background:<%= color %>;">
<%= status %>
</span>

            <p><strong>Job Type:</strong>
                <%= rs2.getString("job_type") %>
            </p>

            <p><strong>Languages Preferred:</strong>
                <%= rs2.getString("languages_preferred") %>
            </p>

            <p><strong>ZIP Code:</strong>
                <%= rs2.getString("zip") %>
            </p>

            <p><strong>Posted On:</strong>
                <%
                Timestamp ts = rs2.getTimestamp("created_at");
                if(ts != null){
                    out.print(new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a")
                    .format(ts));
                }
                %>
            </p>

        </div>

        <div class="job-actions">
            <a href="EditJobServlet?job_id=<%= rs2.getInt("job_id") %>" class="edit-btn">
                Edit
            </a>

            <a href="DeleteJobServlet?job_id=<%= rs2.getInt("job_id") %>"
               class="delete-btn"
               onclick="return confirm('Are you sure you want to delete this job?');">
               Delete
            </a>
        </div>
    </div>

<%
        }

        if(!hasJobs){
%>
        <p style="margin-top:20px;">No jobs posted yet.</p>
<%
        }

        con2.close();

    } catch(Exception e){
        e.printStackTrace();
    }
}
%>

</div>
 </div>






<!-- Review Applications SECTION -->
<div id="reviewApplicationsSection" style="display:none; width:100%; max-width:900px; margin:auto;">

<div class="manage-header">
<div>
<h2>Review Applications</h2>
<p>Review applications only</p>
</div>
</div>

<%
Integer employerId2 = (Integer) currentSession.getAttribute("eid");

if(employerId2 != null){

try{



Connection con3 =DBConnection.getConnection();

PreparedStatement ps3 = con3.prepareStatement(
"SELECT j.job_id, j.title, " +
"a.application_id, a.applied_at, " +
"js.jfirstname, js.jlastname, js.jemail, js.jdistrict, js.jeducation " +
"FROM jobs j " +
"INNER JOIN applications a ON j.job_id = a.job_id " +
"INNER JOIN jobseeker js ON a.jobseeker_id = js.jid " +
"WHERE j.eid = ? AND a.status='Pending' AND a.is_bid=0 " +
"ORDER BY j.title ASC, a.applied_at DESC"
);

ps3.setInt(1, employerId2);

ResultSet rs3 = ps3.executeQuery();

/* grouping variable */

String currentJobTitle = "";
boolean hasApps = false;

while(rs3.next()){

String jobTitle = rs3.getString("title");

if(!jobTitle.equals(currentJobTitle)){

if(!currentJobTitle.equals("")){
%>
</div>
</div>
<%
}

currentJobTitle = jobTitle;
%>

<div class="job-group" style="margin-top:30px;border:1px solid #e6e6e6;padding:20px;border-radius:10px;background:#fff;box-shadow:0 2px 6px rgba(0,0,0,0.05);">

<h3 style="margin-bottom:15px;font-weight:600;color:#333;">
<%= jobTitle %>
</h3>

<div class="applications-list" style="display:flex;flex-direction:column;gap:15px;">
<%
}

if(rs3.getObject("application_id") != null){

hasApps = true;
%>

<div class="review-card" style="display:flex;justify-content:space-between;align-items:center;border:1px solid #eee;padding:15px;border-radius:8px;background:#fafafa;">

<div class="worker-details">

<h4 style="margin:0;">
<%= rs3.getString("jfirstname") %>
<%= rs3.getString("jlastname") %>
</h4>

<p style="margin:3px 0;color:#666;">
<%= rs3.getString("jemail") %>
</p>

<div style="font-size:13px;color:#777;">
<%= rs3.getString("jdistrict") %> |
<%= rs3.getString("jeducation") %>
</div>

</div>

<div class="actions" style="display:flex;gap:10px;">

<a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Accepted"
style="background:#22c55e;color:white;padding:7px 14px;border-radius:6px;text-decoration:none;">
Accept
</a>

<a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Rejected"
style="background:#ef4444;color:white;padding:7px 14px;border-radius:6px;text-decoration:none;">
Reject
</a>

</div>

</div>

<%
}

}

if(!currentJobTitle.equals("")){
%>
</div>
</div>
<%
}

if(!hasApps){
%>
<p style="color:#777;">No pending applications.</p>
<%
}

con3.close();

}catch(Exception e){
e.printStackTrace();
}

}
%>


<!-- ================= REVIEW BIDS SECTION ================= -->

<hr style="margin:50px 0;">


<div class="manage-header">
<div>
<h2>Review Bids</h2>
<p>Workers who placed bids on your jobs</p>
</div>
</div>

<%

Integer employerBidId = (Integer) currentSession.getAttribute("eid");

if(employerBidId != null){

try{



Connection conBid = DBConnection.getConnection();

PreparedStatement psBid = conBid.prepareStatement(

"SELECT j.job_id, j.title, " +
"b.bid_id, b.bid_amount, b.bid_status, b.created_at, b.counter_bid, " +
"js.jfirstname, js.jlastname, js.jemail, js.jdistrict " +

"FROM jobs j " +

"INNER JOIN bids b ON j.job_id = b.job_id " +

"INNER JOIN jobseeker js ON b.job_seeker_id = js.jid " +

"WHERE j.eid = ? AND (b.bid_status='Pending' OR b.bid_status='Countered' OR b.bid_status='Rejected') " +

"ORDER BY j.title ASC, b.bid_amount ASC"

);

psBid.setInt(1, employerBidId);

ResultSet rsBid = psBid.executeQuery();

String currentBidJobTitle = "";
boolean hasBidsOverall = false;

while(rsBid.next()){

String jobTitle = rsBid.getString("title");

if(!jobTitle.equals(currentBidJobTitle)){

if(!currentBidJobTitle.equals("")){
%>
</div>
</div>
<%
}

currentBidJobTitle = jobTitle;
hasBidsOverall = true;
%>

<div class="job-group" style="margin-top:30px;border:1px solid #e6e6e6;padding:20px;border-radius:10px;background:#fff;box-shadow:0 2px 6px rgba(0,0,0,0.05);">

<h3 style="margin-bottom:15px;font-weight:600;color:#333;">
<%= jobTitle %>
</h3>

<div class="applications-list" style="display:flex;flex-direction:column;gap:15px;">

<%
}

if(rsBid.getInt("bid_id") != 0){
%>

<div class="review-card" style="display:flex;justify-content:space-between;align-items:center;border:1px solid #eee;padding:15px;border-radius:8px;background:#fafafa;">

<div>

<h4>
<%= rsBid.getString("jfirstname") %>
<%= rsBid.getString("jlastname") %>
</h4>

<p style="margin:3px 0;color:#666;">
<%= rsBid.getString("jemail") %>
</p>

<div style="font-size:13px;color:#777;">
Bid: ₹<%= rsBid.getInt("bid_amount") %>

<% if(rsBid.getInt("counter_bid") > 0){ %>
 | Countered: ₹<%= rsBid.getInt("counter_bid") %>
<% } %>

 | <%= rsBid.getString("jdistrict") %>
</div>

</div>


<div>

<a href="RespondCounterServlet?bid_id=<%= rsBid.getInt("bid_id") %>&action=accept"
style="background:#22c55e;color:white;padding:7px 14px;border-radius:6px;text-decoration:none;">
Accept
</a>

<a href="RespondCounterServlet?bid_id=<%= rsBid.getInt("bid_id") %>&action=reject"
style="background:#ef4444;color:white;padding:7px 14px;border-radius:6px;text-decoration:none;">
Reject
</a>


<form action="CounterBidServlet" method="post" style="margin-top:10px;display:flex;gap:8px;">

<input type="hidden" name="bid_id" value="<%= rsBid.getInt("bid_id") %>">

<input type="number" name="counter_amount" placeholder="Counter bid" required style="padding:6px;width:140px;">

<button type="submit" style="background:#ff9800;color:white;border:none;padding:6px 10px;border-radius:5px;">
Counter
</button>

</form>

</div>

</div>

<%
}

}

if(!currentBidJobTitle.equals("")){
%>
</div>
</div>
<%
}

if(!hasBidsOverall){
%>
<p>No bids received yet.</p>
<%
}

conBid.close();

}catch(Exception e){
e.printStackTrace();
}

}
%>

</div><!-- ✅ IMPORTANT: closes reviewApplicationsSection -->

<!-- ACCEPTED APPLICATIONS SECTION -->
<div id="acceptedApplicationsSection"
     style="display:none; width:100%; max-width:900px;">

<div class="manage-header">
<div>
<h2>Accepted Applications</h2>
<p>Candidates you've accepted for positions</p>
</div>
</div>

<%
Integer employerId3 = (Integer) currentSession.getAttribute("eid");

if(employerId3 != null){

Connection con4 = null;
PreparedStatement ps4 = null;
ResultSet rs4 = null;

try{



con4 = DBConnection.getConnection();

String query =
"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, a.applied_at, 'Application' AS source " +
"FROM applications a " +
"JOIN jobs j ON a.job_id=j.job_id " +
"JOIN jobseeker js ON a.jobseeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(a.status)='accepted' " +

" UNION ALL " +

"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, b.created_at AS applied_at, 'Bid' AS source " +
"FROM bids b " +
"JOIN jobs j ON b.job_id=j.job_id " +
"JOIN jobseeker js ON b.job_seeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(b.bid_status)='accepted' " +

"ORDER BY applied_at DESC";

ps4 = con4.prepareStatement(query);
ps4.setInt(1, employerId3);
ps4.setInt(2, employerId3);

rs4 = ps4.executeQuery();

boolean hasAccepted=false;

while(rs4.next()){
hasAccepted=true;
%>

<div class="review-card" style="border:1.5px solid #b9f5c8;">

<div class="worker-info">

<div class="avatar">
<%= rs4.getString("jfirstname").substring(0,1) %>
<%= rs4.getString("jlastname").substring(0,1) %>
</div>

<div class="worker-details">

<h3>
<%= rs4.getString("jfirstname") %>
<%= rs4.getString("jlastname") %>
<span style="color:#1dbf73;">✔ Accepted (<%= rs4.getString("source") %>)</span>
</h3>

<p><%= rs4.getString("jemail") %></p>

<div class="meta">
<span>Applied For: <%= rs4.getString("title") %> | </span>
<span>Location: <%= rs4.getString("jdistrict") %></span>
</div>

</div>
</div>

</div>

<%
}

if(!hasAccepted){
%>

<p>No accepted applications.</p>

<%
}

}catch(Exception e){
out.println(e);
}

}
%>
</div>
<!-- REJECTED APPLICATIONS SECTION -->
<div id="rejectedApplicationsSection"
     style="display:none; width:100%; max-width:900px;">

<div class="manage-header">
<div>
<h2>Rejected Applications</h2>
<p>Candidates not selected for the role</p>
</div>
</div>

<%
Integer employerId4 = (Integer) currentSession.getAttribute("eid");

if(employerId4 != null){

Connection con5 = null;
PreparedStatement ps5 = null;
ResultSet rs5 = null;

try{



con5 = DBConnection.getConnection();

String query2 =
"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, a.applied_at, 'Application' AS source " +
"FROM applications a " +
"JOIN jobs j ON a.job_id=j.job_id " +
"JOIN jobseeker js ON a.jobseeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(a.status)='rejected' " +

" UNION ALL " +

"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, b.created_at AS applied_at, 'Bid' AS source " +
"FROM bids b " +
"JOIN jobs j ON b.job_id=j.job_id " +
"JOIN jobseeker js ON b.job_seeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(b.bid_status)='rejected' " +

"ORDER BY applied_at DESC";

ps5 = con5.prepareStatement(query2);
ps5.setInt(1, employerId4);
ps5.setInt(2, employerId4);

rs5 = ps5.executeQuery();

boolean hasRejected=false;

while(rs5.next()){
hasRejected=true;
%>

<div class="review-card" style="border:2px solid rgba(229,57,53,0.5);">

<div class="worker-info">

<div class="avatar">
<%= rs5.getString("jfirstname").substring(0,1) %>
<%= rs5.getString("jlastname").substring(0,1) %>
</div>

<div class="worker-details">

<h3>
<%= rs5.getString("jfirstname") %>
<%= rs5.getString("jlastname") %>
<span style="color:#e53935;">✖ Rejected (<%= rs5.getString("source") %>)</span>
</h3>

<p><%= rs5.getString("jemail") %></p>

<div class="meta">
<span>Applied For: <%= rs5.getString("title") %> | </span>
<span>Location: <%= rs5.getString("jdistrict") %></span>
</div>

</div>
</div>

</div>

<%
}

if(!hasRejected){
%>

<p>No rejected applications.</p>

<%
}

}catch(Exception e){
out.println(e);
}

}
%>

</div>
<!-- ================= PAYMENTS SECTION ================= -->


<div id="paymentsSection" style="display:none; width:100%; max-width:900px;">

    <div class="manage-header">
        <div>
            <h2>Payments</h2>
            <p>Track and confirm payments with workers</p>
        </div>
    </div>

<%
Integer empIdPay = (Integer) currentSession.getAttribute("eid");

if(empIdPay != null){

    try{
       

        Connection conPay = DBConnection.getConnection();
        PreparedStatement psPay = conPay.prepareStatement(
            "SELECT a.application_id, j.title, " +
            "js.jfirstname, js.jlastname, " +
            "IFNULL(p.status,'Pending') AS payment_status " +
            "FROM applications a " +
            "JOIN jobs j ON a.job_id = j.job_id " +
            "JOIN jobseeker js ON a.jobseeker_id = js.jid " +
            "LEFT JOIN payments p ON a.application_id = p.application_id " +
            "WHERE j.eid=? AND a.status='Accepted'"
        );

        psPay.setInt(1, empIdPay);
        ResultSet rsPay = psPay.executeQuery();

        boolean hasData = false;

        while(rsPay.next()){
            hasData = true;

            String status = rsPay.getString("payment_status");

            String color = "#ffc107"; // Pending
            if("Requested".equals(status)) color="#ff9800";
            else if("Paid".equals(status)) color="#2196f3";
            else if("Confirmed".equals(status)) color="#28a745";
%>

<div class="review-card">

    <div class="worker-info">
        <div class="avatar">
            <%= rsPay.getString("jfirstname").charAt(0) %>
            <%= rsPay.getString("jlastname").charAt(0) %>
        </div>

        <div class="worker-details">
            <h3>
                <%= rsPay.getString("jfirstname") %>
                <%= rsPay.getString("jlastname") %>
            </h3>

            <div class="meta">
                <span>Job: <%= rsPay.getString("title") %></span>
            </div>

            <p>
                <strong>Status:</strong>
                <span style="padding:5px 12px;border-radius:12px;color:white;background:<%= color %>;">
                    <%= status %>
                </span>
            </p>
        </div>
    </div>

    <div class="actions">

<% if("Pending".equals(status)) { %>

    <p style="color:#777;">Waiting for worker to request payment</p>

<% } else if("Requested".equals(status)) { %>

    <a href="UpdatePaymentServlet?app_id=<%= rsPay.getInt("application_id") %>&action=paid"
       class="accept-btn">Mark Paid 💸</a>

<% } else if("Paid".equals(status)) { %>

    <p style="color:#555;">Waiting for worker confirmation...</p>

<% } else if("Confirmed".equals(status)) { %>

    <p style="color:green; font-weight:600;">✔ Payment Completed</p>

<% } %>

    </div>

</div>

<%
        }

        if(!hasData){
%>

<p>No payment records yet.</p>

<%
        }

        conPay.close();

    }catch(Exception e){
        e.printStackTrace();
    }
}
%>

</div>



    </main>
</div>

<!-- JS  -->
<script>
const filters = document.querySelectorAll("select, input");
const cards = document.querySelectorAll(".review-card");
filters.forEach(f => f.addEventListener("input", applyFilters));
function applyFilters() {
    cards.forEach(card => {
        card.style.display =
            card.innerText.toLowerCase()
            .includes(searchInput.value.toLowerCase())
            ? "block" : "none";
    });
}
</script>


<script>
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const section = params.get("section");

    if (section === "manageJobs") {
        showSection("manageJobs");
    }
    else if(section === "reviewBids"){
        showSection("reviewBids");
    }

});
</script>

<script>
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", () => {
    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
});
</script>
<script>
function closeModal() {
    document.getElementById("successModal").style.display = "none";
}
setTimeout(() => {
    const modal = document.getElementById("successModal");
    if (modal) modal.style.display = "none";
}, 3000);


function showSection(section, event) {

    const sections = [
        "dashboardSection",
        "manageJobsSection",
        "reviewApplicationsSection",
        "acceptedApplicationsSection",
        "rejectedApplicationsSection",
        "paymentsSection"
    ];

    // Hide all sections
    sections.forEach(function(id) {
        const el = document.getElementById(id);
        if(el){
            el.style.display = "none";
        }
    });

    // Show selected section
    if(section === "dashboard"){
        document.getElementById("dashboardSection").style.display = "block";
    }
    else if(section === "manageJobs"){
        document.getElementById("manageJobsSection").style.display = "block";
    }
    else if(section === "reviewApplications"){
        document.getElementById("reviewApplicationsSection").style.display = "block";
    }
    else if(section === "acceptedApplications"){
        document.getElementById("acceptedApplicationsSection").style.display = "block";
    }
    else if(section === "rejectedApplications"){
        document.getElementById("rejectedApplicationsSection").style.display = "block";
    }
    else if(section === "payments"){
        document.getElementById("paymentsSection").style.display = "block";
    }

    // Remove active class from all sidebar links
    document.querySelectorAll(".sidebar a").forEach(function(a){
        a.classList.remove("active");
    });

    // Add active class to clicked link
    if(event){
        event.target.classList.add("active");
    }
}


</script>

<script>
window.onload = function() {
    // Check if there are any accepted applications
    var acceptedSection = document.getElementById('acceptedApplicationsSection');
    var rejectedSection = document.getElementById('rejectedApplicationsSection');

    if(acceptedSection.querySelectorAll('.review-card').length > 0){
        acceptedSection.style.display = 'block';
    }

    if(rejectedSection.querySelectorAll('.review-card').length > 0){
        rejectedSection.style.display = 'block';
    }
};
</script>
<script>
document.querySelectorAll(".respondBidBtn").forEach(function(button) {
    button.addEventListener("click", function() {
        const bidId = this.dataset.bidid;
        const action = this.dataset.action;
        const card = document.getElementById("bidCard_" + bidId);

        fetch(`RespondBidByEmployerServlet?bid_id=${bidId}&action=${action}`)
            .then(response => response.text())
            .then(data => {
                // Remove card from review section
                card.remove();

                // Create new card for Accepted/Rejected section
                const newCard = card.cloneNode(true);
                newCard.querySelectorAll("button").forEach(b => b.remove()); // remove buttons

                if(action === "accept") {
                    newCard.querySelector("h3").innerHTML += ' <span style="color:#1dbf73;">✔ Accepted</span>';
                    const acceptedSection = document.getElementById("acceptedApplicationsSection");
                    acceptedSection.style.display = "block";
                    acceptedSection.appendChild(newCard);
                } else {
                    newCard.querySelector("h3").innerHTML += ' <span style="color:#e53935;">✖ Rejected</span>';
                    const rejectedSection = document.getElementById("rejectedApplicationsSection");
                    rejectedSection.style.display = "block";
                    rejectedSection.appendChild(newCard);
                }
            })
            .catch(err => console.error(err));
    });
});
</script>
</body>
</html> 
