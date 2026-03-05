<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

HttpSession currentSession = request.getSession(false);
if (currentSession == null || currentSession.getAttribute("jobseekerId") == null) {
    response.sendRedirect("login.jsp");
    return;
}

int jobseekerId = (Integer) currentSession.getAttribute("jobseekerId");
String cityFilter = request.getParameter("city");
String minSalaryFilter = request.getParameter("min_salary");
String section = request.getParameter("section"); // 🔹 Added to detect Applied Jobs section

Connection con = null;
PreparedStatement psTemp = null;
ResultSet rsTemp = null;

// Load name if not in session
if (currentSession.getAttribute("jfirstname") == null) {
    try {
        con = DBConnection.getConnection();
        psTemp = con.prepareStatement(
            "SELECT jfirstname, jlastname FROM jobseeker WHERE jid = ?"
        );
        psTemp.setInt(1, jobseekerId);
        rsTemp = psTemp.executeQuery();

        if (rsTemp.next()) {
            currentSession.setAttribute("jfirstname", rsTemp.getString("jfirstname"));
            currentSession.setAttribute("jlastname", rsTemp.getString("jlastname"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsTemp != null) try { rsTemp.close(); } catch(Exception e){}
        if (psTemp != null) try { psTemp.close(); } catch(Exception e){}
        if (con != null) try { con.close(); } catch(Exception e){}
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

<div class="sidebar">
<h2>JobSeeker</h2>
<a href="jobseeker_dash.jsp">Dashboard</a>
<a href="jobseeker_dash.jsp?section=applied">Applied Jobs</a>
<a href="#">Assigned Job</a>
<a href="#">Payment History</a>
<a href="#">Ratings & Reviews</a>
</div>

<div class="main">

<div class="navbar">
<div class="nav-left">SkillMitra</div>
<div class="nav-right">
<div class="profile-dropdown">
<img src="images/default-user.png" class="profile-icon" id="profileIcon">
<div class="profile-menu" id="profileMenu">
<div class="profile-name">
<%= currentSession.getAttribute("jfirstname") %>
<%= currentSession.getAttribute("jlastname") %>
</div>
<a href="jobseeker_profile.jsp">View Profile</a>
<a href="LogoutServlet">Logout</a>
</div>
</div>
</div>
</div>

<div class="topbar">
Welcome, <b><%= currentSession.getAttribute("jfirstname") %></b>
</div>

<form class="search-box" method="get">
<input type="text" name="city" placeholder="City" value="<%= cityFilter!=null?cityFilter:"" %>">
<input type="number" name="min_salary" placeholder="Minimum Salary" value="<%= minSalaryFilter!=null?minSalaryFilter:"" %>">
<button type="submit">Search</button>
</form>

<div class="cards">
<%
PreparedStatement ps = null;
ResultSet rs = null;

try {
    con = DBConnection.getConnection();

    if("applied".equals(section)){
        // 🔹 Fetch Applied Jobs
        String sqlApplied = "SELECT j.job_id, j.title, j.description, j.city, j.state, j.country, " +
                            "j.locality, j.salary, j.min_salary, j.job_type, j.languages_preferred, " +
                            "j.experience_required, j.experience_level, j.workers_required, " +
                            "j.expiry_date, j.gender_preference, j.working_hours, j.zip, " +
                            "a.status " +
                            "FROM applications a " +
                            "JOIN jobs j ON j.job_id = a.job_id " +
                            "WHERE a.jobseeker_id = ? " +
                            "ORDER BY a.applied_at DESC";
        ps = con.prepareStatement(sqlApplied);
        ps.setInt(1, jobseekerId);

    } else {
        // 🔹 Normal Skill matched jobs fetch (existing logic)
        String sql = "SELECT DISTINCT j.job_id, j.title, j.description, j.city, j.state, j.country, " +
                     "j.locality, j.salary, j.min_salary, j.job_type, j.languages_preferred, " +
                     "j.experience_required, j.experience_level, j.workers_required, " +
                     "j.expiry_date, j.gender_preference, j.working_hours, j.zip, " +
                     "a.status, " +
                     "CASE WHEN a.application_id IS NOT NULL THEN 1 ELSE 0 END AS applied " +
                     "FROM jobs j " +
                     "JOIN job_skills jk ON jk.job_id = j.job_id " +
                     "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
                     "AND js.subskill_id = jk.subskill_id " +
                     "LEFT JOIN applications a ON a.job_id = j.job_id AND a.jobseeker_id = ? " +
                     "WHERE js.jid = ? ";

        if (cityFilter != null && !cityFilter.isEmpty()) sql += " AND LOWER(j.city) LIKE LOWER(?) ";
        if (minSalaryFilter != null && !minSalaryFilter.isEmpty()) sql += " AND j.min_salary >= ? ";

        ps = con.prepareStatement(sql);
        int idx = 1;
        ps.setInt(idx++, jobseekerId);
        ps.setInt(idx++, jobseekerId);
        if (cityFilter != null && !cityFilter.isEmpty()) ps.setString(idx++, "%" + cityFilter + "%");
        if (minSalaryFilter != null && !minSalaryFilter.isEmpty()) ps.setInt(idx++, Integer.parseInt(minSalaryFilter));
    }

    rs = ps.executeQuery();

    while(rs.next()){
%>

<div class="card" style="background:white;padding:20px;margin-bottom:20px;border-radius:12px;box-shadow:0 3px 10px rgba(0,0,0,0.08);">

<h3><%= rs.getString("title") %></h3>

<p><b>Description:</b> <%= rs.getString("description") %></p>

<p><b>Location:</b> 
<%= rs.getString("locality") %>, 
<%= rs.getString("city") %>, 
<%= rs.getString("state") %>, 
<%= rs.getString("country") %> - 
<%= rs.getString("zip") %>
</p>

<p><b>Salary:</b> ₹<%= rs.getString("salary") %></p>

<p><b>Minimum Salary:</b> ₹<%= rs.getString("min_salary") %></p>

<p><b>Experience Required:</b> <%= rs.getString("experience_required") %></p>

<p><b>Experience Level:</b> <%= rs.getString("experience_level") %></p>

<p><b>Workers Required:</b> <%= rs.getString("workers_required") %></p>

<p><b>Working Hours:</b> <%= rs.getString("working_hours") %></p>

<p><b>Gender Preference:</b> <%= rs.getString("gender_preference") %></p>

<p><b>Languages Preferred:</b> <%= rs.getString("languages_preferred") %></p>

<p><b>Expiry Date:</b> <%= rs.getString("expiry_date") %></p>

<p>
<span style="background:#eef2ff;padding:4px 12px;border-radius:15px;font-size:13px;">
<%= rs.getString("job_type") %>
</span>
</p>

<div style="margin-top:15px;">
<%
if("applied".equals(section)){
%>
    <button disabled style="background:#cccccc;padding:8px 16px;border:none;border-radius:6px;">
        ✓ <%= rs.getString("status") %>
    </button>
<%
} else {
    boolean isApplied = rs.getInt("applied") == 1;
    String status = rs.getString("status");
    if(isApplied){
%>
    <button disabled style="background:#cccccc;padding:8px 16px;border:none;border-radius:6px;">
        ✓ <%= status %>
    </button>
<% } else { %>
    <a href="job_details.jsp?jobId=<%= rs.getInt("job_id") %>">
    <button type="button" style="background:#007bff;color:white;padding:8px 16px;border:none;border-radius:6px;">
        View Job
    </button>
    </a>
<% } } %>
</div>

</div>

<%
    }

} catch (Exception e) { e.printStackTrace(); }
finally {
    if(rs != null) try{ rs.close(); } catch(Exception e){}
    if(ps != null) try{ ps.close(); } catch(Exception e){}
    if(con != null) try{ con.close(); } catch(Exception e){}
}
%>

</div>

<script>
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", function(e){
    e.stopPropagation();
    profileMenu.style.display = profileMenu.style.display==="block"?"none":"block";
});
document.addEventListener("click", function(){
    profileMenu.style.display="none";
});
</script>

</div>
</body>
</html>