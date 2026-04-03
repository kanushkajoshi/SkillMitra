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
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>
<div class="sidebar" id="sidebar">
<h2>JobSeeker Dashboard</h2>
<a class="active" onclick="showSection('dashboard', this)">
    <i class="fa-solid fa-house nav-icon"></i>
    <span class="nav-label"> Dashboard</span>
</a>
<a onclick="showSection('applied', this)">
    <i class="fa-solid fa-file-lines nav-icon"></i>
    <span class="nav-label"> Applied Jobs</span>
</a>
<a onclick="showSection('assigned', this)">
    <i class="fa-solid fa-briefcase nav-icon"></i>
    <span class="nav-label"> Assigned Job</span>
</a>
<a onclick="showSection('payments', this)">
    <i class="fa-solid fa-clock-rotate-left nav-icon"></i>
    <span class="nav-label"> Payment History</span>
</a>
<a onclick="showSection('reviews', this)">
    <i class="fa-solid fa-star nav-icon"></i>
    <span class="nav-label"> Ratings & Reviews</span>
</a>
</div>

<div class="main">

<div class="navbar">
<div style="display:flex; align-items:center; gap:12px;">
    <button class="hamburger" id="hamburger">&#9776;</button>
    <img src="skillmitralogo.jpg" alt="Logo" style="width:35px; height:35px; border-radius:50%; object-fit:cover;">
    <div class="nav-left">SkillMitra</div>
</div>
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
<%-- ── PROFILE COMPLETION BAR ── --%>
<%
Connection conProf = null;
try {
    conProf = DBConnection.getConnection();
    PreparedStatement psProf = conProf.prepareStatement(
        "SELECT jfirstname, jlastname, jphone, jdistrict, jzip, jeducation, jphoto " +
        "FROM jobseeker WHERE jid=?"
    );
    psProf.setInt(1, jobseekerId);
    ResultSet rsProf = psProf.executeQuery();

    int profScore = 0;
    int profTotal = 7;
    String profTip = "";

    if(rsProf.next()){
        if(rsProf.getString("jfirstname") != null && !rsProf.getString("jfirstname").isEmpty()) profScore++;
        if(rsProf.getString("jphone")     != null && !rsProf.getString("jphone").isEmpty())     profScore++;
        else profTip = "Add your phone number. ";
        if(rsProf.getString("jdistrict")  != null && !rsProf.getString("jdistrict").isEmpty())  profScore++;
        if(rsProf.getString("jzip")       != null && !rsProf.getString("jzip").isEmpty())       profScore++;
        else profTip += "Add your ZIP code. ";
        if(rsProf.getString("jeducation") != null && !rsProf.getString("jeducation").isEmpty()) profScore++;
        else profTip += "Add your education. ";
        if(rsProf.getString("jphoto")     != null && !rsProf.getString("jphoto").isEmpty())     profScore++;
        else profTip += "Upload a profile photo. ";
    }
    rsProf.close(); psProf.close();

    // check skills
    PreparedStatement psProfSkill = conProf.prepareStatement(
        "SELECT COUNT(*) FROM jobseeker_skills WHERE jid=?"
    );
    psProfSkill.setInt(1, jobseekerId);
    ResultSet rsProfSkill = psProfSkill.executeQuery();
    if(rsProfSkill.next() && rsProfSkill.getInt(1) > 0) profScore++;
    else profTip += "Add your skills.";
    rsProfSkill.close(); psProfSkill.close();

    int profPct = (profScore * 100) / profTotal;
    String barColor = profPct < 40 ? "#ef4444" : profPct < 70 ? "#f59e0b" : "#22c55e";
    String profLabel = profPct < 40 ? "Just started" : profPct < 70 ? "Getting there!" : profPct < 100 ? "Almost complete!" : "Complete!";
%>

<div style="background:#fff; border:1px solid #e8edf2; border-radius:12px;
            padding:16px 20px; margin:16px 0; box-shadow:0 1px 4px rgba(0,0,0,0.05);">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <span style="font-size:14px; font-weight:600; color:#1a2a3a;">
            Profile Completion
        </span>
        <span style="font-size:13px; font-weight:700; color:<%= barColor %>;">
            <%= profPct %>% — <%= profLabel %>
        </span>
    </div>

    <div style="background:#f0f2f5; border-radius:20px; height:8px; overflow:hidden;">
        <div style="height:8px; border-radius:20px; width:<%= profPct %>%;
                    background:<%= barColor %>; transition:width 0.5s ease;">
        </div>
    </div>

    <% if(profPct < 100 && !profTip.isEmpty()){ %>
    <p style="font-size:12px; color:#6b7280; margin:8px 0 0;">
        💡 <%= profTip %>
        <a href="jobseeker_profile.jsp"
           style="color:#3b5bdb; font-weight:600; text-decoration:none;">
            Complete Profile →
        </a>
    </p>
    <% } %>
</div>

<%
} catch(Exception e){ e.printStackTrace(); }
finally { if(conProf != null) try{ conProf.close(); }catch(Exception ignored){} }
%>
<form class="search-box" method="get" action="search_results.jsp">
    <input type="hidden" name="jid" value="<%= session.getAttribute("jobseekerId") %>">
