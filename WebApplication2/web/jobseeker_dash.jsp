<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
    // 🔴 ADDED: Prevent browser cache (VERY IMPORTANT)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 🔴 ADDED: Strict Session Check FIRST
    HttpSession currentSession = request.getSession(false);

    if (currentSession == null || currentSession.getAttribute("jobseekerId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int jobseekerId = (Integer) currentSession.getAttribute("jobseekerId");

    String cityFilter = request.getParameter("city");
    String minSalaryFilter = request.getParameter("min_salary");
%>

<%
    // Load firstname only if not already in session
    if (currentSession.getAttribute("jfirstname") == null) {

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conTemp = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "password");

            PreparedStatement psTemp = conTemp.prepareStatement(
                "SELECT jfirstname, jlastname FROM jobseeker WHERE jid = ?");
            psTemp.setInt(1, jobseekerId);

            ResultSet rsTemp = psTemp.executeQuery();
            if (rsTemp.next()) {
                currentSession.setAttribute("jfirstname", rsTemp.getString("jfirstname"));
                currentSession.setAttribute("jlastname", rsTemp.getString("jlastname"));
            }

            conTemp.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Seeker Dashboard | SkillMitra</title>
<link rel="stylesheet" href="jobseeker_dash.css">
</head>

<body>

<!-- Sidebar -->
<div class="sidebar">
    <h2>JobSeeker</h2>
    <a href="jobseeker_dash.jsp">Dashboard</a>
    <a href="#">Applied Jobs</a>
    <a href="#">Assigned Job</a>
    <a href="#">Payment History</a>
    <a href="#">Ratings & Reviews</a>
</div>

<div class="main">

    <!-- Navbar -->
    <div class="navbar">
        <div class="nav-left">SkillMitra</div>

        <div class="nav-right">
            <div class="profile-dropdown">

                <img src="images/default-user.png"
                     class="profile-icon"
                     id="profileIcon">

                <div class="profile-menu" id="profileMenu">
                    <div class="profile-name">
                        <%= currentSession.getAttribute("jfirstname") != null ?
                            currentSession.getAttribute("jfirstname") : "" %>

                        <%= currentSession.getAttribute("jlastname") != null ?
                            currentSession.getAttribute("jlastname") : "" %>
                    </div>

                    <a href="jobseeker_profile.jsp">View Profile</a>
                    <a href="LogoutServlet">Logout</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Top Bar -->
    <div class="topbar">
        <div>
            Welcome,
            <b><%= currentSession.getAttribute("jfirstname") %></b>
        </div>
    </div>

    <!-- Search Bar -->
    <form class="search-box" method="get">
        <input type="text" name="city" placeholder="City"
               value="<%= cityFilter != null ? cityFilter : "" %>">

        <input type="number" name="min_salary" placeholder="Minimum Salary"
               value="<%= minSalaryFilter != null ? minSalaryFilter : "" %>">

        <button type="submit">Search</button>
    </form>

    <!-- Job Cards -->
    <div class="cards">

<%
Connection con = DBConnection.getConnection();

String sql =
    "SELECT DISTINCT j.job_id, j.title, j.city, j.salary, j.job_type " +
    "FROM jobs j " +
    "JOIN job_skills jk ON jk.job_id = j.job_id " +
    "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
    "AND js.subskill_id = jk.subskill_id " +
    "WHERE js.jid = ? ";

if (cityFilter != null && !cityFilter.isEmpty()) {
    sql += " AND LOWER(j.city) LIKE LOWER(?) ";
}

if (minSalaryFilter != null && !minSalaryFilter.isEmpty()) {
    sql += " AND j.min_salary >= ? ";
}

PreparedStatement ps = con.prepareStatement(sql);

int idx = 1;
ps.setInt(idx++, jobseekerId);

if (cityFilter != null && !cityFilter.isEmpty()) {
    ps.setString(idx++, "%" + cityFilter + "%");
}

if (minSalaryFilter != null && !minSalaryFilter.isEmpty()) {
    ps.setInt(idx++, Integer.parseInt(minSalaryFilter));
}

ResultSet rs = ps.executeQuery();


while (rs.next()) {
%>

<div class="card" style="
        background:white;
        padding:18px;
        margin-bottom:18px;
        border-radius:10px;
        box-shadow:0 2px 8px rgba(0,0,0,0.08);
">

    <!-- Job Title -->
    <h3 style="margin:0; font-size:20px;">
        <%= rs.getString("title") %>
    </h3>

    <!-- Salary Highlight -->
    <div style="font-size:16px; font-weight:bold; color:#1dbf73; margin-top:6px;">
        💰 ₹<%= rs.getString("salary") %>
    </div>

    <!-- Location -->
    <p style="margin:6px 0;">
        📍 <%= rs.getString("city") %>
    </p>

    <!-- Job Type Badge -->
    <div style="margin-top:8px;">
        <span style="
            background:#eef2ff;
            padding:4px 12px;
            border-radius:15px;
            font-size:13px;">
            <%= rs.getString("job_type") %>
        </span>
    </div>

    <!-- Buttons -->
    <div style="margin-top:15px;">
        
        <!-- Apply Button -->
        <form action="ApplyJobServlet" method="post" style="display:inline;">
            <input type="hidden" name="jobId" value="<%= rs.getInt("job_id") %>">
            <button type="submit" style="
                background:#007bff;
                color:white;
                padding:8px 16px;
                border:none;
                border-radius:6px;
                cursor:pointer;">
                Apply Now
            </button>
        </form>

       

    </div>

</div>

<%
}
con.close();
%>


<script>
    const profileIcon = document.getElementById("profileIcon");
    const profileMenu = document.getElementById("profileMenu");

    profileIcon.addEventListener("click", function (e) {
        e.stopPropagation();
        profileMenu.style.display =
            profileMenu.style.display === "block" ? "none" : "block";
    });

    document.addEventListener("click", function () {
        profileMenu.style.display = "none";
    });
</script>

    </div>
</div>

</body>
</html>
