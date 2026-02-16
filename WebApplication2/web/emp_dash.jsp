<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>
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
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/skillmitra", "root", "");

   Integer employerId = (Integer) session.getAttribute("eid");

PreparedStatement ps = con.prepareStatement(
    "SELECT efirstname, elastname, ecompanyname FROM employer WHERE eid = ?");
ps.setInt(1, employerId);


    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        session.setAttribute("efirstname", rs.getString("efirstname"));
        session.setAttribute("elastname", rs.getString("elastname"));
        session.setAttribute("ecompanyname", rs.getString("ecompanyname"));
    }
    con.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

<%
    String successMsg = (String) session.getAttribute("jobSuccess");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Employer Dashboard | SkillMitra</title>
    <link rel="stylesheet" href="emp_dash.css">
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
    session.removeAttribute("jobSuccess");
}
%>

<header>
    <div class="logo">SkillMitra</div>
    

   
    <div class="profile-dropdown">
        <img src="images/default-user.png" class="profile-icon" id="profileIcon">
        <div class="profile-menu" id="profileMenu">
            <div class="profile-name" style="background:none; color:#000; font-weight:600; border-bottom:none;">
                <%
    String fname = (String) session.getAttribute("efirstname");
    String lname = (String) session.getAttribute("elastname");
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
        <a href="#">Payments</a>
        <a href="#">Rate & Review</a>
    </aside>

    <main class="content">

     
 <div class="topbar">
        <div>
    Welcome,
    <b><%= session.getAttribute("efirstname") %>
    <%= session.getAttribute("elastname") %></b>
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


    <!-- Header (Post Job button remains here) -->
    <div class="manage-header">
        <h2>Manage Jobs</h2>
        <a href="<%= request.getContextPath() %>/post-job">
            <button class="post-job-btn">+ Post Job</button>
        </a>
    </div>

<%
Integer employerId = (Integer) session.getAttribute("eid");

if(employerId != null){

    try{
        Class.forName("com.mysql.jdbc.Driver");

        Connection con2 = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra",
            "root",
            ""
        );

        PreparedStatement ps2 = con2.prepareStatement(
            "SELECT * FROM jobs WHERE eid = ? ORDER BY job_id DESC"
        );

        ps2.setInt(1, employerId);

        ResultSet rs2 = ps2.executeQuery();

        boolean hasJobs = false;

        
        while(rs2.next()){
    
            
%>


    <!-- JOB CARD -->
    <div class="job-card">
    <div class="job-details">
        <h3><%= rs2.getString("title") %></h3>

        <p><strong>Description:</strong>
            <%= rs2.getString("description") %>
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

        <p><strong>Experience Level:</strong>
            <%= rs2.getString("experience_level") %>
        </p>

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
    out.print(new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(ts));
}
%>
</p>


    </div>

    <div class="job-actions">
        <a href="EditJobServlet?job_id=<%= rs2.getInt("job_id") %>" class="edit-btn"> Edit</a>

        <a href="DeleteJobServlet?job_id=<%= rs2.getInt("job_id") %>"
           class="delete-btn"
           onclick="return confirm('Are you sure you want to delete this job?');">
           Delete
        </a>
    </div>
</div>



<%
    }

        if(hasJobs==false){
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


        
        <!-- REVIEW APPLICATIONS SECTION -->
<div id="reviewApplicationsSection" style="display:none; width:100%; max-width:900px;">

    <div class="manage-header">
        <div>
            <h2>Review Applications</h2>
            <p>Review and manage candidate applications</p>
        </div>
    </div>
    <%
Integer employerId2 = (Integer) session.getAttribute("eid");

if(employerId2 != null){

    try{
        Class.forName("com.mysql.jdbc.Driver");

        Connection con3 = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra",
            "root",
            ""
        );

        PreparedStatement ps3 = con3.prepareStatement(
            "SELECT a.application_id, a.applied_at, j.title, " +
            "js.jid, js.jfirstname, js.jlastname, js.jemail, js.jcity, js.jjob " +
            "FROM applications a " +
            "JOIN jobs j ON a.job_id = j.job_id " +
            "JOIN jobseeker js ON a.jobseeker_id = js.jid " +
            "WHERE j.eid = ? AND a.status = 'Pending' " +
            "ORDER BY a.applied_at DESC"
        );

        ps3.setInt(1, employerId2);

        ResultSet rs3 = ps3.executeQuery();

        boolean hasApps = false;

        while(rs3.next()){
            hasApps = true;
%>

<div class="review-card">

    <div class="worker-info">
        <div class="avatar">
            <%= rs3.getString("jfirstname").charAt(0) %>
            <%= rs3.getString("jlastname").charAt(0) %>
        </div>

        <div class="worker-details">
            <h3>
                <%= rs3.getString("jfirstname") %>
                <%= rs3.getString("jlastname") %>
            </h3>

            <p><%= rs3.getString("jemail") %></p>

            <div class="meta">
                <span>Applied For: <%= rs3.getString("title") %></span>
                <span>📍 <%= rs3.getString("jcity") %></span>
                <span>Skill: <%= rs3.getString("jjob") %></span>
            </div>

            <div style="font-size:13px; margin-top:6px;">
                Applied On:
                <%
                Timestamp ts = rs3.getTimestamp("applied_at");
                if(ts != null){
                    out.print(new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(ts));
                }
                %>
            </div>
        </div>
    </div>

    <div class="actions">

        <a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Accepted"
           class="accept-btn">
           Accept
        </a>

        <a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Rejected"
           class="reject-btn">
           Reject
        </a>

    </div>

</div>

<%
        }

        if(!hasApps){
%>
<p>No pending applications.</p>
<%
        }

        con3.close();

    } catch(Exception e){
        e.printStackTrace();
    }
}
%>

   



