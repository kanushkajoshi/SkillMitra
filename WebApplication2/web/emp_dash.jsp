<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("eemail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (session.getAttribute("efirstname") == null) {
        String email = (String) session.getAttribute("eemail");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "password");
            PreparedStatement ps = con.prepareStatement(
                "SELECT efirstname, elastname, ecompanyname FROM employer WHERE eemail = ?");
            ps.setString(1, email);
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
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Employer Dashboard | SkillMitra</title>
    <link rel="stylesheet" href="emp_dash.css">
</head>

<body>

<header>
    <div class="logo">SkillMitra</div>
    <nav>
        <a href="#" onclick="showSection('dashboard')">Dashboard</a>
        <a href="#" onclick="showSection('manageJobs')">Post Job</a>
        <a href="LogoutServlet">Logout</a>
    </nav>

    <div class="profile-dropdown">
        <img src="images/default-user.png" class="profile-icon" id="profileIcon">
        <div class="profile-menu" id="profileMenu">
            <div class="profile-name">
                <%= session.getAttribute("efirstname") %> <%= session.getAttribute("elastname") %>
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
                <button class="post-job-btn">+ Post Job</button>
            </div>

            <div class="job-card">
                <div class="job-details">
                    <h3>Electrician</h3>
                    <p class="job-desc">Looking for an experienced electrician for home wiring work.</p>
                    <div class="job-meta">
                        <span>📍 Delhi</span>
                        <span>💰 ₹800 / day</span>
                    </div>
                </div>
                <div class="job-actions">
                    <span class="edit">✏️</span>
                    <span class="delete">🗑️</span>
                </div>
            </div>

            <div class="job-card">
                <div class="job-details">
                    <h3>Plumber</h3>
                    <p class="job-desc">Looking for a plumber for bathroom fitting and repair.</p>
                    <div class="job-meta">
                        <span>📍 Noida</span>
                        <span>💰 ₹750 / day</span>
                    </div>
                </div>
                <div class="job-actions">
                    <span class="edit">✏️</span>
                    <span class="delete">🗑️</span>
                </div>
            </div>
        </div>

        <!-- REVIEW, ACCEPTED, REJECTED sections remain same as before -->
        <!-- ... keep all remaining HTML unchanged ... -->

    </main>
</div>

<!-- JS Scripts remain unchanged -->
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
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", () => {
    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
});
</script>

</body>
</html>