<input type="text" id="searchInput" name="q" placeholder="Search by skill or area...">

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
<%-- ── RECENT ACTIVITY FEED ── --%>
<div style="background:#fff; border:1px solid #e8edf2; border-radius:12px;
            padding:20px; margin-top:20px; box-shadow:0 1px 4px rgba(0,0,0,0.05);">
    <h4 style="margin:0 0 16px; font-size:16px; color:#1a2a3a;">Recent Activity</h4>

<%
Connection conAct = null;
try {
    conAct = DBConnection.getConnection();
    PreparedStatement psAct = conAct.prepareStatement(
        "SELECT * FROM ( " +

        "SELECT 'applied'  AS type, j.title, a.applied_at AS event_time, NULL AS extra " +
        "FROM applications a JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE a.jobseeker_id=? " +

        "UNION ALL " +

        "SELECT CASE WHEN a.status='Accepted' THEN 'accepted' ELSE 'rejected' END AS type, " +
        "j.title, a.applied_at AS event_time, NULL AS extra " +
        "FROM applications a JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE a.jobseeker_id=? AND a.status IN ('Accepted','Rejected') " +

        "UNION ALL " +

        "SELECT 'bid' AS type, j.title, b.created_at AS event_time, " +
        "CAST(b.bid_amount AS CHAR) AS extra " +
        "FROM bids b JOIN jobs j ON b.job_id=j.job_id " +
        "WHERE b.job_seeker_id=? " +

        "UNION ALL " +

        "SELECT 'countered' AS type, j.title, b.created_at AS event_time, " +
        "CAST(b.counter_bid AS CHAR) AS extra " +
        "FROM bids b JOIN jobs j ON b.job_id=j.job_id " +
        "WHERE b.job_seeker_id=? AND b.counter_bid > 0 " +

        "UNION ALL " +

        "SELECT 'payment' AS type, j.title, p.updated_at AS event_time, NULL AS extra " +
        "FROM payments p " +
        "JOIN applications a ON p.application_id=a.application_id " +
        "JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE a.jobseeker_id=? AND p.status='Confirmed' " +

        ") AS activity ORDER BY event_time DESC LIMIT 6"
    );
    psAct.setInt(1, jobseekerId);
    psAct.setInt(2, jobseekerId);
    psAct.setInt(3, jobseekerId);
    psAct.setInt(4, jobseekerId);
    psAct.setInt(5, jobseekerId);
    ResultSet rsAct = psAct.executeQuery();

    boolean anyAct = false;
    while(rsAct.next()){
        anyAct = true;
        String actType  = rsAct.getString("type");
        String actTitle = rsAct.getString("title");
        String actExtra = rsAct.getString("extra");
        String actDate  = new java.text.SimpleDateFormat("dd MMM yyyy")
                            .format(rsAct.getTimestamp("event_time"));
        String icon, msg, dotColor;
        if("applied".equals(actType)){
            icon="📝"; dotColor="#eef2ff"; msg="Applied to <b>"+actTitle+"</b>";
        } else if("accepted".equals(actType)){
            icon="✅"; dotColor="#dcfce7"; msg="Accepted for <b>"+actTitle+"</b>";
        } else if("rejected".equals(actType)){
            icon="❌"; dotColor="#fee2e2"; msg="Not selected for <b>"+actTitle+"</b>";
        } else if("bid".equals(actType)){
            icon="💰"; dotColor="#fff7ed"; msg="Placed a bid of ₹"+actExtra+" on <b>"+actTitle+"</b>";
        } else if("countered".equals(actType)){
            icon="🔄"; dotColor="#fff7ed"; msg="Employer countered with ₹"+actExtra+" on <b>"+actTitle+"</b>";
        } else if("payment".equals(actType)){
            icon="💸"; dotColor="#dcfce7"; msg="Payment confirmed for <b>"+actTitle+"</b>";
        } else {
            icon="📌"; dotColor="#f3f4f6"; msg=actTitle;
        }
        %>
    <div style="display:flex; align-items:flex-start; gap:14px; margin-bottom:14px;">

        <div style="font-size:20px; width:36px; height:36px; border-radius:50%;
                    background:<%= dotColor %>; display:flex; align-items:center;
                    justify-content:center; flex-shrink:0;">
            <%= icon %>
        </div>

        <div style="flex:1;">
            <p style="margin:0; font-size:14px; color:#374151; line-height:1.5;">
                <%= msg %>
            </p>
            <span style="font-size:12px; color:#9ca3af;"><%= actDate %></span>
        </div>

    </div>
<%
    }
    if(!anyAct){
%>
    <div style="text-align:center; padding:24px; color:#9ca3af;">
        <div style="font-size:28px; margin-bottom:8px;">📋</div>
        <p style="margin:0; font-size:14px;">No activity yet. Start by applying to a job!</p>
    </div>
<%
    }
    rsAct.close(); psAct.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conAct != null) try{ conAct.close(); }catch(Exception ignored){} }