</div>

<!-- ACCEPTED APPLICATIONS SECTION -->
<div id="acceptedApplicationsSection"
     style="display:none; width:100%; max-width:900px;">

    <div class="manage-header">
        <div>
            <h2>Accepted Applications</h2>
            <p>Candidates you've accepted for positions</p>
        </div>
    </div>
<div class="review-card" style="border:1.5px solid #b9f5c8;">
    <div class="worker-info"
         style="width:100%; display:flex; justify-content:space-between; align-items:flex-end;">

       
        <div style="display:flex; gap:16px;">
            <div class="avatar">RK</div>

            <div class="worker-details">
                <h3>
                    Rakesh Kumar
                    <span style="color:#1dbf73; font-size:14px; margin-left:8px;">
                        ✔ Accepted
                    </span>
                </h3>

                <p>rakesh@example.com</p>

                <div class="meta" style="margin-top:6px;">
                    <div><b>Skill:</b> Electrician</div>
                    <div><b>Location:</b> Delhi</div>
                </div>
            </div>
        </div>

       
        <div style="text-align:right;">
            <div style="font-weight:600; font-size:15px;">
                ₹800 / day
            </div>

            <div style="font-size:13px; color:#555; margin-top:6px;">
                Hired Date : <b>15 Jan 2026</b>
            </div>
        </div>

    </div>
</div>
<div class="review-card" style="border:1.5px solid #b9f5c8;">
    <div class="worker-info"
         style="width:100%; display:flex; justify-content:space-between; align-items:flex-end;">

        
        <div style="display:flex; gap:16px;">
            <div class="avatar">SD</div>

            <div class="worker-details">
                <h3>
                    Sunita Devi
                    <span style="color:#1dbf73; font-size:14px; margin-left:8px;">
                        ✔ Accepted
                    </span>
                </h3>

                <p>sunita@example.com</p>

                <div class="meta" style="margin-top:6px;">
                    <div><b>Skill:</b> House Maid</div>
                    <div><b>Location:</b> Noida</div>
                </div>
            </div>
        </div>

       
        <div style="text-align:right;">
            <div style="font-weight:600; font-size:15px;">
                ₹600 / day
            </div>

            <div style="font-size:13px; color:#555; margin-top:6px;">
                Hired Date : <b>18 Jan 2026</b>
            </div>
        </div>

    </div>
