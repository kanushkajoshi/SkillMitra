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
<h2>JobSeeker Dashboard</h2>
<a class="active" onclick="showSection('dashboard', this)">Dashboard</a>
<a onclick="showSection('applied', this)">Applied Jobs</a>
<a onclick="showSection('assigned', this)">Assigned Job</a>
<a onclick="showSection('payments', this)">Payment History</a>
<a onclick="showSection('reviews', this)">Ratings & Reviews</a>
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
<div id="dashboardSection">
<div class="topbar">
Welcome, <b><%= currentSession.getAttribute("jfirstname") %></b>
</div>

<form class="search-box" method="get" action="search_results.jsp">
    <input type="hidden" name="jid" value="<%= session.getAttribute("jobseekerId") %>">
<input type="text" id="searchInput" name="q" placeholder="Search jobs...">

<button type="button" id="filterBtn">Filters ▼</button>

<button type="submit">Search</button>

<div id="filterContainer" class="filter-container">

<!-- SKILL -->
<label>Skill:</label>

<div class="readonly-box">
<%
Connection conSkill = DBConnection.getConnection();

PreparedStatement psSkill = conSkill.prepareStatement(
    "SELECT DISTINCT s.skill_id, s.skill_name " +
    "FROM skill s " +
    "JOIN jobseeker_skills js ON js.skill_id = s.skill_id " +
    "WHERE js.jid = ?"
);

psSkill.setInt(1, jobseekerId);
ResultSet rsSkill = psSkill.executeQuery();

// ✅ GET FIRST SKILL ID
int firstSkillId = 0;

if(rsSkill.next()){
    firstSkillId = rsSkill.getInt("skill_id");
}

// ✅ RESET CURSOR
rsSkill.beforeFirst();

StringBuilder skillNames = new StringBuilder();

// ✅ LOOP START
while(rsSkill.next()){

    if(skillNames.length() > 0){
        skillNames.append(", ");
    }

    skillNames.append(rsSkill.getString("skill_name"));
%>

    <input type="checkbox"
           name="skill"
           value="<%= rsSkill.getInt("skill_id") %>"
           checked
           hidden>

<%
}
%>

<!-- ✅ IMPORTANT: ONLY ONE -->
<input type="hidden" id="selectedSkillId" value="<%= firstSkillId %>">

<%= skillNames.toString() %>

<%
conSkill.close();
%>

</div>

<!-- SUBSKILL -->
<label>Subskills:</label>

<div class="multi-select">

    <div class="select-box" onclick="toggleSubskill()">
        <span id="subskillText">Select Subskills</span>
    </div>

    <div id="subskillDropdown" class="dropdown">

        <div id="subskillList">
            Select skill first
        </div>

        <button type="button" class="ok-btn" onclick="closeSubskill()">
            OK
        </button>

    </div>

</div>

<!-- DISTRICT -->
<label>District:</label>
<input type="text" name="district"
value="<%= currentSession.getAttribute("jdistrict") %>" readonly>

<!-- AREA -->
<label>Area:</label>
<div class="multi-select">

    <div class="select-box" onclick="toggleArea()">
        <span id="areaText">Select Area</span>
    </div>

    <div id="areaDropdown" class="dropdown">

        <div id="areaContainer"></div>

        <button type="button" class="ok-btn" onclick="closeArea()">
            OK
        </button>

    </div>

</div>

<!-- SALARY -->
<label>Min Salary:</label>
<input type="number" name="min_salary">

<label>Max Salary:</label>
<input type="number" name="max_salary">

<button type="button" id="applyFilter">Apply Filters</button>

</div>
</form>
<%
Connection conStats = DBConnection.getConnection();

PreparedStatement ps1 = conStats.prepareStatement(
    "SELECT COUNT(*) FROM jobs WHERE status='Active'");
ResultSet rs1 = ps1.executeQuery();
rs1.next();
int totalJobs = rs1.getInt(1);
rs1.close(); ps1.close();

PreparedStatement ps2 = conStats.prepareStatement(
    "SELECT COUNT(*) FROM applications WHERE jobseeker_id=?");
ps2.setInt(1, jobseekerId);
ResultSet rs2 = ps2.executeQuery();
rs2.next();
int appliedJobs = rs2.getInt(1);
rs2.close(); ps2.close();

