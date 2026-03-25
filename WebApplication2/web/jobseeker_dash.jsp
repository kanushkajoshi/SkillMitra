<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ include file="header.jsp" %>

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
Connection conName = DBConnection.getConnection();

PreparedStatement psName =
conName.prepareStatement(
"SELECT jfirstname, jlastname, jdistrict, jzip FROM jobseeker WHERE jid=?");

psName.setInt(1, jobseekerId);

ResultSet rsName = psName.executeQuery();

if(rsName.next()){

currentSession.setAttribute("jfirstname", rsName.getString("jfirstname"));
currentSession.setAttribute("jlastname", rsName.getString("jlastname"));
currentSession.setAttribute("jdistrict", rsName.getString("jdistrict"));
String zip = rsName.getString("jzip");
if(zip != null){
    currentSession.setAttribute("jzip", zip);
}
}

conName.close();
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
            currentSession.setAttribute("jdistrict", rsTemp.getString("jdistrict"));
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

<form class="search-box" onsubmit="return false;"> 
    <input type="hidden" name="jid" value="<%= session.getAttribute("jobseekerId") %>">
<input type="text" name="q" placeholder="Search jobs...">

<button type="button" id="filterBtn">Filters ▼</button>

<button type="button" onclick="applyFilters()">Search</button>

<div id="filterContainer" class="filter-container">

<!-- Skill -->
<label>Skill:</label>
<select id="skillSelect">
    <option value="">-- Select Skill --</option>
    <%
    Connection conSkill = DBConnection.getConnection();
    PreparedStatement psSkill = conSkill.prepareStatement("SELECT skill_id, skill_name FROM skill");
    ResultSet rsSkill = psSkill.executeQuery();
    while(rsSkill.next()){
    %>
        <option value="<%= rsSkill.getInt("skill_id") %>">
            <%= rsSkill.getString("skill_name") %>
        </option>
    <%
    }
    conSkill.close();
    %>
</select>

<!-- Subskills -->
<label>Subskills:</label>
<div id="subskillContainer">Select skill first</div>

<!-- District -->
<label>District:</label>
<input type="text" name="district"
value="<%= currentSession.getAttribute("jdistrict") %>" readonly>

<!-- Area -->
<label>Area:</label>
<div id="areaContainer"></div>

<!-- Salary -->
<label>Min Salary:</label>
<input type="number" name="min_salary">

<label>Max Salary:</label>
<input type="number" name="max_salary">

<button type="submit">Apply Filters</button>

