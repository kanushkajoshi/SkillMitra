<%-- 
    Document   : emp_dash.jsp
    Created on : 2 Jan, 2026, 10:33:58 PM
    Author     : Ishitaa Gupta
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>
<!--//for for each loop-->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<%
    // Session check
//    if (session.getAttribute("eemail") == null) {
//        response.sendRedirect("login.jsp");
//        return;
//    }

    // If name not already in session, fetch from DB
    if (session.getAttribute("efirstname") == null) {

        String email = (String) session.getAttribute("eemail");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "");

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

<!-- HEADER -->
<header>
    <div class="logo">SkillMitra</div>
    <nav>
        <a href="EmployerJobsServlet">Dashboard</a>
        <a href="post_job.jsp">Post Job</a>
        <a href="#">Logout</a>
    </nav>
</header>

<!-- DASHBOARD -->
<div class="dashboard">

    <!-- LEFT FILTERS -->
    <aside class="filters">
        <h3>Filter Workers</h3>

        <label>Skill</label>
        <select id="skillFilter">
            <option value="">All</option>
            <option>Electrician</option>
            <option>Plumber</option>
            <option>Driver</option>
            <option>House Maid</option>
        </select>

        <label>Location</label>
        <input type="text" id="locationFilter" placeholder="Enter city">

        <label>Experience</label>
        <select id="experienceFilter">
            <option value="">Any</option>
            <option>Fresher</option>
            <option>1-3</option>
            <option>3+</option>
        </select>

        <label>Availability</label>
        <select id="availabilityFilter">
            <option value="">Any</option>
            <option>Full-Time</option>
            <option>Part-Time</option>
            <option>Daily</option>
        </select>

        <label>Wage (₹/day)</label>
        <select id="wageFilter">
            <option value="">Any</option>
            <option value="500">₹500+</option>
            <option value="800">₹800+</option>
            <option value="1000">₹1000+</option>
        </select>

        <label>Job Type</label>
        <select id="jobTypeFilter">
            <option value="">Any</option>
            <option>Permanent</option>
            <option>Temporary</option>
            <option>Contract</option>
        </select>
    </aside>

    <!-- CENTER CONTENT -->
    <main class="content">

        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="Search workers by skill or location">
            <button>Search</button>
        </div>

        <div class="cards">

            <div class="worker-card"
                 data-skill="Electrician"
                 data-location="Delhi"
                 data-experience="3+"
                 data-availability="Full-Time"
                 data-wage="800"
                 data-jobtype="Permanent">

                <h4>Ramesh Kumar</h4>
                <p>Electrician</p>
                <span>📍 Delhi | ₹800/day</span>
                <button>View Profile</button>
            </div>

            <div class="worker-card"
                 data-skill="House Maid"
                 data-location="Noida"
                 data-experience="1-3"
                 data-availability="Daily"
                 data-wage="600"
                 data-jobtype="Temporary">

                <h4>Sunita Devi</h4>
                <p>House Maid</p>
                <span>📍 Noida | ₹600/day</span>
                <button>View Profile</button>
            </div>

        </div>
           <section class="posted-jobs">
        <h2>Your Posted Jobs</h2>

        <c:if test="${empty jobs}">
            <p>You have not posted any jobs yet.</p>
        </c:if>

        <div class="job-cards">
            <c:forEach var="job" items="${jobs}">
                <div class="job-card">
                    <h3>${job.job_title}</h3>
                    <p>
                         ${job.job_location}, ${job.job_city}<br>
                         ${job.job_type}<br>
                         ₹${job.wage}/day
                    </p>
                    <small>Posted on ${job.created_at}</small>
                </div>
            </c:forEach>
        </div>
    </section>
    </main>
        
         <aside class="profile">
    <div class="profile-header" onclick="toggleProfileMenu()">
        <img src="images/default-user.png">
        <div>
            <strong>
                <%= session.getAttribute("efirstname") %>
                <%= session.getAttribute("elastname") %>
            </strong>
            <p>
                <%= session.getAttribute("ecompanyname") %>
            </p>
        </div>
    </div>

    <div class="profile-menu" id="profileMenu">
    <a href="employer_profile.jsp">View Profile</a>
    <a href="EditEmployerProfileServlet">Edit Profile</a>
    <a href="LogoutServlet">Logout</a>
</div>

</aside>  
</div>
    

    
    <!--List of posted jobs-->


    <!-- RIGHT PROFILE (LINKEDIN STYLE) -->
   



<!-- FILTER LOGIC -->
<script>
const filters = document.querySelectorAll("select, input");
const cards = document.querySelectorAll(".worker-card");

filters.forEach(f => f.addEventListener("input", applyFilters));

function applyFilters() {
    cards.forEach(card => {
        const match =
            (!skillFilter.value || card.dataset.skill === skillFilter.value) &&
            (!locationFilter.value || card.dataset.location.toLowerCase().includes(locationFilter.value.toLowerCase())) &&
            (!experienceFilter.value || card.dataset.experience === experienceFilter.value) &&
            (!availabilityFilter.value || card.dataset.availability === availabilityFilter.value) &&
            (!jobTypeFilter.value || card.dataset.jobtype === jobTypeFilter.value) &&
            (!wageFilter.value || Number(card.dataset.wage) >= Number(wageFilter.value)) &&
            card.innerText.toLowerCase().includes(searchInput.value.toLowerCase());

        card.style.display = match ? "block" : "none";
    });
}

function toggleProfileMenu() {
    document.getElementById("profileMenu").classList.toggle("show");
}
</script>

</body>
</html>