%>
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

    "b.counter_bid, " +
    "b.bid_amount, " +
    "b.bid_id, " +

    // 🔥 FINAL SALARY LOGIC
    "CASE " +
    "WHEN b.bid_id IS NOT NULL AND b.bid_status='Accepted' AND b.counter_bid IS NOT NULL THEN b.counter_bid " +
    "WHEN b.bid_id IS NOT NULL AND b.bid_status='Accepted' THEN b.bid_amount " +
    "WHEN b.bid_id IS NOT NULL AND b.bid_status='Rejected' THEN 0 " +
    "WHEN b.bid_id IS NOT NULL AND b.counter_bid IS NOT NULL THEN b.counter_bid " +
    "WHEN b.bid_id IS NOT NULL THEN b.bid_amount " +
    "ELSE j.salary " +
    "END AS final_salary " +

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
        int finalSalary = rsApp.getInt("final_salary");
%>

<div class="card">

    <h3><%= rsApp.getString("title") %></h3>

    <p><b>Description:</b> <%= rsApp.getString("description") %></p>
    

    <p>📍 <%= rsApp.getString("locality") %>, <%= rsApp.getString("city") %></p>

    <!-- 🔥 STATUS -->
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

    <!-- 🔥 FINAL SALARY DISPLAY -->
    <%
    String label = "Posted Salary";

    if(rsApp.getObject("bid_id") != null){
        if(counterBid > 0){
            label = "Counter Offer";
        } else {
            label = "Your Bid";
        }
    }
    %>

    <% if(finalSalary > 0){ %>
        <p><b><%= label %>:</b> ₹<%= finalSalary %></p>
    <% } else { %>
        <p style="color:red; font-weight:600;">❌ Application Rejected</p>
    <% } %>

    <!-- 🔥 COUNTER ACTION -->
    <% if("Countered".equalsIgnoreCase(status)) { %>

        <p style="color:#dc3545; font-weight:600;">
            💸 Employer Countered: ₹<%= counterBid %>
        </p>

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
    String sqlApp = 
"SELECT j.*, a.status, j.salary AS final_salary " +
"FROM applications a " +
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
    
</div>
<%
    }
    rsAss.close(); psAss.close();

    // ACCEPTED BIDS
   String sqlBid = 
"SELECT j.*, b.bid_status, b.bid_amount, b.counter_bid, " +

"CASE " +
"WHEN b.counter_bid IS NOT NULL AND b.counter_bid > 0 THEN b.counter_bid " +
"ELSE b.bid_amount " +
"END AS final_salary " +

