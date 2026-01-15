<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>


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
<link rel="stylesheet"
      href="<%= request.getContextPath() %>/jobseeker_dash.css">

</head>

<body>

<!-- Sidebar -->
<div class="sidebar">
    <h2>SkillMitra</h2>
    <a href="jobseeker_dash.jsp">Job Seeker Dashboard</a>
    <a href="#">Applied Jobs</a>
    <a href="#">Assigned Job</a>
    <a href="#">Payment History</a>
    <a href="#">Ratings & Reviews</a>
</div>

<div class="main">

    <!-- Top Bar -->
    <div class="topbar">
        <div>Welcome, <b><%= session.getAttribute("jobseekerName") %></b></div>
        <div><a href="LogoutServlet">Logout</a></div>
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
    "SELECT DISTINCT j.* " +
    "FROM jobs j " +
    "JOIN jobseeker_skills js ON j.skill_id = js.skill_id " +
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

    </div>
</div>

</body>
</html>