</div>
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
                            "j.experience_level, j.workers_required, " +
                            "j.expiry_date, j.gender_preference, j.working_hours, j.zip, " +
                            "a.status " +
                            "FROM applications a " +
                            "JOIN jobs j ON j.job_id = a.job_id " +
                            "WHERE a.jobseeker_id = ? " +
                            "ORDER BY a.applied_at DESC";
        ps = con.prepareStatement(sqlApplied);
        ps.setInt(1, jobseekerId);

    } else {

    String districtFilter = request.getParameter("district");
    String[] areaFilter = request.getParameterValues("area");
    String[] subskillFilter = request.getParameterValues("subskill");
    String minSalary = request.getParameter("min_salary");
    String maxSalary = request.getParameter("max_salary");

    StringBuilder sql = new StringBuilder(
    "SELECT DISTINCT j.job_id, j.title, j.description, j.city, j.state, j.country, " +
    "j.locality, j.salary, j.min_salary, j.job_type, j.languages_preferred, " +
    "j.experience_level, j.workers_required, j.expiry_date, j.gender_preference, j.working_hours, j.zip, " +
    "a.status, CASE WHEN a.application_id IS NOT NULL THEN 1 ELSE 0 END AS applied " +
    "FROM jobs j " +
    "JOIN job_skills jk ON jk.job_id = j.job_id " +
    "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
    "LEFT JOIN applications a ON a.job_id = j.job_id AND a.jobseeker_id = ? " +
    "WHERE js.jid = ? AND j.status='ACTIVE' "
    );

    // FILTERS

    if (districtFilter != null && !districtFilter.isEmpty()) {
        sql.append(" AND LOWER(j.city)=LOWER(?) ");
    }

    if (areaFilter != null && areaFilter.length > 0) {
        sql.append(" AND j.locality IN (");
        for(int i=0;i<areaFilter.length;i++){
            sql.append("?");
            if(i<areaFilter.length-1) sql.append(",");
        }
        sql.append(") ");
    }

    if (subskillFilter != null && subskillFilter.length > 0) {
        sql.append(" AND jk.subskill_id IN (");
        for(int i=0;i<subskillFilter.length;i++){
            sql.append("?");
            if(i<subskillFilter.length-1) sql.append(",");
        }
        sql.append(") ");
    }

    if (minSalary != null && !minSalary.isEmpty()) {
        sql.append(" AND j.min_salary >= ? ");
    }

    if (maxSalary != null && !maxSalary.isEmpty()) {
        sql.append(" AND j.salary <= ? ");
    }

    // ALWAYS LAST
    sql.append(" ORDER BY (LOWER(j.city)=LOWER(?)) DESC ");

    ps = con.prepareStatement(sql.toString());

    int idx = 1;

    ps.setInt(idx++, jobseekerId);
    ps.setInt(idx++, jobseekerId);

    if (districtFilter != null && !districtFilter.isEmpty()) {
        ps.setString(idx++, districtFilter);
    }

    if (areaFilter != null) {
        for(String area : areaFilter){
            ps.setString(idx++, area);
        }
    }

    if (subskillFilter != null) {
        for(String sub : subskillFilter){
            ps.setInt(idx++, Integer.parseInt(sub));
        }
    }

    if (minSalary != null && !minSalary.isEmpty()) {
        ps.setInt(idx++, Integer.parseInt(minSalary));
    }

    if (maxSalary != null && !maxSalary.isEmpty()) {
        ps.setInt(idx++, Integer.parseInt(maxSalary));
    }

    ps.setString(idx++, (String) currentSession.getAttribute("jdistrict"));
}
    rs = ps.executeQuery();

    while(rs.next()){
%>

<div class="card" style="background:white;padding:20px;margin-bottom:20px;border-radius:12px;box-shadow:0 3px 10px rgba(0,0,0,0.08);">

<h3><%= rs.getString("title") %></h3>
<%
int jobIdCard = rs.getInt("job_id");

PreparedStatement psBid = con.prepareStatement(
"SELECT bid_id,bid_amount, bid_status, counter_bid FROM bids WHERE job_id=? AND job_seeker_id=?"
);

psBid.setInt(1, jobIdCard);
psBid.setInt(2, jobseekerId);

ResultSet rsBid = psBid.executeQuery();

int bidAmount = 0;
String bidStatus = "";
int counterBid = 0;
int bidId = 0;

if(rsBid.next()){
     bidId = rsBid.getInt("bid_id");
    bidAmount = rsBid.getInt("bid_amount");
    bidStatus = rsBid.getString("bid_status");
    counterBid = rsBid.getInt("counter_bid");
}
%>

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

<p><b>Experience Required:</b> <%= rs.getString("experience_level") %></p>

<p><b>Experience Level:</b> <%= rs.getString("experience_level") %></p>

<p><b>Workers Required:</b> <%= rs.getString("workers_required") %></p>

<p><b>Working Hours:</b> <%= rs.getString("working_hours") %></p>

<p><b>Gender Preference:</b> <%= rs.getString("gender_preference") %></p>

<p><b>Languages Preferred:</b> <%= rs.getString("languages_preferred") %></p>

<p><b>Expiry Date:</b> <%= rs.getString("expiry_date") %></p>
<%
if(bidAmount > 0){
%>

<p style="color:green;">
<b>Your Bid:</b> ₹<%= bidAmount %> (<%= bidStatus %>)
</p>

<%
    if("Countered".equals(bidStatus)){
%>

<p style="color:red;">
💸 Employer Countered: ₹<%= counterBid %>
</p>

<a href="RespondCounterServlet?bid_id=<%= bidId %>&action=accept">
    <button style="background:#28a745;color:white;padding:6px 12px;border:none;border-radius:5px;">
        Accept Counter
    </button>
</a>

<a href="RespondCounterServlet?bid_id=<%= bidId %>&action=reject">
    <button style="background:#dc3545;color:white;padding:6px 12px;border:none;border-radius:5px;">
        Reject Counter
    </button>
</a>

<%
    }
}
%>

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
const jobseekerZip = "<%= currentSession.getAttribute("jzip") %>";
console.log("ZIP CODE:", jobseekerZip);
</script>

<script>
function loadAreas(){

console.log("Fetching areas for:", jobseekerZip);

fetch("https://api.postalpincode.in/pincode/" + jobseekerZip)

.then(response => response.json())

.then(data => {

const container = document.getElementById("areaContainer");

container.innerHTML = "";

if(data && data[0] && data[0].Status === "Success"){

const postOffices = data[0].PostOffice;

postOffices.forEach(function(post){

const area = post.Name;

const label = document.createElement("label");

label.innerHTML =
'<input type="checkbox" name="area" value="'+area+'"> ' + area;

container.appendChild(label);

});

}else{

container.innerHTML = "No areas found";

}

})

.catch(error => {

console.error("API error:", error);

document.getElementById("areaContainer").innerHTML = "Error loading areas";

});

}

loadAreas();
</script>
<script>
const searchInput = document.getElementById("searchInput");
const suggestionBox = document.getElementById("suggestionBox");

searchInput.addEventListener("keyup", function(){

const q = this.value;

if(q.length < 1){
suggestionBox.innerHTML="";
return;
}

fetch("SearchSuggestionServlet?q="+q)

.then(res=>res.json())

.then(data=>{

suggestionBox.innerHTML="";

data.forEach(function(item){

const div = document.createElement("div");

div.className="suggestion-item";

div.textContent=item;

div.onclick=function(){

searchInput.value=item;
suggestionBox.innerHTML="";

};

suggestionBox.appendChild(div);

});

});
});
</script>
<script>
// FILTER TOGGLE
const filterBtn = document.getElementById("filterBtn");
const filterBox = document.getElementById("filterContainer");

filterBtn.addEventListener("click", function () {
    filterBox.style.display =
        filterBox.style.display === "block" ? "none" : "block";
});

// LOAD SUBSKILLS
const skillSelect = document.getElementById("skillSelect");
const subskillContainer = document.getElementById("subskillContainer");

skillSelect.addEventListener("change", function () {

    const skillId = this.value;

    if (!skillId) {
        subskillContainer.innerHTML = "Select skill first";
        return;
    }

    fetch("GetSubskillsServlet?skillId=" + skillId)
    .then(res => res.json())
    .then(data => {

        subskillContainer.innerHTML = "";

        data.forEach(sub => {
            const label = document.createElement("label");
            label.innerHTML =
                `<input type="checkbox" name="subskill" value="${sub.id}"> ${sub.name}`;
            subskillContainer.appendChild(label);
        });
    });
});

// LOAD AREAS FROM PINCODE



</script>
<script>
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");

/* OPEN / CLOSE */
profileIcon.addEventListener("click", function(e){
    e.stopPropagation();
    profileMenu.style.display =
        profileMenu.style.display === "block" ? "none" : "block";
});

/* 🔥 FIX: prevent closing when clicking inside menu */
profileMenu.addEventListener("click", function(e){
    e.stopPropagation();
});

/* CLOSE when clicking outside */
document.addEventListener("click", function(){
    profileMenu.style.display = "none";
});
</script>
<script>function applyFilters(){

    const q = document.querySelector("input[name='q']").value;
    const district = document.querySelector("input[name='district']").value;
    const min_salary = document.querySelector("input[name='min_salary']").value;
    const max_salary = document.querySelector("input[name='max_salary']").value;

    const jid = "<%= session.getAttribute("jobseekerId") %>";

    // ✅ GET SELECTED AREAS
    let areas = [];
    document.querySelectorAll("input[name='area']:checked").forEach(cb=>{
        areas.push(cb.value);
    });

    // ✅ GET SELECTED SUBSKILLS
    let subskills = [];
    document.querySelectorAll("input[name='subskill']:checked").forEach(cb=>{
        subskills.push(cb.value);
    });

    // 🔥 BUILD QUERY STRING
    let url = "SearchJobsServlet?";
    url += "jid=" + jid;
    url += "&q=" + encodeURIComponent(q);
    url += "&district=" + encodeURIComponent(district);

    areas.forEach(a => url += "&area=" + encodeURIComponent(a));
    subskills.forEach(s => url += "&subskill=" + s);

    if(min_salary) url += "&min_salary=" + min_salary;
    if(max_salary) url += "&max_salary=" + max_salary;

    console.log("Fetching:", url);

    // 🚀 FETCH DATA
    fetch(url)
    .then(res => res.json())
    .then(data => {
        renderJobs(data);
    })
    .catch(err => console.error(err));
}
function renderJobs(jobs){

    const container = document.querySelector(".cards");

    container.innerHTML = ""; // clear old jobs

    if(jobs.length === 0){
        container.innerHTML = "<h3>No jobs found</h3>";
        return;
    }

    jobs.forEach(job => {

        const card = document.createElement("div");

        card.className = "card";
        card.style = "background:white;padding:20px;margin-bottom:20px;border-radius:12px;box-shadow:0 3px 10px rgba(0,0,0,0.08);";

        card.innerHTML = `
            <h3>${job.title}</h3>

            <p><b>Location:</b> ${job.locality}, ${job.city}</p>

            <p><b>Salary:</b> ₹${job.salary}</p>

            <button onclick="viewJob(${job.jobId})"
                style="background:#007bff;color:white;padding:8px 16px;border:none;border-radius:6px;">
                View Job
            </button>
        `;

        container.appendChild(card);
    });
}
</script>
</div>
</body>
</html>