"FROM bids b " +
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
    <p><b>Final Salary:</b> ₹<%= rsAss.getInt("final_salary") %></p>

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

    <p style="font-weight:600; margin-bottom:10px;">
        Employer has marked this as paid. Did you receive it?
    </p>

    <div style="display:flex; gap:10px;">

        <!-- ✅ YES BUTTON -->
        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=confirm&type=<%= rsPay.getString("type") %>">
            <button style="background:#28a745; color:#fff; padding:8px 20px;
                           border:none; border-radius:8px; cursor:pointer; font-size:14px;">
                ✅ Yes, Received
            </button>
        </a>

        <!-- ❌ NO BUTTON -->
        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=notreceived&type=<%= rsPay.getString("type") %>">
            <button style="background:#dc3545; color:#fff; padding:8px 20px;
                           border:none; border-radius:8px; cursor:pointer; font-size:14px;">
                ❌ Not Received
            </button>
        </a>

    </div>

<%-- ── CONFIRMED: done ────────────────────────────────────────────── --%>
<% } else if ("Confirmed".equals(payStatus)) { %>

    <div style="background:#e8f5e9; border:1px solid #a5d6a7; border-radius:8px; padding:12px;">
        <p style="margin:0; color:#2e7d32; font-weight:600;">
            ✔ Payment completed successfully!
        </p>
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

<%--
  ================================================================
  FILE: js_reviews_section.jsp  (include or paste into jobseeker_dashboard.jsp)
  Drop this inside the <div class="main"> of jobseeker_dashboard.jsp.
  The sidebar link already calls showSection('reviews', this).
  Add 'reviewsSection' to the sections[] array in showSection().
  ================================================================
--%>

<!-- ================= JOBSEEKER → RATE & REVIEW SECTION ================= -->
<!-- ================= JOBSEEKER → RATE & REVIEW SECTION ================= -->
<div id="reviewsSection" style="display:none;">
<div style="padding:2rem 1.5rem; max-width:820px; font-family:inherit;">

<%
HttpSession currentSession2 = request.getSession(false);
String ratingSuccessJs = (String) currentSession2.getAttribute("ratingMsg_js_success");
String ratingErrorJs   = (String) currentSession2.getAttribute("ratingMsg_js_error");
if (ratingSuccessJs != null) { currentSession2.removeAttribute("ratingMsg_js_success"); }
if (ratingErrorJs   != null) { currentSession2.removeAttribute("ratingMsg_js_error"); }
%>

<% if (ratingSuccessJs != null) { %>
<div style="background:#EAF3DE;border:0.5px solid #97C459;border-radius:10px;
            padding:12px 16px;color:#3B6D11;font-size:14px;font-weight:500;margin-bottom:1.5rem;">
    ✓ &nbsp;<%= ratingSuccessJs %>
</div>
<% } %>
<% if (ratingErrorJs != null) { %>
<div style="background:#FCEBEB;border:0.5px solid #F09595;border-radius:10px;
            padding:12px 16px;color:#A32D2D;font-size:14px;font-weight:500;margin-bottom:1.5rem;">
    ! &nbsp;<%= ratingErrorJs %>
</div>
<% } %>

<%-- ── SECTION: Rate employers ── --%>
<p style="font-size:11px;font-weight:500;letter-spacing:0.08em;text-transform:uppercase;
          color:var(--color-text-tertiary);margin:0 0 1rem;">Ratings & Reviews</p>
<h2 style="font-size:20px;font-weight:500;color:var(--color-text-primary);margin:0 0 4px;">Rate Employers</h2>
<p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 1.5rem;">
    Leave a review after payment has been confirmed
</p>

<%
int jobseekerId2 = (Integer) currentSession2.getAttribute("jobseekerId");
Connection conJsRev = null;
PreparedStatement psJsRev = null;
ResultSet rsJsRev = null;
try {
    conJsRev = db.DBConnection.getConnection();
    String sqlJsRev =
        "SELECT j.job_id, j.title, j.eid AS employer_id, " +
        "CONCAT(e.efirstname,' ',e.elastname) AS employer_name, e.ecompanyname, " +
        "r.rating_id AS already_rated " +
        "FROM applications a " +
        "JOIN jobs j ON j.job_id = a.job_id " +
        "JOIN employer e ON e.eid = j.eid " +
        "JOIN payments p ON p.application_id = a.application_id " +
        "LEFT JOIN ratings r ON r.job_id = j.job_id " +
        "    AND r.employer_id = j.eid " +
        "    AND r.jobseeker_id = a.jobseeker_id " +
        "    AND r.rating_by = 'Jobseeker' " +
        "WHERE a.jobseeker_id = ? AND a.status = 'Accepted' AND p.status = 'Confirmed' " +
        "UNION " +
        "SELECT j.job_id, j.title, j.eid AS employer_id, " +
        "CONCAT(e.efirstname,' ',e.elastname) AS employer_name, e.ecompanyname, " +
        "r.rating_id AS already_rated " +
        "FROM bids b " +
        "JOIN jobs j ON j.job_id = b.job_id " +
        "JOIN employer e ON e.eid = j.eid " +
        "JOIN payments p ON p.application_id = b.bid_id " +
        "LEFT JOIN ratings r ON r.job_id = j.job_id " +
        "    AND r.employer_id = j.eid " +
        "    AND r.jobseeker_id = b.job_seeker_id " +
        "    AND r.rating_by = 'Jobseeker' " +
        "WHERE b.job_seeker_id = ? AND b.bid_status = 'Accepted' AND p.status = 'Confirmed' " +
        "ORDER BY job_id DESC";
    psJsRev = conJsRev.prepareStatement(sqlJsRev);
    psJsRev.setInt(1, jobseekerId2);
    psJsRev.setInt(2, jobseekerId2);
    //rsJsRev = conJsRev.executeQuery(sqlJsRev); // use psJsRev!
    rsJsRev = psJsRev.executeQuery();

    boolean anyJsRow = false;
    while (rsJsRev.next()) {
        anyJsRow = true;
        boolean jsRated = (rsJsRev.getObject("already_rated") != null);
        String empName = rsJsRev.getString("employer_name");
        String initials = "";
        if (empName != null && empName.contains(" ")) {
            String[] parts = empName.trim().split(" ");
            initials = ("" + parts[0].charAt(0) + parts[parts.length-1].charAt(0)).toUpperCase();
        } else if (empName != null && empName.length() > 0) {
            initials = ("" + empName.charAt(0)).toUpperCase();
        }
        String companyName = rsJsRev.getString("ecompanyname");
        if (companyName == null) companyName = "";
%>
<%-- Employer card --%>
<div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);
            border-radius:var(--border-radius-lg);padding:1.25rem 1.5rem;margin-bottom:12px;
            display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;">
    <div style="width:42px;height:42px;border-radius:50%;background:#E6F1FB;
                display:flex;align-items:center;justify-content:center;
                font-size:14px;font-weight:500;color:#185FA5;flex-shrink:0;">
        <%= initials %>
    </div>
    <div style="flex:1;min-width:0;">
        <p style="font-size:15px;font-weight:500;color:var(--color-text-primary);margin:0 0 2px;
                  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
            <%= empName %>
        </p>
        <p style="font-size:13px;color:var(--color-text-secondary);margin:0 0 8px;">
            <%= companyName.isEmpty() ? "" : companyName + " &nbsp;·&nbsp; " %>
            <%= rsJsRev.getString("title") %>
        </p>
        <% if (jsRated) { %>
        <span style="display:inline-block;background:#EAF3DE;color:#3B6D11;
                     font-size:12px;font-weight:500;padding:3px 10px;border-radius:20px;">
            Review submitted
        </span>
        <% } else { %>
        <span style="display:inline-block;background:#FAEEDA;color:#854F0B;
                     font-size:12px;font-weight:500;padding:3px 10px;border-radius:20px;">
            Pending your review
        </span>
        <% } %>
    </div>
    <% if (!jsRated) { %>
    <a href="rating_form.jsp?job_id=<%= rsJsRev.getInt("job_id") %>&employer_id=<%= rsJsRev.getInt("employer_id") %>&jobseeker_id=<%= jobseekerId2 %>&rating_by=Jobseeker"
       style="text-decoration:none;flex-shrink:0;">
        <button style="background:#1D9E75;color:#fff;border:none;border-radius:var(--border-radius-md);
                       padding:9px 20px;font-size:14px;font-weight:500;cursor:pointer;white-space:nowrap;">
            Rate employer
        </button>
    </a>
    <% } else { %>
    <button disabled style="background:var(--color-background-secondary);color:var(--color-text-tertiary);
                            border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);
                            padding:9px 20px;font-size:14px;white-space:nowrap;cursor:default;">
        Submitted
    </button>
    <% } %>
</div>
<%
    }
    if (!anyJsRow) {
%>
<div style="text-align:center;padding:3rem 1rem;color:var(--color-text-tertiary);
            background:var(--color-background-secondary);border-radius:var(--border-radius-lg);">
    <div style="font-size:28px;margin-bottom:12px;">⭐</div>
    <p style="font-size:15px;color:var(--color-text-secondary);margin:0 0 6px;font-weight:500;">
        No completed jobs yet
    </p>
    <p style="font-size:13px;margin:0;">Review option appears after payment is confirmed.</p>
</div>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rsJsRev  != null) try { rsJsRev.close();  } catch(Exception ignored){}
    if (psJsRev  != null) try { psJsRev.close();  } catch(Exception ignored){}
    if (conJsRev != null) try { conJsRev.close(); } catch(Exception ignored){}
}
%>