PreparedStatement ps3 = conStats.prepareStatement(
    "SELECT COUNT(*) FROM applications WHERE jobseeker_id=? AND status='Accepted'");
ps3.setInt(1, jobseekerId);
ResultSet rs3 = ps3.executeQuery();
rs3.next();
int acceptedJobs = rs3.getInt(1);
rs3.close(); ps3.close();


conStats.close();
%>
<%
// Bids Placed count
Connection conBids = DBConnection.getConnection();
PreparedStatement psBids = conBids.prepareStatement(
    "SELECT COUNT(*) FROM bids WHERE job_seeker_id=?");
psBids.setInt(1, jobseekerId);
ResultSet rsBids = psBids.executeQuery();
rsBids.next();
int bidsPlaced = rsBids.getInt(1);
rsBids.close(); psBids.close();
conBids.close();
%>

<%-- ── STATS ── --%>
<div class="stats-grid">
    <div class="stat stat-blue">
        <div class="stat-label">Jobs Available</div>
        <div class="stat-value"><%= totalJobs %></div>
    </div>
    <div class="stat stat-amber">
        <div class="stat-label">Applied</div>
        <div class="stat-value"><%= appliedJobs %></div>
    </div>
    <div class="stat stat-green">
        <div class="stat-label">Accepted</div>
        <div class="stat-value"><%= acceptedJobs %></div>
    </div>
    <div class="stat stat-purple">
    <div class="stat-label">Bids Placed</div>
    <div class="stat-value"><%= bidsPlaced %></div>
</div>
</div>

<%-- ── STATUS + RECOMMENDED ROW ── --%>
<div class="section-row">

    <%-- Application Status --%>
    <div class="status-card">
        <h4>Application Status</h4>
        <%
        Connection conStatus = DBConnection.getConnection();
        PreparedStatement psStatus = conStatus.prepareStatement(
            "SELECT status, COUNT(*) as count FROM applications WHERE jobseeker_id=? GROUP BY status"
        );
        psStatus.setInt(1, jobseekerId);
        ResultSet rsStatus = psStatus.executeQuery();

        java.util.Map<String,Integer> statusMap = new java.util.HashMap<String,Integer>();
        while(rsStatus.next()){
            statusMap.put(rsStatus.getString("status"), rsStatus.getInt("count"));
        }
        conStatus.close();

        int pendingCount  = statusMap.getOrDefault("Pending",  0);
        int acceptedCount = statusMap.getOrDefault("Accepted", 0);
        int rejectedCount = statusMap.getOrDefault("Rejected", 0);
        %>
        <div class="status-item">
            <span>Pending</span>
            <span class="badge badge-pending"><%= pendingCount %></span>
        </div>
        <div class="status-item">
            <span>Accepted</span>
            <span class="badge badge-accepted"><%= acceptedCount %></span>
        </div>
        <div class="status-item">
            <span>Rejected</span>
            <span class="badge badge-rejected"><%= rejectedCount %></span>
        </div>
    </div>

    <%-- Recommended Jobs --%>
    <div class="rec-section">
        <h4>Recommended for You</h4>
        <div class="rec-cards">
        <%
        Connection conRec = DBConnection.getConnection();
        PreparedStatement psRec = conRec.prepareStatement(
            "SELECT j.job_id, j.title, j.locality, j.city, j.salary, j.job_type, " +
            "COUNT(DISTINCT js.subskill_id) AS matched, " +
            "COUNT(DISTINCT jk.subskill_id) AS total " +
            "FROM jobs j " +
            "JOIN job_skills jk ON jk.job_id = j.job_id " +
            "LEFT JOIN jobseeker_skills js ON js.subskill_id = jk.subskill_id AND js.jid = ? " +
            "WHERE j.status='Active' " +
            "GROUP BY j.job_id, j.title, j.locality, j.city, j.salary, j.job_type " +
            "HAVING (COUNT(DISTINCT js.subskill_id) * 100 / COUNT(DISTINCT jk.subskill_id)) >= 50 " +
            "ORDER BY matched DESC LIMIT 4"
        );
        psRec.setInt(1, jobseekerId);
        ResultSet rsRec = psRec.executeQuery();
        while(rsRec.next()){
            int matched = rsRec.getInt("matched");
            int total   = rsRec.getInt("total");
            int pct     = (total > 0) ? (matched * 100) / total : 0;
        %>
        <div class="rec-card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">

    <div class="job-title">
        <%= rsRec.getString("title") %>
    </div>

    <span style="font-size:12px; color:#16a34a; font-weight:600;">
        <%= pct %>% match
    </span>

</div>
            <div class="job-loc">📍 <%= rsRec.getString("locality") %>, <%= rsRec.getString("city") %></div>
     
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px;">
    <div class="job-salary">₹<%= rsRec.getString("salary") %></div>
    <div style="display:flex; flex-wrap:wrap; gap:4px; justify-content:flex-end;">
    <%
    Connection conSub = DBConnection.getConnection();
    PreparedStatement psSub = conSub.prepareStatement(
        "SELECT ss.subskill_name FROM subskill ss " +
        "JOIN job_skills jsk ON jsk.subskill_id = ss.subskill_id " +
        "WHERE jsk.job_id = ?"
    );
    psSub.setInt(1, rsRec.getInt("job_id"));
    ResultSet rsSub = psSub.executeQuery();
    while(rsSub.next()){
    %>
        <span style="background:#f0f4ff; color:#3b5bdb; font-size:10px; padding:2px 8px; border-radius:20px; white-space:nowrap;">
            <%= rsSub.getString("subskill_name") %>
        </span>
       
    <%
    }
    rsSub.close(); psSub.close(); conSub.close();
    %>
    </div>
</div>
            <span class="job-type"><%= rsRec.getString("job_type") %></span>
            <a href="job_details.jsp?jobId=<%= rsRec.getInt("job_id") %>" class="rec-view-btn">View Job</a>
        </div>
        <%
        }
        conRec.close();
        %>
        </div>
    </div>

