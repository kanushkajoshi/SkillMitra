<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="db.DBConnection" %>

<%
HttpSession sessionUser = request.getSession(false);

if(sessionUser == null || sessionUser.getAttribute("jobseekerId") == null){
response.sendRedirect("login.jsp");
return;
}

int jid = (Integer) sessionUser.getAttribute("jobseekerId");

String q = request.getParameter("q");
String minSalary = request.getParameter("min_salary");
String maxSalary = request.getParameter("max_salary");
String[] areas = request.getParameterValues("area");

Connection con = DBConnection.getConnection();

/* ================= GET DISTRICT ================= */

String district = "";

PreparedStatement psDistrict = con.prepareStatement(
"SELECT jdistrict FROM jobseeker WHERE jid=?"
);

psDistrict.setInt(1,jid);
ResultSet rsDistrict = psDistrict.executeQuery();

if(rsDistrict.next()){
district = rsDistrict.getString("jdistrict");
}

rsDistrict.close();
psDistrict.close();

/* ================= BUILD QUERY ================= */

StringBuilder sql = new StringBuilder();

sql.append(
"SELECT j.job_id, j.title, j.description, j.city, j.locality, j.salary, j.min_salary, " +
"COUNT(DISTINCT js.subskill_id) AS matchedSkills, " +
"COUNT(DISTINCT jk.subskill_id) AS totalSkills " +
"FROM jobs j " +
"JOIN job_skills jk ON jk.job_id = j.job_id " +
"LEFT JOIN jobseeker_skills js ON js.subskill_id = jk.subskill_id AND js.jid = ? " +
"WHERE j.city = ? AND j.status = 'Active' AND j.expiry_date >= CURDATE() "
);

/* search */

if(q!=null && !q.trim().isEmpty()){
sql.append(
" AND j.job_id IN (" +
"SELECT jk2.job_id FROM job_skills jk2 " +
"JOIN subskill ss ON ss.subskill_id = jk2.subskill_id " +
"WHERE LOWER(ss.subskill_name) LIKE LOWER(?)" +
") "
);
}

/* area filter */

if(areas!=null && areas.length>0){
sql.append(" AND j.locality IN (");
for(int i=0;i<areas.length;i++){
sql.append("?");
if(i<areas.length-1){
sql.append(",");
}
}
sql.append(") ");
}

/* salary filter */

if(minSalary!=null && !minSalary.isEmpty()){
sql.append(" AND j.min_salary >= ? ");
}

if(maxSalary!=null && !maxSalary.isEmpty()){
sql.append(" AND j.salary <= ? ");
}

sql.append(" GROUP BY j.job_id ORDER BY matchedSkills DESC ");

/* ================= PREPARE ================= */

PreparedStatement ps = con.prepareStatement(sql.toString());

int idx=1;

ps.setInt(idx++,jid);
ps.setString(idx++,district);

if(q!=null && !q.trim().isEmpty()){
ps.setString(idx++,"%"+q+"%");
}

if(areas!=null && areas.length>0){
for(int i=0;i<areas.length;i++){
ps.setString(idx++,areas[i]);
}
}

if(minSalary!=null && !minSalary.isEmpty()){
ps.setInt(idx++,Integer.parseInt(minSalary));
}

if(maxSalary!=null && !maxSalary.isEmpty()){
ps.setInt(idx++,Integer.parseInt(maxSalary));
}

/* ================= EXECUTE ================= */

ResultSet rs = ps.executeQuery();

List<Map<String,Object>> bestMatchJobs = new ArrayList<Map<String,Object>>();
List<Map<String,Object>> otherJobs = new ArrayList<Map<String,Object>>();

while(rs.next()){

int matched = rs.getInt("matchedSkills");
int total = rs.getInt("totalSkills");

int percent = 0;
if(total > 0){
    percent = (matched * 100) / total;
}

Map<String,Object> job = new HashMap<String,Object>();

job.put("job_id",rs.getInt("job_id"));
job.put("title",rs.getString("title"));
job.put("locality",rs.getString("locality"));
job.put("city",rs.getString("city"));
job.put("salary",rs.getString("salary"));
job.put("min_salary",rs.getString("min_salary"));
job.put("percent",percent);

if(bestMatchJobs.size() < 3){
    bestMatchJobs.add(job);
} else {
    otherJobs.add(job);
}


}

rs.close();
ps.close();
con.close();

int totalResults = bestMatchJobs.size() + otherJobs.size();
%>

<!DOCTYPE html>

<html>
<head>
<title>Search Results | SkillMitra</title>
<link rel="stylesheet" href="search_results.css">
</head>

<body>

<!-- 🔵 NAVBAR -->
<div class="navbar">
  <div class="nav-left">SkillMitra</div>
  <a href="jobseeker_dash.jsp" class="back-btn">← Back</a>
</div>

<!-- 🔵 MAIN CONTAINER (IMPORTANT CHANGE) -->
<div class="results-container">

<p class="total-results">
    <b>Total Results:</b> <%= totalResults %>
</p>

<%
if(totalResults == 0){
%>

<div class="no-results">
    <div class="no-results-card">
        <div class="no-results-icon">😕</div>
        <h2>No jobs found</h2>
        <p>Try adjusting your filters to see more results</p>

        <div class="suggestions-box">
            <p class="suggestions-label">Suggestions</p>
            <ul>
                <li>Remove the area filter</li>
                <li>Try a different skill keyword</li>
                <li>Increase your salary range</li>
            </ul>
        </div>

        <button class="reset-btn"
            onclick="window.location='jobseeker_dash.jsp'">
            Reset Filters
        </button>
    </div>
</div>

<%
} else {
%>

<h2 class="section-title">🔥 Best Skill Match</h2>

<%
if(bestMatchJobs.isEmpty()){
%>

<p>No strong skill matches found</p>

<%
}

for(int i=0;i<bestMatchJobs.size();i++){
Map<String,Object> job = bestMatchJobs.get(i);
%>

<div class="card">

<h3><%= job.get("title") %></h3>

<p>📍 <%= job.get("locality") %>, <%= job.get("city") %></p>

<p>Salary: ₹<%= job.get("salary") %></p>

<p>Min Salary: ₹<%= job.get("min_salary") %></p>

<p>
Match: <span class="match">
<%= job.get("percent") %>%
</span>
</p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>">
<button class="view-btn">View Job</button>
</a>

</div>

<%
}
%>

<h2 class="section-title">Other Jobs</h2>

<%
if(otherJobs.isEmpty()){
%>

<p>No other jobs available</p>

<%
}

for(int i=0;i<otherJobs.size();i++){
Map<String,Object> job = otherJobs.get(i);
%>

<div class="card">

<h3><%= job.get("title") %></h3>

<p>📍 <%= job.get("locality") %>, <%= job.get("city") %></p>

<p>Salary: ₹<%= job.get("salary") %></p>

<p>Min Salary: ₹<%= job.get("min_salary") %></p>

<p>
Match: <span class="match">
<%= job.get("percent") %>%
</span>
</p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>">
<button class="view-btn">View Job</button>
</a>

</div>

<%
}
}
%>

</div>

</body>