</div>


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

    <div class="review-card" style="
    border: 2px solid rgba(229,57,53,0.5); /* light red transparent */
    border-radius:14px;
    padding:18px 20px;
    box-shadow:0 8px 18px rgba(0,0,0,0.08);
    margin-bottom:16px;
    width:100%;
    max-width:900px;
">

    <div class="worker-info"
         style="width:100%; display:flex; justify-content:space-between; align-items:flex-end;">

        <div style="display:flex; gap:16px;">
            <div class="avatar">MR</div>

            <div class="worker-details">
                <h3>
                    Mohan Ram
                    <span style="color:#e53935; font-size:14px; margin-left:8px;">
                        ✖ Rejected
                    </span>
                </h3>

                <p>mohan@example.com</p>

                <div class="meta" style="margin-top:6px;">
                    <div><b>Skill:</b> Construction Helper</div>
                    <div><b>Location:</b> Ghaziabad</div>
                </div>
            </div>
        </div>

        <!-- RIGHT BOTTOM -->
        <div style="text-align:right;">
            <div style="font-weight:600; font-size:15px;">
                ₹550 / day
            </div>

            <div style="font-size:13px; color:#555; margin-top:6px;">
                Rejected Date : <b>20 Jan 2026</b>
            </div>
        </div>

    </div>
</div>
<div class="review-card" style="
    border: 2px solid rgba(229,57,53,0.5); /* light red transparent */
    border-radius:14px;
    padding:18px 20px;
    box-shadow:0 8px 18px rgba(0,0,0,0.08);
    margin-bottom:16px;
    width:100%;
    max-width:900px;
">

    <div class="worker-info"
         style="width:100%; display:flex; justify-content:space-between; align-items:flex-end;">

       
        <div style="display:flex; gap:16px;">
            <div class="avatar">KS</div>

            <div class="worker-details">
                <h3>
                    Kamla Singh
                    <span style="color:#e53935; font-size:14px; margin-left:8px;">
                        ✖ Rejected
                    </span>
                </h3>

                <p>kamla@example.com</p>

                <div class="meta" style="margin-top:6px;">
                    <div><b>Skill:</b> Street Food Helper</div>
                    <div><b>Location:</b> Faridabad</div>
                </div>
            </div>
        </div>

       
        <div style="text-align:right;">
            <div style="font-weight:600; font-size:15px;">
                ₹500 / day
            </div>

            <div style="font-size:13px; color:#555; margin-top:6px;">
                Rejected Date : <b>21 Jan 2026</b>
            </div>
        </div>

    </div>
</div>

</div>

    </main>
</div>

<!-- JS  -->
<script>
const filters = document.querySelectorAll("select, input");
const cards = document.querySelectorAll(".worker-card");
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
function showSection(section) {
    const sections = [
        "dashboardSection","manageJobsSection","reviewApplicationsSection",
        "acceptedApplicationsSection","rejectedApplicationsSection"
    ];
    sections.forEach(id => {
        const el = document.getElementById(id);
        if(el) el.style.display = "none";
    });
    if(section === "dashboard") dashboardSection.style.display = "block";
    else if(section === "manageJobs") manageJobsSection.style.display = "block";
    else if(section === "reviewApplications") reviewApplicationsSection.style.display = "block";
    else if(section === "acceptedApplications") acceptedApplicationsSection.style.display = "block";
    else if(section === "rejectedApplications") rejectedApplicationsSection.style.display = "block";

    document.querySelectorAll(".sidebar a").forEach(a => a.classList.remove("active"));
    event.target.classList.add("active");
}
</script>
<script>
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const section = params.get("section");

    if (section === "manageJobs") {
        showSection("manageJobs");
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

</script>


</body>
</html> 