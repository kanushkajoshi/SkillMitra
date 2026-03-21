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
"COUNT(DISTINCT js.subskill_id) AS matchedSkills " +
"FROM jobs j " +
"JOIN job_skills jk ON jk.job_id = j.job_id " +
"LEFT JOIN jobseeker_skills js ON js.subskill_id = jk.subskill_id AND js.jid = ? " +
"WHERE j.city = ? AND j.status = 'Active' AND j.expiry_date >= CURDATE() "
);

/* search text */

if(q!=null && !q.trim().isEmpty()){

sql.append(
" AND j.job_id IN (" +
"SELECT jk2.job_id FROM job_skills jk2 " +
"JOIN subskill ss ON ss.subskill_id = jk2.subskill_id " +
"WHERE LOWER(ss.subskill_name) LIKE LOWER(?)" +
") "
);

}

/* areas filter */

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

/* salary filters */

if(minSalary!=null && !minSalary.isEmpty()){
sql.append(" AND j.min_salary >= ? ");
}

if(maxSalary!=null && !maxSalary.isEmpty()){
sql.append(" AND j.salary <= ? ");
}
sql.append(" GROUP BY j.job_id ORDER BY matchedSkills DESC ");

/* ================= PREPARE STATEMENT ================= */

PreparedStatement ps = con.prepareStatement(sql.toString());

int idx=1;

ps.setInt(idx++,jid);
ps.setString(idx++,district);

/* search parameters */

if(q!=null && !q.trim().isEmpty()){
ps.setString(idx++,"%"+q+"%");
}

/* area parameters */

if(areas!=null && areas.length>0){
for(String area:areas){
ps.setString(idx++,area);
}
}

/* salary parameters */

if(minSalary!=null && !minSalary.isEmpty()){
ps.setInt(idx++,Integer.parseInt(minSalary));
}

if(maxSalary!=null && !maxSalary.isEmpty()){
ps.setInt(idx++,Integer.parseInt(maxSalary));
}

/* ================= EXECUTE ================= */

ResultSet rs = ps.executeQuery();

/* Store results first */

List<Map<String,Object>> bestMatchJobs = new ArrayList<Map<String,Object>>();
List<Map<String,Object>> otherJobs = new ArrayList<Map<String,Object>>();

while(rs.next()){

int jobId = rs.getInt("job_id");
int matched = rs.getInt("matchedSkills");

PreparedStatement psTotal = con.prepareStatement(
"SELECT COUNT(*) FROM job_skills WHERE job_id=?"
);

psTotal.setInt(1, jobId);

ResultSet rsTotal = psTotal.executeQuery();
rsTotal.next();

int totalSkills = rsTotal.getInt(1);

rsTotal.close();
psTotal.close();

int percent = 0;

if(totalSkills>0){
percent = (matched*100)/totalSkills;
}

/* store job details */

Map<String,Object> job = new HashMap<String,Object>();

job.put("job_id",jobId);
job.put("title",rs.getString("title"));
job.put("locality",rs.getString("locality"));
job.put("city",rs.getString("city"));
job.put("salary",rs.getString("salary"));
job.put("min_salary",rs.getString("min_salary"));
job.put("percent",percent);

if(bestMatchJobs.size() < 3){
    bestMatchJobs.add(job);   // top 3 jobs automatically
}else{
    otherJobs.add(job);
}

}


rs.close();
ps.close();

%>

<!DOCTYPE html>
<html>
<head>
<title>Search Results | SkillMitra</title>
<link rel="stylesheet" href="jobseeker_dash.css">
</head>

<body>

<div class="main">
<a href="jobseeker_dash.jsp">
<button style="margin-bottom:20px;">← Back to Dashboard</button>
</a>
<h2>🔥 Best Skill Match</h2>

<%
for(Map<String,Object> job : bestMatchJobs){
%>

<div class="card">

<h3><%= job.get("title") %></h3>

<p><b>Location:</b>
<%= job.get("locality") %>,
<%= job.get("city") %>
</p>

<p><b>Salary:</b> ₹<%= job.get("salary") %></p>

<p><b>Minimum Salary:</b> ₹<%= job.get("min_salary") %></p>

<p><b>Match:</b>
<b style="color:green"><%= job.get("percent") %>% Match</b>
</p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>">
<button class="view-btn">View Job</button>
</a>

</div>

<%
}
%>
<h2>Other <%= q %> Jobs</h2>

<%
for(Map<String,Object> job : otherJobs){
%>

<div class="card">

<h3><%= job.get("title") %></h3>

<p><b>Location:</b>
<%= job.get("locality") %>,
<%= job.get("city") %>
</p>

<p><b>Salary:</b> ₹<%= job.get("salary") %></p>

<p><b>Minimum Salary:</b> ₹<%= job.get("min_salary") %></p>

<p><b>Match:</b>
<b style="color:green"><%= job.get("percent") %>% Match</b>
</p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>">
<button class="view-btn">View Job</button>
</a>

</div>

<%
}
%>
<%

rs.close();
ps.close();
con.close();
%>

</div>

</body>
</html>