</div>
</div> <%-- closes dashboardSection --%>


<!-- ================= APPLIED SECTION ================= -->
<div id="appliedSection" style="display:none;">
<div class="cards">
<%
Connection conApp = null;
PreparedStatement psApp = null;
ResultSet rsApp = null;

try {
    conApp = DBConnection.getConnection();
    boolean found = false;

   String sqlApp = 
"SELECT j.*, " +
"CASE " +
"WHEN b.bid_id IS NOT NULL THEN b.bid_status " +
"ELSE a.status " +
"END AS final_status, " +
"b.counter_bid, b.bid_id " +

"FROM jobs j " +

"LEFT JOIN bids b ON j.job_id = b.job_id AND b.job_seeker_id = ? " +
"LEFT JOIN applications a ON j.job_id = a.job_id AND a.jobseeker_id = ? " +

"WHERE (a.application_id IS NOT NULL OR b.bid_id IS NOT NULL) " +
"AND j.status='ACTIVE'";

    psApp = conApp.prepareStatement(sqlApp);
    psApp.setInt(1, jobseekerId);
    psApp.setInt(2, jobseekerId);
    rsApp = psApp.executeQuery();

    while(rsApp.next()){
        found = true;

        int counterBid = rsApp.getInt("counter_bid");
        int bidId = rsApp.getInt("bid_id");
        String status = rsApp.getString("final_status");
%>

<div class="card">

    <h3><%= rsApp.getString("title") %></h3>

    <p><b>Description:</b> <%= rsApp.getString("description") %></p>

    <p>📍 <%= rsApp.getString("locality") %>, <%= rsApp.getString("city") %></p>

    <p><b>Salary:</b> ₹<%= rsApp.getString("salary") %></p>

    <!-- STATUS -->
    <span style="
        display:inline-block;
        padding:5px 12px;
        border-radius:20px;
        font-size:12px;
        background:#eef2ff;
        color:#3b5bdb;
        margin-bottom:8px;">
        <%= status %>
    </span>

    <% if("Countered".equals(status)) { %>

        <!-- COUNTER BID -->
        <p style="color:#dc3545; font-weight:600;">
            💸 Employer Countered: ₹<%= counterBid %>
        </p>

        <!-- ACTION BUTTONS -->
        <div style="margin-top:10px; display:flex; gap:10px;">

            <a href="RespondCounterServlet?bid_id=<%= bidId %>&action=accept">
                <button class="btn accept-btn">✓ Accept</button>
            </a>

            <a href="RespondCounterServlet?bid_id=<%= bidId %>&action=reject">
                <button class="btn reject-btn">✕ Reject</button>
            </a>

        </div>

    <% } %>

</div>

<%
    }

    if(!found){
%>
<h3>No Applied Jobs</h3>
<%
    }

} catch(Exception e){ e.printStackTrace(); }
finally {
    if(rsApp != null) try{ rsApp.close(); } catch(Exception e){}
    if(psApp != null) try{ psApp.close(); } catch(Exception e){}
    if(conApp != null) try{ conApp.close(); } catch(Exception e){}
}
%>
</div>
</div>

