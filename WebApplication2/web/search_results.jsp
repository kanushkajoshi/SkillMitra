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

if(percent >= 50){
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
  <div style="display:flex; align-items:center; gap:16px;">
      <a href="jobseeker_dash.jsp" class="back-btn">← Back to Dashboard</a>
    <img src="skillmitralogo.jpg" alt="Logo" style="width:35px; height:35px; border-radius:50%; object-fit:cover;">
      <div class="nav-left">SkillMitra</div>
    
  </div>
  <div class="profile-dropdown">
    <%
    HttpSession sr = request.getSession(false);
    String srPhoto = (String) sr.getAttribute("jphoto");
    String srImg = (srPhoto != null && !srPhoto.trim().isEmpty()) 
                   ? "uploads/" + srPhoto 
                   : "images/default-user.png";
    %>
    <img src="<%= srImg %>" class="profile-icon" id="profileIcon"
         style="width:38px; height:38px; border-radius:50%; 
                border:2px solid white; cursor:pointer;">
    <div class="profile-menu" id="profileMenu"
         style="display:none; position:absolute; right:0; top:55px;
                background:#fff; width:200px; border-radius:10px;
                box-shadow:0 8px 25px rgba(0,0,0,0.15); z-index:999;">
      <div style="padding:12px 14px; font-weight:600; border-bottom:1px solid #eee;">
        <%= sr.getAttribute("jfirstname") %> <%= sr.getAttribute("jlastname") %>
      </div>
      <a href="jobseeker_profile.jsp" 
         style="display:block; padding:10px 14px; color:#333; text-decoration:none;">
         View Profile
      </a>
      <a href="LogoutServlet" 
         style="display:block; padding:10px 14px; color:#333; text-decoration:none;">
         Logout
      </a>
    </div>
  </div>
</div>

<script>
document.getElementById("profileIcon").addEventListener("click", function(e){
    e.stopPropagation();
    var menu = document.getElementById("profileMenu");
    menu.style.display = menu.style.display === "block" ? "none" : "block";
});
document.addEventListener("click", function(){
    document.getElementById("profileMenu").style.display = "none";
});
</script>

<!-- 🔵 MAIN CONTAINER (IMPORTANT CHANGE) -->
<div class="results-container">

<!-- LEFT PANEL -->
<div class="left-panel">
    <div class="side-card">
        <h4>Search Tips</h4>
        <div class="side-tip">
            <span>Results are matched based on your registered skills</span>
        </div>
        <div class="side-tip">
            <span>Use area and salary filters for more relevant results</span>
        </div>
        <div class="side-tip">
            <span>Keep your profile updated for better job matches</span>
        </div>
    </div>
    <div class="side-card">
        <h4>Match Guide</h4>
        <div class="side-tip">
            <span style="color:#166534; font-weight:700;">75–100%</span>
            <span>Excellent match</span>
        </div>
        <div class="side-tip">
            <span style="color:#1d4ed8; font-weight:700;">50–74%</span>
            <span>Good match</span>
        </div>
        <div class="side-tip">
            <span style="color:#9ca3af; font-weight:700;">Below 50%</span>
            <span>Partial match</span>
        </div>
    </div>
</div>

<!-- CENTER COLUMN -->
<div class="center-col">

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

<h2 class="section-title">Best Skill Match</h2>

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

<div class="salary-row">
    <span class="salary-badge">₹<%= job.get("salary") %> Min</span>
    <span class="min-salary-badge">₹<%= job.get("min_salary") %> Max</span>
</div>

<p>
<%
Connection conSub1 = DBConnection.getConnection();
PreparedStatement psSub1 = conSub1.prepareStatement(
    "SELECT ss.subskill_name FROM subskill ss " +
    "JOIN job_skills jsk ON jsk.subskill_id = ss.subskill_id " +
    "WHERE jsk.job_id = ?"
);
psSub1.setInt(1, (Integer) job.get("job_id"));
ResultSet rsSub1 = psSub1.executeQuery();
while(rsSub1.next()){
%>
<span style="display:inline-block; background:#f0f4ff; color:#3b5bdb;
             font-size:11px; padding:2px 10px; border-radius:20px; margin:2px;">
    <%= rsSub1.getString("subskill_name") %>
</span>
<%
}
rsSub1.close(); psSub1.close(); conSub1.close();
%>
</p>

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

<div class="salary-row">
    <span class="salary-badge">₹<%= job.get("salary") %> Min</span>
    <span class="min-salary-badge">₹<%= job.get("min_salary") %> Max</span>
</div>

<p>
<%
Connection conSub2 = DBConnection.getConnection();
PreparedStatement psSub2 = conSub2.prepareStatement(
    "SELECT ss.subskill_name FROM subskill ss " +
    "JOIN job_skills jsk ON jsk.subskill_id = ss.subskill_id " +
    "WHERE jsk.job_id = ?"
);
psSub2.setInt(1, (Integer) job.get("job_id"));
ResultSet rsSub2 = psSub2.executeQuery();
while(rsSub2.next()){
%>
<span style="display:inline-block; background:#f0f4ff; color:#3b5bdb;
             font-size:11px; padding:2px 10px; border-radius:20px; margin:2px;">
    <%= rsSub2.getString("subskill_name") %>
</span>
<%
}
rsSub2.close(); psSub2.close(); conSub2.close();
%>
</p>

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

</div> <%-- closes center-col --%>

<!-- RIGHT PANEL -->
<div class="right-panel">
    <div class="side-card">
        <h4>Quick Actions</h4>
        <div class="side-tip-plain">
            <a href="jobseeker_profile.jsp" style="color:#3b5bdb; text-decoration:none; font-weight:500;">Update your profile</a>
        </div>
        <div class="side-tip-plain">
            <a href="jobseeker_dash.jsp?section=applied" style="color:#3b5bdb; text-decoration:none; font-weight:500;">View applied jobs</a>
        </div>
        <div class="side-tip-plain">
            <a href="jobseeker_dash.jsp?section=payments" style="color:#3b5bdb; text-decoration:none; font-weight:500;">Payment history</a>
        </div>
    </div>
    <div class="side-card">
        <h4>How Bidding Works</h4>
        <div class="side-tip-plain">
            <span style="font-weight:700; color:#4f6d84; margin-right:8px;">1.</span>
            <span>View a job and place your expected salary</span>
        </div>
        <div class="side-tip-plain">
            <span style="font-weight:700; color:#4f6d84; margin-right:8px;">2.</span>
            <span>Employer reviews and accepts or counters</span>
        </div>
        <div class="side-tip-plain">
            <span style="font-weight:700; color:#4f6d84; margin-right:8px;">3.</span>
            <span>Accept the counter offer to get hired</span>
        </div>
    </div>
</div>

</div> <%-- closes results-container --%>

</body>