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

<style>
body { font-family: Arial; background: #f5f5f5; }

.main { width: 70%; margin: auto; }

.card {
    background: white;
    padding: 15px;
    margin: 15px 0;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.view-btn {
    padding: 8px 15px;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

/* ── improved empty state ── */
.no-results {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 400px;
    padding: 2rem 0;
}

.no-results-card {
    background: white;
    border-radius: 12px;
    border: 1px solid #e5e5e5;
    padding: 3rem 2.5rem;
    text-align: center;
    max-width: 420px;
    width: 100%;
}

.no-results-icon {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: #f5f5f5;
    border: 1px solid #e5e5e5;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1.5rem;
    font-size: 32px;
    line-height: 1;
}

.no-results-card h2 {
    font-size: 20px;
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 0.5rem;
}

.no-results-card > p {
    font-size: 14px;
    color: #666;
    margin: 0 0 1.5rem;
}

.suggestions-box {
    background: #f9f9f9;
    border-radius: 8px;
    padding: 1rem 1.25rem;
    margin: 0 0 1.5rem;
    text-align: left;
}

.suggestions-label {
    font-size: 11px;
    font-weight: 600;
    color: #999;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    margin: 0 0 0.65rem;
}

.suggestions-box ul {
    margin: 0;
    padding-left: 1.25rem;
}

.suggestions-box ul li {
    font-size: 14px;
    color: #333;
    padding: 3px 0;
}

.reset-btn {
    width: 100%;
    padding: 10px 0;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    cursor: pointer;
}

.reset-btn:hover {
    background: #0069d9;
}
/* find your back button style or add this */
.back-btn{
    background:#4a6fa5;
    color:white;
    padding:8px 16px;
    border-radius:6px;
    text-decoration:none;
}

</style>

</head>

<body>

<div class="main">

<a href="jobseeker_dash.jsp" class="back-btn">← Back to Dashboard</a>

<p><b>Total Results:</b> <%= totalResults %></p>

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
        <button class="reset-btn" onclick="window.location='jobseeker_dash.jsp'">
            Reset Filters
        </button>
    </div>
</div>

<%
} else {
%>

<h2>🔥 Best Skill Match</h2>

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

<p><b>Location:</b> <%= job.get("locality") %>, <%= job.get("city") %></p>
<p><b>Salary:</b> ₹<%= job.get("salary") %></p>
<p><b>Min Salary:</b> ₹<%= job.get("min_salary") %></p>
<p><b>Match:</b> <b style="color:green"><%= job.get("percent") %>%</b></p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>"> <button class="view-btn">View Job</button> </a>

</div>

<%
}
%>

<h2>Other Jobs</h2>

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

<p><b>Location:</b> <%= job.get("locality") %>, <%= job.get("city") %></p>
<p><b>Salary:</b> ₹<%= job.get("salary") %></p>
<p><b>Min Salary:</b> ₹<%= job.get("min_salary") %></p>
<p><b>Match:</b> <b style="color:green"><%= job.get("percent") %>%</b></p>

<a href="job_details.jsp?jobId=<%= job.get("job_id") %>"> <button class="view-btn">View Job</button> </a>

</div>

<%
}
%>

<%
}
%>

</div>

</body>
</html>