<!-- ================= ASSIGNED SECTION ================= -->
<div id="assignedSection" style="display:none;">
<div class="cards">
<%
Connection conAss = null;
PreparedStatement psAss = null;
ResultSet rsAss = null;
try {
    conAss = DBConnection.getConnection();
    boolean found = false;

    // ACCEPTED APPLICATIONS
    String sqlApp = "SELECT j.*, a.status FROM applications a " +
                    "JOIN jobs j ON j.job_id = a.job_id " +
                    "WHERE a.jobseeker_id=? AND a.status='Accepted'";

    psAss = conAss.prepareStatement(sqlApp);
    psAss.setInt(1, jobseekerId);
    rsAss = psAss.executeQuery();

    while(rsAss.next()){
        found = true;
%>
<div class="card">
    <h3><%= rsAss.getString("title") %></h3>
    <p>Description: <%= rsAss.getString("description") %></p>
    <p>📍 <%= rsAss.getString("locality") %>, <%= rsAss.getString("city") %></p>
    <p>₹<%= rsAss.getString("salary") %></p>
    <button disabled style="background:#28a745;color:white;">
        ✓ Accepted
    </button>
</div>
<%
    }
    rsAss.close(); psAss.close();

    // ACCEPTED BIDS
    String sqlBid = "SELECT j.*, b.bid_status FROM bids b " +
                    "JOIN jobs j ON j.job_id = b.job_id " +
                    "WHERE b.job_seeker_id=? AND b.bid_status='Accepted'";

    psAss = conAss.prepareStatement(sqlBid);
    psAss.setInt(1, jobseekerId);
    rsAss = psAss.executeQuery();

    while(rsAss.next()){
        found = true;
%>
<div class="card">
    <h3><%= rsAss.getString("title") %></h3>
    <p>Description: <%= rsAss.getString("description") %></p>
    <p>📍 <%= rsAss.getString("locality") %>, <%= rsAss.getString("city") %></p>
    <p>₹<%= rsAss.getString("salary") %></p>
    <button disabled style="background:#28a745;color:white;">
        ✓ Accepted
    </button>
</div>
<%
    }

    if(!found){
%>
<h3>No Assigned Jobs</h3>
<%
    }

} catch(Exception e){ e.printStackTrace(); }
finally {
    if(rsAss != null) try{ rsAss.close(); } catch(Exception e){}
    if(psAss != null) try{ psAss.close(); } catch(Exception e){}
    if(conAss != null) try{ conAss.close(); } catch(Exception e){}
}
%>
</div>
</div>
<!-- ================= PAYMENTS SECTION (JOBSEEKER) ================= -->
<div id="paymentsSection" style="display:none;">
<div class="cards">
<%
Connection conPay = null;
PreparedStatement psPay = null;
ResultSet rsPay = null;
try {
    conPay = DBConnection.getConnection();

   
        String sqlPay =
    "SELECT a.application_id AS ref_id, j.title, j.salary, " +
    "COALESCE(p.status, 'Pending') AS payment_status, " +
    "'application' AS type " +
    "FROM applications a " +
    "JOIN jobs j ON j.job_id = a.job_id " +
    "LEFT JOIN payments p ON a.application_id = p.application_id " +
    "WHERE a.jobseeker_id = ? AND a.status = 'Accepted' " +

    "UNION " +

    "SELECT b.bid_id AS ref_id, j.title, j.salary, " +
    "COALESCE(p.status, 'Pending') AS payment_status, " +
    "'bid' AS type " +
    "FROM bids b " +
    "JOIN jobs j ON j.job_id = b.job_id " +
    "LEFT JOIN payments p ON b.bid_id = p.application_id " +
    "WHERE b.job_seeker_id = ? AND b.bid_status = 'Accepted'";

    psPay = conPay.prepareStatement(sqlPay);
    psPay.setInt(1, jobseekerId);
    psPay.setInt(2, jobseekerId); // ✅ both ? filled
    rsPay = psPay.executeQuery();

    boolean foundPay = false;

    while (rsPay.next()) {
        foundPay = true;
        String payStatus = rsPay.getString("payment_status");
        String type = rsPay.getString("type");
        // badge color
        String color = "#ffc107";
        if ("Requested".equals(payStatus))  color = "#ff9800";
        else if ("Paid".equals(payStatus))  color = "#2196f3";
        else if ("Confirmed".equals(payStatus)) color = "#28a745";
%>

<div class="card" style="border-radius:12px; padding:20px; background:#fff; box-shadow:0 2px 8px rgba(0,0,0,0.08); margin-bottom:16px;">

    <h3 style="margin:0 0 8px;"><%= rsPay.getString("title") %></h3>
    <p style="margin:4px 0;"><b>Salary:</b> ₹<%= rsPay.getString("salary") %></p>
    <p style="margin:4px 0;">
        <b>Payment Status:</b>
        <span style="padding:4px 12px; border-radius:20px; color:#fff; background:<%= color %>; font-size:13px;">
            <%= payStatus %>
        </span>
    </p>

    <div style="margin-top:14px;">

    <%-- ── PENDING: ask the worker first ──────────────────────────────── --%>
    <% if ("Pending".equals(payStatus)) { %>

        <p style="font-weight:600; margin-bottom:10px;">Have you received payment for this job?</p>
        <div style="display:flex; gap:10px;">

            <%-- YES → mark confirmed directly --%>
            <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&type=<%= rsPay.getString("type") %>&action=confirm">
                <button style="background:#28a745; color:#fff; padding:8px 20px;
                               border:none; border-radius:8px; cursor:pointer; font-size:14px;">
                    ✅ Yes, Received
                </button>
            </a>

            <%-- NO → request payment from employer (sends notification) --%>
            <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&type=<%= rsPay.getString("type") %>&action=request">
                <button style="background:#ff9800; color:#fff; padding:8px 20px;
                               border:none; border-radius:8px; cursor:pointer; font-size:14px;">
                    ❌ No, Request Payment
                </button>
            </a>

        </div>

    <%-- ── REQUESTED: waiting for employer ───────────────────────────── --%>
    <% } else if ("Requested".equals(payStatus)) { %>

        <div style="background:#fff8e1; border:1px solid #ffe082; border-radius:8px; padding:12px;">
            <p style="margin:0; color:#795548;">
                ⏳ Payment request sent. Waiting for employer to mark it as paid...
            </p>
        </div>

    <%-- ── PAID: employer marked paid, now worker confirms ────────────── --%>
    <% } else if ("Paid".equals(payStatus)) { %>

        <p style="font-weight:600; margin-bottom:10px;">Employer has marked this as paid. Did you receive it?</p>
        <div style="display:flex; gap:10px;">

            <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=confirm">
                <button style="background:#28a745; color:#fff; padding:8px 20px;
                               border:none; border-radius:8px; cursor:pointer; font-size:14px;">
                    ✅ Yes, Confirm Receipt
                </button>
            </a>

        </div>

    <%-- ── CONFIRMED: done ────────────────────────────────────────────── --%>
    <% } else if ("Confirmed".equals(payStatus)) { %>

        <div style="background:#e8f5e9; border:1px solid #a5d6a7; border-radius:8px; padding:12px;">
            <p style="margin:0; color:#2e7d32; font-weight:600;">✔ Payment completed successfully!</p>
        </div>

    <% } %>

    </div>
</div>

<%
    }

    if (!foundPay) {
%>
    <div style="text-align:center; padding:50px 20px;">
        <h3 style="color:#555;">No Payment Records Yet</h3>
        <p style="color:#999;">Your accepted jobs will appear here once payment flow begins.</p>
    </div>
<%
    }

} catch (Exception e) {
    out.println("<p style='color:red;'>Error loading payments: " + e.getMessage() + "</p>");
    e.printStackTrace();
} finally {
    if (rsPay  != null) try { rsPay.close();  } catch (Exception ignored) {}
    if (psPay  != null) try { psPay.close();  } catch (Exception ignored) {}
    if (conPay != null) try { conPay.close(); } catch (Exception ignored) {}
}
%>
</div>
</div>

