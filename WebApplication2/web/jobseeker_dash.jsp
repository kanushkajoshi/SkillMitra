<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

  

    if (session.getAttribute("jfirstname") == null) {
        int jid = (Integer) session.getAttribute("jobseekerId");
        String email = (String) session.getAttribute("jemail");
        try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra", "root", "password");

        PreparedStatement ps = con.prepareStatement(
            "SELECT jfirstname, jlastname FROM jobseeker WHERE jid = ?");
        ps.setInt(1, jid);

        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            session.setAttribute("jfirstname", rs.getString("jfirstname"));
            session.setAttribute("jlastname", rs.getString("jlastname"));
        }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<%
    if (session == null || session.getAttribute("jobseekerId") == null) {
        response.sendRedirect("register.jsp");
        return;
    }

    int jobseekerId = (Integer) session.getAttribute("jobseekerId");

    String cityFilter = request.getParameter("city");
    String minSalaryFilter = request.getParameter("min_salary");
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
    <a href="jobseeker_dash.jsp"> Dashboard</a>
    <a href="#">Applied Jobs</a>
    <a href="#">Assigned Job</a>
    <a href="#">Payment History</a>
    <a href="#">Ratings & Reviews</a>
</div>

<div class="main">
   
    <!-- ADDED NAVBAR  -->
    
    
    <div class="navbar">
        <div class="nav-left">SkillMitra</div>

        <div class="nav-right">

    <!-- PROFILE DROPDOWN WRAPPER -->
    <div class="profile-dropdown">

        <!-- Profile Icon -->
        <img src="images/default-user.png"
             class="profile-icon"
             id="profileIcon">

        
        <div class="profile-menu" id="profileMenu">
            <div class="profile-name">
                <%
                    String fname = (String) session.getAttribute("jfirstname");
                    String lname = (String) session.getAttribute("jlastname");
                %>
                <%= fname != null ? fname : "" %> <%= lname != null ? lname : "" %>
            </div>

            <a href="jobseeker_profile.jsp">View Profile</a>
            <a href="LogoutServlet">Logout</a>
        </div>

    </div>
</div>


    </div>
    


    <!-- Top Bar -->
    <div class="topbar">
        <div>Welcome, <b><%= session.getAttribute("jobseekerName") %></b></div>

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
    <div class="card">
        <h3><%= rs.getString("title") %></h3>
        <p><b>City:</b> <%= rs.getString("city") %></p>
        <p><b>Salary:</b> ₹<%= rs.getString("salary") %></p>
        <p><b>Type:</b> <%= rs.getString("job_type") %></p>
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