<%-- ── DIVIDER ── --%>
<hr style="border:none;border-top:0.5px solid var(--color-border-tertiary);margin:2.5rem 0;">

<%-- ── SECTION: Reviews received ── --%>
<p style="font-size:11px;font-weight:500;letter-spacing:0.08em;text-transform:uppercase;
          color:var(--color-text-tertiary);margin:0 0 1rem;">Reviews from employers</p>
<h2 style="font-size:20px;font-weight:500;color:var(--color-text-primary);margin:0 0 4px;">Your Reviews</h2>
<p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 1.5rem;">
    What employers say about your work
</p>

<%
Connection conJsMyRev = null;
PreparedStatement psJsMyRev = null;
ResultSet rsJsMyRev = null;
try {
    conJsMyRev = db.DBConnection.getConnection();

    PreparedStatement psAvgJs = conJsMyRev.prepareStatement(
        "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
        "FROM ratings WHERE jobseeker_id=? AND rating_by='Employer'"
    );
    psAvgJs.setInt(1, jobseekerId2);
    ResultSet rsAvgJs = psAvgJs.executeQuery();
    double avgRjs = 0; int totalRjs = 0;
    if (rsAvgJs.next()) { avgRjs = rsAvgJs.getDouble("avg_r"); totalRjs = rsAvgJs.getInt("total"); }
    rsAvgJs.close(); psAvgJs.close();
%>

<%-- Score summary box --%>
<div style="background:var(--color-background-secondary);border-radius:var(--border-radius-lg);
            padding:1.25rem 1.5rem;display:flex;align-items:center;gap:20px;margin-bottom:1.5rem;">
    <div>
        <div style="font-size:36px;font-weight:500;color:var(--color-text-primary);line-height:1;">
            <%= totalRjs > 0 ? String.format("%.1f", avgRjs) : "—" %>
        </div>
        <div style="display:flex;gap:3px;margin-top:6px;">
<%
        if (totalRjs > 0) {
            int full = (int) Math.floor(avgRjs);
            for (int si = 1; si <= 5; si++) {
                if (si <= full) {
                    out.print("<span style='color:#BA7517;font-size:16px;'>★</span>");
                } else {
                    out.print("<span style='color:var(--color-border-secondary);font-size:16px;'>★</span>");
                }
            }
        }
%>
        </div>
    </div>
    <div>
        <div style="font-size:15px;font-weight:500;color:var(--color-text-primary);">Overall rating</div>
        <div style="font-size:13px;color:var(--color-text-secondary);margin-top:4px;">
            <%= totalRjs > 0 ? "Based on " + totalRjs + " review" + (totalRjs!=1?"s":"") : "No reviews yet" %>
        </div>
    </div>
</div>

<%
    psJsMyRev = conJsMyRev.prepareStatement(
        "SELECT r.rating_value, r.review_text, r.created_at, " +
        "r.work_quality, r.performance, r.punctuality, r.professional_behavior, " +
        "CONCAT(e.efirstname,' ',e.elastname) AS reviewer_name, " +
        "e.ecompanyname, j.title AS job_title " +
        "FROM ratings r " +
        "JOIN employer e ON e.eid = r.employer_id " +
        "JOIN jobs j ON j.job_id = r.job_id " +
        "WHERE r.jobseeker_id=? AND r.rating_by='Employer' " +
        "ORDER BY r.created_at DESC"
    );
    psJsMyRev.setInt(1, jobseekerId2);
    rsJsMyRev = psJsMyRev.executeQuery();
    boolean anyJsReview = false;

    while (rsJsMyRev.next()) {
        anyJsReview = true;
        double rv = rsJsMyRev.getDouble("rating_value");
        String reviewerName = rsJsMyRev.getString("reviewer_name");
        String co2 = rsJsMyRev.getString("ecompanyname");
        if (co2 == null) co2 = "";
        String reviewText = rsJsMyRev.getString("review_text");
        int wq = rsJsMyRev.getInt("work_quality");
        int pf = rsJsMyRev.getInt("performance");
        int pu = rsJsMyRev.getInt("punctuality");
        int pb = rsJsMyRev.getInt("professional_behavior");
        String dateStr = new java.text.SimpleDateFormat("dd MMM yyyy")
                            .format(rsJsMyRev.getTimestamp("created_at"));
%>
<%-- Review card --%>
<div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);
            border-radius:var(--border-radius-lg);padding:1.25rem 1.5rem;margin-bottom:12px;">
    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px;">
        <div>
            <p style="font-size:14px;font-weight:500;color:var(--color-text-primary);margin:0 0 2px;">
                <%= reviewerName %>
            </p>
            <p style="font-size:12px;color:var(--color-text-tertiary);margin:0;">
                <%= co2.isEmpty() ? "" : co2 + " · " %>
                <%= rsJsMyRev.getString("job_title") %>
                &nbsp;·&nbsp; <%= dateStr %>
            </p>
        </div>
        <span style="background:#FAEEDA;color:#633806;font-size:13px;font-weight:500;
                     padding:4px 10px;border-radius:var(--border-radius-md);white-space:nowrap;flex-shrink:0;">
            <%= String.format("%.1f", rv) %> ★
        </span>
    </div>
    <%-- Criteria tags --%>
    <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px;">
        <% if (wq > 0) { %><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Work quality: <%= wq %>/5</span><% } %>
        <% if (pf > 0) { %><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Performance: <%= pf %>/5</span><% } %>
        <% if (pu > 0) { %><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Punctuality: <%= pu %>/5</span><% } %>
        <% if (pb > 0) { %><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Professionalism: <%= pb %>/5</span><% } %>
    </div>
    <% if (reviewText != null && !reviewText.trim().isEmpty()) { %>
    <p style="font-size:14px;color:var(--color-text-secondary);line-height:1.6;margin:0 0 10px;
              border-left:2px solid var(--color-border-secondary);padding-left:12px;">
        <%= reviewText.trim() %>
    </p>
    <% } %>
</div>
<%
    }
    if (!anyJsReview) {
%>
<div style="text-align:center;padding:3rem 1rem;color:var(--color-text-tertiary);
            background:var(--color-background-secondary);border-radius:var(--border-radius-lg);">
    <p style="font-size:15px;color:var(--color-text-secondary);margin:0;font-weight:500;">
        No reviews received yet
    </p>
</div>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rsJsMyRev  != null) try { rsJsMyRev.close();  } catch(Exception ignored){}
    if (psJsMyRev  != null) try { psJsMyRev.close();  } catch(Exception ignored){}
    if (conJsMyRev != null) try { conJsMyRev.close(); } catch(Exception ignored){}
}
%>

</div><%-- inner padding div --%>
</div><%-- reviewsSection --%>


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

    if (section) {
        document.querySelectorAll(".sidebar a").forEach(function(a) {
            const oc = a.getAttribute("onclick") || "";
            if (oc.includes("'" + section + "'") || oc.includes('"' + section + '"')) {
                showSection(section, a);
            }
        });
    }
});

//sidebar
// ================= HAMBURGER TOGGLE =================
const hamburger = document.getElementById("hamburger");
const sidebar   = document.getElementById("sidebar");

// jobseeker uses .main, employer uses .content
const mainContent = document.querySelector(".main") || document.querySelector(".content");
const navbar      = document.querySelector(".navbar") || document.querySelector("header");

hamburger.addEventListener("click", function(){
    sidebar.classList.toggle("collapsed");
    hamburger.classList.toggle("collapsed");
    if(mainContent) mainContent.classList.toggle("collapsed");
    if(navbar)      navbar.classList.toggle("collapsed");
});
</script>
</div>
</body>
</html>  