<script>
const jobseekerZip = "<%= currentSession.getAttribute("jzip") %>";
console.log("ZIP CODE:", jobseekerZip);
</script>

<script>

// ================= AREA =================
function loadAreas(){

console.log("Fetching areas for:", jobseekerZip);

fetch("https://api.postalpincode.in/pincode/" + jobseekerZip)

.then(function(response){ return response.json(); })

.then(function(data){

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

.catch(function(error){

console.error("API error:", error);
document.getElementById("areaContainer").innerHTML = "Error loading areas";

});

}

loadAreas();


// ================= SEARCH SUGGESTION =================
const searchInput = document.getElementById("searchInput");

const suggestionBox = document.createElement("div");
suggestionBox.id = "suggestionBox";
suggestionBox.style.cssText =
    "position:absolute; background:#fff; border:1px solid #e8edf2; " +
    "border-radius:8px; width:100%; max-height:220px; overflow-y:auto; " +
    "z-index:999; box-shadow:0 4px 12px rgba(0,0,0,0.1); display:none; top:100%; left:0;";

searchInput.parentElement.style.position = "relative";
searchInput.parentNode.insertBefore(suggestionBox, searchInput.nextSibling);

if(searchInput){
    searchInput.addEventListener("keyup", function(){
        const q = this.value.trim();

        if(q.length < 1){
            suggestionBox.style.display = "none";
            suggestionBox.innerHTML = "";
            return;
        }

        fetch("SearchSuggestionServlet?q=" + encodeURIComponent(q))
        .then(function(res){ return res.json(); })
        .then(function(data){

            suggestionBox.innerHTML = "";

            if(data.length === 0){
                suggestionBox.style.display = "none";
                return;
            }

            data.forEach(function(item){
                const div = document.createElement("div");
                div.textContent = item;
                div.style.cssText =
                    "padding:10px 14px; font-size:14px; cursor:pointer; " +
                    "border-bottom:1px solid #f0f2f5; color:#1a2a3a;";

                div.addEventListener("mouseenter", function(){
                    this.style.background = "#f5f8ff";
                });
                div.addEventListener("mouseleave", function(){
                    this.style.background = "#fff";
                });
                div.addEventListener("click", function(){
                    searchInput.value = item;
                    suggestionBox.style.display = "none";
                    suggestionBox.innerHTML = "";
                });

                suggestionBox.appendChild(div);
            });

            suggestionBox.style.display = "block";
        });
    });
}

document.addEventListener("click", function(e){
    if(e.target !== searchInput){
        suggestionBox.style.display = "none";
    }
});
// ================= FILTER TOGGLE =================
const filterBtn = document.getElementById("filterBtn");
const filterBox = document.getElementById("filterContainer");

filterBtn.addEventListener("click", function () {

    if(filterBox.style.display === "block"){
        filterBox.style.display = "none";
    } else {
        filterBox.style.display = "block";
    }

});


// ================= APPLY FILTER BUTTON =================
document.getElementById("applyFilter").addEventListener("click", function(){
    document.getElementById("filterContainer").style.display = "none";
});


// ================= LOAD SUBSKILLS =================
window.onload = function(){
    loadSubskills();
};

function loadSubskills(){
    console.log("Skill ID:", document.getElementById("selectedSkillId")?.value);
    var skillInput = document.getElementById("selectedSkillId");

    if(!skillInput){
        console.log("No skillId found");
        return;
    }

    var skillId = skillInput.value;

    fetch("GetSubskillsServlet?skillId=" + skillId)

    .then(function(res){ return res.json(); })

    .then(function(data){

        var subskillList = document.getElementById("subskillList");
        subskillList.innerHTML = "";

        if(data.length === 0){
            subskillList.innerHTML = "No subskills found";
            return;
        }

        data.forEach(function(sub){

            var label = document.createElement("label");

            label.innerHTML =
                '<input type="checkbox" name="subskill" value="'+sub.id+'"> ' + sub.name;

            subskillList.appendChild(label);
        });

    })

    .catch(function(err){
        console.error("Subskill error:", err);
    });
}


// ================= PROFILE MENU =================
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");

profileIcon.addEventListener("click", function(e){
    e.stopPropagation();
    profileMenu.style.display =
        profileMenu.style.display === "block" ? "none" : "block";
});

profileMenu.addEventListener("click", function(e){
    e.stopPropagation();
});

document.addEventListener("click", function(){
    profileMenu.style.display = "none";
});


// ================= RENDER JOBS =================
function renderJobs(jobs){

    const container = document.querySelector(".cards");
    container.innerHTML = "";

    if(jobs.length === 0){
        container.innerHTML = "<h3>No jobs found</h3>";
        return;
    }

    jobs.forEach(function(job){

        const card = document.createElement("div");
        card.className = "card";

        card.innerHTML =
            "<h3>"+job.title+"</h3>" +
            "<p><b>Location:</b> "+job.locality+", "+job.city+"</p>" +
            "<p><b>Salary:</b> ₹"+job.salary+"</p>" +
            '<button onclick="viewJob('+job.jobId+')">View Job</button>';

        container.appendChild(card);
    });
}


// ================= SECTION SWITCH =================
function showSection(section, el){

   const sections = [
    "dashboardSection",
    "appliedSection",
    "assignedSection",
    "paymentsSection",
    "reviewsSection"
   ];

   sections.forEach(function(id){
        const sec = document.getElementById(id);
        if(sec) sec.style.display = "none";
   });

   if(section === "dashboard") document.getElementById("dashboardSection").style.display = "block";
   else if(section === "applied") document.getElementById("appliedSection").style.display = "block";
   else if(section === "assigned") document.getElementById("assignedSection").style.display = "block";
   else if(section === "payments") document.getElementById("paymentsSection").style.display = "block";
   else if(section === "reviews") document.getElementById("reviewsSection").style.display = "block";

   document.querySelectorAll(".sidebar a").forEach(function(a){
        a.classList.remove("active");
   });

   el.classList.add("active");
}


// ===== SUBSKILL UI (REGISTER STYLE) =====
function toggleSubskill(){
    var d = document.getElementById("subskillDropdown");
    d.style.display = (d.style.display === "block") ? "none" : "block";
}

function closeSubskill(){
    document.getElementById("subskillDropdown").style.display = "none";
    updateSubskillText();
}

function updateSubskillText(){

    var checks = document.querySelectorAll("input[name='subskill']:checked");

    if(checks.length === 0){
        document.getElementById("subskillText").innerText = "Select Subskills";
        return;
    }

    var names = [];

    checks.forEach(function(c){
        names.push(c.parentElement.textContent.trim());
    });

    document.getElementById("subskillText").innerText = names.join(", ");
}


// ===== AREA UI (SAME STYLE) =====
function toggleArea(){
    var d = document.getElementById("areaDropdown");
    d.style.display = (d.style.display === "block") ? "none" : "block";
}

function closeArea(){

    document.getElementById("areaDropdown").style.display = "none";

    var checks = document.querySelectorAll("input[name='area']:checked");

    if(checks.length === 0){
        document.getElementById("areaText").innerText = "Select Area";
        return;
    }

    var names = [];

    checks.forEach(function(c){
        names.push(c.parentElement.textContent.trim());
    });

    document.getElementById("areaText").innerText = names.join(", ");
}
// ── Read URL param and show correct section on page load ──
document.addEventListener("DOMContentLoaded", function () {
    const params = new URLSearchParams(window.location.search);
    const section = params.get("section");

    if (section === "payments") {
        // find the payments sidebar link and simulate click
        document.querySelectorAll(".sidebar a").forEach(function(a) {
            if (a.getAttribute("onclick") && a.getAttribute("onclick").includes("payments")) {
                showSection("payments", a);
            }
        });
    }
});
</script>
</div>
</body>
</html>  
