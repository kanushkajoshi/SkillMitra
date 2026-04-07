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
PreparedStatement psName = conName.prepareStatement(
    "SELECT jfirstname, jlastname, jdistrict, jzip FROM jobseeker WHERE jid=?");
psName.setInt(1, jobseekerId);
ResultSet rsName = psName.executeQuery();
if (rsName.next()) {
    currentSession.setAttribute("jfirstname", rsName.getString("jfirstname"));
    currentSession.setAttribute("jlastname",  rsName.getString("jlastname"));
    currentSession.setAttribute("jdistrict",  rsName.getString("jdistrict"));
    String zip = rsName.getString("jzip");
    if (zip != null) currentSession.setAttribute("jzip", zip);
}
rsName.close(); psName.close(); conName.close();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Seeker Dashboard | SkillMitra</title>
<link rel="stylesheet" href="jobseeker_dash.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
.neg-thread {
    display:flex; flex-direction:column; gap:8px;
    margin:10px 0 14px; padding:12px 16px;
    background:#f8fafc; border-radius:10px;
    border:0.5px solid #e2e8f0;
    max-height:240px; overflow-y:auto;
}
.neg-bubble { display:flex; gap:10px; align-items:flex-start; }
.neg-bubble.you { flex-direction:row-reverse; }
.neg-dot {
    width:28px; height:28px; border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    font-size:11px; font-weight:700; flex-shrink:0;
}
/* Jobseeker dot = blue, Employer dot = green */
.neg-dot.js-dot  { background:#dbeafe; color:#1d4ed8; }
.neg-dot.emp-dot { background:#dcfce7; color:#166534; }
.neg-content {
    background:#fff; border:0.5px solid #e5e7eb;
    border-radius:10px; padding:8px 12px;
    max-width:72%; font-size:13px; line-height:1.5;
}
/* "you" bubble (right side) gets a blue tint for jobseeker */
.neg-bubble.you .neg-content { background:#eff6ff; border-color:#bfdbfe; }
.neg-amount { font-size:15px; font-weight:700; color:#1a2a3a; }
.neg-action { font-size:11px; color:#9ca3af; margin-top:2px; }
.neg-note   { font-size:12px; color:#6b7280; font-style:italic; margin-top:3px; }
.neg-date   { font-size:10px; color:#c0c7d1; margin-top:4px; }
.bid-pill { display:inline-block; font-size:11px; font-weight:600;
            padding:3px 10px; border-radius:20px; margin-top:5px; }
.pill-pending    { background:#fef9c3; color:#854d0e; }
.pill-countered  { background:#fff7ed; color:#9a3412; }
.pill-jsAccepted { background:#dbeafe; color:#1e40af; }
.pill-accepted   { background:#dcfce7; color:#166534; }
.pill-rejected   { background:#fee2e2; color:#991b1b; }
.pill-jscounter  { background:#ede9fe; color:#6d28d9; }
</style>
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

    <!-- ═══════════════════════════════════════════════════════════
         SECTION 1: DASHBOARD
    ═══════════════════════════════════════════════════════════ -->
    <div id="dashboardSection">
        <div class="topbar">
            Welcome, <b><%= currentSession.getAttribute("jfirstname") %></b>
        </div>

        <%-- Profile Completion Bar --%>
        <%
        Connection conProf = null;
        try {
            conProf = DBConnection.getConnection();
            PreparedStatement psProf = conProf.prepareStatement(
                "SELECT jfirstname, jlastname, jphone, jdistrict, jzip, jeducation, jphoto " +
                "FROM jobseeker WHERE jid=?");
            psProf.setInt(1, jobseekerId);
            ResultSet rsProf = psProf.executeQuery();
            int profScore = 0; int profTotal = 7; String profTip = "";
            if (rsProf.next()) {
                if (rsProf.getString("jfirstname") != null && !rsProf.getString("jfirstname").isEmpty()) profScore++;
                if (rsProf.getString("jphone")     != null && !rsProf.getString("jphone").isEmpty())     profScore++;
                else profTip = "Add your phone number. ";
                if (rsProf.getString("jdistrict")  != null && !rsProf.getString("jdistrict").isEmpty())  profScore++;
                if (rsProf.getString("jzip")       != null && !rsProf.getString("jzip").isEmpty())       profScore++;
                else profTip += "Add your ZIP code. ";
                if (rsProf.getString("jeducation") != null && !rsProf.getString("jeducation").isEmpty()) profScore++;
                else profTip += "Add your education. ";
                if (rsProf.getString("jphoto")     != null && !rsProf.getString("jphoto").isEmpty())     profScore++;
                else profTip += "Upload a profile photo. ";
            }
            rsProf.close(); psProf.close();
            PreparedStatement psProfSkill = conProf.prepareStatement(
                "SELECT COUNT(*) FROM jobseeker_skills WHERE jid=?");
            psProfSkill.setInt(1, jobseekerId);
            ResultSet rsProfSkill = psProfSkill.executeQuery();
            if (rsProfSkill.next() && rsProfSkill.getInt(1) > 0) profScore++;
            else profTip += "Add your skills.";
            rsProfSkill.close(); psProfSkill.close();
            int profPct = (profScore * 100) / profTotal;
            String barColor  = profPct < 40 ? "#ef4444" : profPct < 70 ? "#f59e0b" : "#22c55e";
            String profLabel = profPct < 40 ? "Just started" : profPct < 70 ? "Getting there!" : profPct < 100 ? "Almost complete!" : "Complete!";
        %>
        <div style="background:#fff; border:1px solid #e8edf2; border-radius:12px;
                    padding:16px 20px; margin:16px 0; box-shadow:0 1px 4px rgba(0,0,0,0.05);">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                <span style="font-size:14px; font-weight:600; color:#1a2a3a;">Profile Completion</span>
                <span style="font-size:13px; font-weight:700; color:<%= barColor %>;">
                    <%= profPct %>% — <%= profLabel %>
                </span>
            </div>
            <div style="background:#f0f2f5; border-radius:20px; height:8px; overflow:hidden;">
                <div style="height:8px; border-radius:20px; width:<%= profPct %>%;
                            background:<%= barColor %>; transition:width 0.5s ease;"></div>
            </div>
            <% if (profPct < 100 && !profTip.isEmpty()) { %>
            <p style="font-size:12px; color:#6b7280; margin:8px 0 0;">
                💡 <%= profTip %>
                <a href="jobseeker_profile.jsp" style="color:#3b5bdb; font-weight:600; text-decoration:none;">
                    Complete Profile →
                </a>
            </p>
            <% } %>
        </div>
        <%
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conProf != null) try { conProf.close(); } catch (Exception ignored) {} }
        %>

        <%-- Search Box --%>
        <form class="search-box" method="get" action="search_results.jsp">
            <input type="hidden" name="jid" value="<%= session.getAttribute("jobseekerId") %>">
            <input type="text" id="searchInput" name="q" placeholder="Search by skill or area...">
            <button type="button" id="filterBtn">Filters ▼</button>
            <button type="submit">Search</button>
            <div id="filterContainer" class="filter-container">
                <label>Skill:</label>
                <div class="readonly-box">
                <%
                Connection conSkill = DBConnection.getConnection();
                PreparedStatement psSkill = conSkill.prepareStatement(
                    "SELECT DISTINCT s.skill_id, s.skill_name FROM skill s " +
                    "JOIN jobseeker_skills js ON js.skill_id = s.skill_id WHERE js.jid = ?");
                psSkill.setInt(1, jobseekerId);
                ResultSet rsSkill = psSkill.executeQuery();
                int firstSkillId = 0;
                if (rsSkill.next()) { firstSkillId = rsSkill.getInt("skill_id"); }
                rsSkill.beforeFirst();
                StringBuilder skillNames = new StringBuilder();
                while (rsSkill.next()) {
                    if (skillNames.length() > 0) skillNames.append(", ");
                    skillNames.append(rsSkill.getString("skill_name"));
                %>
                    <input type="checkbox" name="skill" value="<%= rsSkill.getInt("skill_id") %>" checked hidden>
                <%
                }
                %>
                <input type="hidden" id="selectedSkillId" value="<%= firstSkillId %>">
                <%= skillNames.toString() %>
                <% rsSkill.close(); psSkill.close(); conSkill.close(); %>
                </div>
                <label>Subskills:</label>
                <div class="multi-select">
                    <div class="select-box" onclick="toggleSubskill()"><span id="subskillText">Select Subskills</span></div>
                    <div id="subskillDropdown" class="dropdown">
                        <div id="subskillList">Select skill first</div>
                        <button type="button" class="ok-btn" onclick="closeSubskill()">OK</button>
                    </div>
                </div>
                <label>District:</label>
                <input type="text" name="district" value="<%= currentSession.getAttribute("jdistrict") %>" readonly>
                <label>Area:</label>
                <div class="multi-select">
                    <div class="select-box" onclick="toggleArea()"><span id="areaText">Select Area</span></div>
                    <div id="areaDropdown" class="dropdown">
                        <div id="areaContainer"></div>
                        <button type="button" class="ok-btn" onclick="closeArea()">OK</button>
                    </div>
                </div>
                <label>Min Salary:</label>
                <input type="number" name="min_salary">
                <label>Max Salary:</label>
                <input type="number" name="max_salary">
                <button type="button" id="applyFilter">Apply Filters</button>
            </div>
        </form>

        <%-- Stats --%>
        <%
        Connection conStats = DBConnection.getConnection();
        PreparedStatement ps1 = conStats.prepareStatement("SELECT COUNT(*) FROM jobs WHERE status='Active'");
        ResultSet rs1 = ps1.executeQuery(); rs1.next(); int totalJobs = rs1.getInt(1); rs1.close(); ps1.close();
        PreparedStatement ps2 = conStats.prepareStatement("SELECT COUNT(*) FROM applications WHERE jobseeker_id=?");
        ps2.setInt(1, jobseekerId); ResultSet rs2 = ps2.executeQuery(); rs2.next(); int appliedJobs = rs2.getInt(1); rs2.close(); ps2.close();
        PreparedStatement ps3 = conStats.prepareStatement("SELECT COUNT(*) FROM applications WHERE jobseeker_id=? AND status='Accepted'");
        ps3.setInt(1, jobseekerId); ResultSet rs3 = ps3.executeQuery(); rs3.next(); int acceptedJobs = rs3.getInt(1); rs3.close(); ps3.close();
        conStats.close();
        Connection conBids = DBConnection.getConnection();
        PreparedStatement psBids = conBids.prepareStatement("SELECT COUNT(*) FROM bids WHERE job_seeker_id=?");
        psBids.setInt(1, jobseekerId); ResultSet rsBids = psBids.executeQuery(); rsBids.next(); int bidsPlaced = rsBids.getInt(1); rsBids.close(); psBids.close(); conBids.close();
        %>
        <div class="stats-grid">
            <div class="stat stat-blue"><div class="stat-label">Jobs Available</div><div class="stat-value"><%= totalJobs %></div></div>
            <div class="stat stat-amber"><div class="stat-label">Applied</div><div class="stat-value"><%= appliedJobs %></div></div>
            <div class="stat stat-green"><div class="stat-label">Accepted</div><div class="stat-value"><%= acceptedJobs %></div></div>
            <div class="stat stat-purple"><div class="stat-label">Bids Placed</div><div class="stat-value"><%= bidsPlaced %></div></div>
        </div>

        <div class="section-row">
            <div class="status-card">
                <h4>Application Status</h4>
                <%
                Connection conStatus = DBConnection.getConnection();
                PreparedStatement psStatus = conStatus.prepareStatement(
                    "SELECT status, COUNT(*) as count FROM applications WHERE jobseeker_id=? GROUP BY status");
                psStatus.setInt(1, jobseekerId);
                ResultSet rsStatus = psStatus.executeQuery();
                java.util.Map<String,Integer> statusMap = new java.util.HashMap<String,Integer>();
                while (rsStatus.next()) { statusMap.put(rsStatus.getString("status"), rsStatus.getInt("count")); }
                conStatus.close();
                int pendingCount  = statusMap.getOrDefault("Pending",  0);
                int acceptedCount = statusMap.getOrDefault("Accepted", 0);
                int rejectedCount = statusMap.getOrDefault("Rejected", 0);
                %>
                <div class="status-item"><span>Pending</span><span class="badge badge-pending"><%= pendingCount %></span></div>
                <div class="status-item"><span>Accepted</span><span class="badge badge-accepted"><%= acceptedCount %></span></div>
                <div class="status-item"><span>Rejected</span><span class="badge badge-rejected"><%= rejectedCount %></span></div>
            </div>

            <div class="rec-section">
                <h4>Recommended for You</h4>
                <div class="rec-cards">
                <%
                Connection conRec = DBConnection.getConnection();
                PreparedStatement psRec = conRec.prepareStatement(
                    "SELECT j.job_id, j.title, j.locality, j.city, j.salary, j.job_type, " +
                    "COUNT(DISTINCT js.subskill_id) AS matched, COUNT(DISTINCT jk.subskill_id) AS total " +
                    "FROM jobs j JOIN job_skills jk ON jk.job_id = j.job_id " +
                    "LEFT JOIN jobseeker_skills js ON js.subskill_id = jk.subskill_id AND js.jid = ? " +
                    "WHERE j.status='Active' " +
                    "GROUP BY j.job_id, j.title, j.locality, j.city, j.salary, j.job_type " +
                    "HAVING (COUNT(DISTINCT js.subskill_id) * 100 / COUNT(DISTINCT jk.subskill_id)) >= 50 " +
                    "ORDER BY matched DESC LIMIT 4");
                psRec.setInt(1, jobseekerId);
                ResultSet rsRec = psRec.executeQuery();
                while (rsRec.next()) {
                    int matched = rsRec.getInt("matched"); int total = rsRec.getInt("total");
                    int pct = (total > 0) ? (matched * 100) / total : 0;
                %>
                <div class="rec-card">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                        <div class="job-title"><%= rsRec.getString("title") %></div>
                        <span style="font-size:12px; color:#16a34a; font-weight:600;"><%= pct %>% match</span>
                    </div>
                    <div class="job-loc">📍 <%= rsRec.getString("locality") %>, <%= rsRec.getString("city") %></div>
                    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px;">
                        <div class="job-salary">₹<%= rsRec.getString("salary") %></div>
                        <div style="display:flex; flex-wrap:wrap; gap:4px; justify-content:flex-end;">
                        <%
                        Connection conSub = DBConnection.getConnection();
                        PreparedStatement psSub = conSub.prepareStatement(
                            "SELECT ss.subskill_name FROM subskill ss JOIN job_skills jsk ON jsk.subskill_id = ss.subskill_id WHERE jsk.job_id = ?");
                        psSub.setInt(1, rsRec.getInt("job_id"));
                        ResultSet rsSub = psSub.executeQuery();
                        while (rsSub.next()) {
                        %>
                        <span style="background:#f0f4ff; color:#3b5bdb; font-size:10px; padding:2px 8px; border-radius:20px; white-space:nowrap;">
                            <%= rsSub.getString("subskill_name") %>
                        </span>
                        <% } rsSub.close(); psSub.close(); conSub.close(); %>
                        </div>
                    </div>
                    <span class="job-type"><%= rsRec.getString("job_type") %></span>
                    <a href="job_details.jsp?jobId=<%= rsRec.getInt("job_id") %>" class="rec-view-btn">View Job</a>
                </div>
                <% } conRec.close(); %>
                </div>
            </div>
        </div>

        <div style="background:#fff; border:1px solid #e8edf2; border-radius:12px;
                    padding:20px; margin-top:20px; box-shadow:0 1px 4px rgba(0,0,0,0.05);">
            <h4 style="margin:0 0 16px; font-size:16px; color:#1a2a3a;">Recent Activity</h4>
            <%
            Connection conAct = null;
            try {
                conAct = DBConnection.getConnection();
                PreparedStatement psAct = conAct.prepareStatement(
                    "SELECT * FROM ( " +
                    "SELECT 'applied' AS type, j.title, a.applied_at AS event_time, NULL AS extra " +
                    "FROM applications a JOIN jobs j ON a.job_id=j.job_id WHERE a.jobseeker_id=? " +
                    "UNION ALL " +
                    "SELECT CASE WHEN a.status='Accepted' THEN 'accepted' ELSE 'rejected' END AS type, " +
                    "j.title, a.applied_at AS event_time, NULL AS extra " +
                    "FROM applications a JOIN jobs j ON a.job_id=j.job_id " +
                    "WHERE a.jobseeker_id=? AND a.status IN ('Accepted','Rejected') " +
                    "UNION ALL " +
                    "SELECT 'bid' AS type, j.title, b.created_at AS event_time, CAST(b.bid_amount AS CHAR) AS extra " +
                    "FROM bids b JOIN jobs j ON b.job_id=j.job_id WHERE b.job_seeker_id=? " +
                    "UNION ALL " +
                    "SELECT 'countered' AS type, j.title, b.created_at AS event_time, CAST(b.counter_bid AS CHAR) AS extra " +
                    "FROM bids b JOIN jobs j ON b.job_id=j.job_id WHERE b.job_seeker_id=? AND b.counter_bid > 0 " +
                    "UNION ALL " +
                    "SELECT 'payment' AS type, j.title, p.updated_at AS event_time, NULL AS extra " +
                    "FROM payments p JOIN applications a ON p.application_id=a.application_id " +
                    "JOIN jobs j ON a.job_id=j.job_id WHERE a.jobseeker_id=? AND p.status='Confirmed' " +
                    ") AS activity ORDER BY event_time DESC LIMIT 6");
                psAct.setInt(1, jobseekerId); psAct.setInt(2, jobseekerId);
                psAct.setInt(3, jobseekerId); psAct.setInt(4, jobseekerId); psAct.setInt(5, jobseekerId);
                ResultSet rsAct = psAct.executeQuery();
                boolean anyAct = false;
                while (rsAct.next()) {
                    anyAct = true;
                    String actType  = rsAct.getString("type");
                    String actTitle = rsAct.getString("title");
                    String actExtra = rsAct.getString("extra");
                    String actDate  = new java.text.SimpleDateFormat("dd MMM yyyy").format(rsAct.getTimestamp("event_time"));
                    String icon, msg, dotColor;
                    if      ("applied".equals(actType))   { icon="📝"; dotColor="#eef2ff"; msg="Applied to <b>"+actTitle+"</b>"; }
                    else if ("accepted".equals(actType))  { icon="✅"; dotColor="#dcfce7"; msg="Accepted for <b>"+actTitle+"</b>"; }
                    else if ("rejected".equals(actType))  { icon="❌"; dotColor="#fee2e2"; msg="Not selected for <b>"+actTitle+"</b>"; }
                    else if ("bid".equals(actType))       { icon="💰"; dotColor="#fff7ed"; msg="Placed a bid of ₹"+actExtra+" on <b>"+actTitle+"</b>"; }
                    else if ("countered".equals(actType)) { icon="🔄"; dotColor="#fff7ed"; msg="Employer countered with ₹"+actExtra+" on <b>"+actTitle+"</b>"; }
                    else if ("payment".equals(actType))   { icon="💸"; dotColor="#dcfce7"; msg="Payment confirmed for <b>"+actTitle+"</b>"; }
                    else                                  { icon="📌"; dotColor="#f3f4f6"; msg=actTitle; }
            %>
                <div style="display:flex; align-items:flex-start; gap:14px; margin-bottom:14px;">
                    <div style="font-size:20px; width:36px; height:36px; border-radius:50%; background:<%= dotColor %>;
                                display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                        <%= icon %>
                    </div>
                    <div style="flex:1;">
                        <p style="margin:0; font-size:14px; color:#374151; line-height:1.5;"><%= msg %></p>
                        <span style="font-size:12px; color:#9ca3af;"><%= actDate %></span>
                    </div>
                </div>
            <%
                }
                if (!anyAct) {
            %>
                <div style="text-align:center; padding:24px; color:#9ca3af;">
                    <div style="font-size:28px; margin-bottom:8px;">📋</div>
                    <p style="margin:0; font-size:14px;">No activity yet. Start by applying to a job!</p>
                </div>
            <%
                }
                rsAct.close(); psAct.close();
            } catch (Exception e) { e.printStackTrace(); }
            finally { if (conAct != null) try { conAct.close(); } catch (Exception ignored) {} }
            %>
        </div>

    </div><%-- END dashboardSection --%>


    <!-- ═══════════════════════════════════════════════════════════
         SECTION 2: APPLIED JOBS
    ═══════════════════════════════════════════════════════════ -->
    <div id="appliedSection" style="display:none;">

        <%
        int jsUserId = (Integer) currentSession.getAttribute("jobseekerId");
        Connection conApplied = null;
        try {
            conApplied = DBConnection.getConnection();

            // A. Regular Applications (non-bid)
            PreparedStatement psRegApp = conApplied.prepareStatement(
                "SELECT j.job_id, j.title, j.description, j.locality, j.city, " +
                "       j.salary, a.status, a.applied_at " +
                "FROM   applications a JOIN jobs j ON j.job_id = a.job_id " +
                "WHERE  a.jobseeker_id = ? AND a.is_bid = 0 AND j.status = 'ACTIVE' " +
                "ORDER  BY a.applied_at DESC");
            psRegApp.setInt(1, jsUserId);
            ResultSet rsRegApp = psRegApp.executeQuery();
            boolean anyReg = false;
            while (rsRegApp.next()) {
                anyReg = true;
                String appStatus  = rsRegApp.getString("status");
                String badgeColor = "#ffc107";
                if ("Accepted".equals(appStatus)) badgeColor = "#28a745";
                else if ("Rejected".equals(appStatus)) badgeColor = "#ef4444";
        %>
            <div style="background:#fff; border:0.5px solid #e5e7eb; border-radius:12px;
                        padding:18px 20px; margin-bottom:14px;">
                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <h3 style="margin:0 0 6px; font-size:16px; color:#1a2a3a;"><%= rsRegApp.getString("title") %></h3>
                        <div style="font-size:13px; color:#6b7280; margin-bottom:6px;">
                            📍 <%= rsRegApp.getString("locality") %>, <%= rsRegApp.getString("city") %>
                            &nbsp;·&nbsp; ₹<%= rsRegApp.getString("salary") %>
                        </div>
                        <p style="font-size:13px; color:#374151; margin:0; line-height:1.5;"><%= rsRegApp.getString("description") %></p>
                    </div>
                    <span style="background:<%= badgeColor %>; color:#fff; padding:4px 12px; border-radius:20px;
                                 font-size:12px; font-weight:600; white-space:nowrap; flex-shrink:0; margin-left:16px;">
                        <%= appStatus %>
                    </span>
                </div>
            </div>
        <%
            }
            rsRegApp.close(); psRegApp.close();

            // B. Bids with negotiation thread
            PreparedStatement psBids2 = conApplied.prepareStatement(
                "SELECT b.bid_id, b.job_id, b.bid_amount, b.counter_bid, " +
                "       b.bid_status, b.current_amount, b.round_number, " +
                "       j.title, j.description, j.locality, j.city, j.salary, j.eid " +
                "FROM   bids b JOIN jobs j ON j.job_id = b.job_id " +
                "WHERE  b.job_seeker_id = ? ORDER BY b.bid_id DESC");
            psBids2.setInt(1, jsUserId);
            ResultSet rsBids2 = psBids2.executeQuery();
            boolean anyBid = false;
            while (rsBids2.next()) {
                anyBid = true;
                int    bidId3     = rsBids2.getInt("bid_id");
                String bStatus    = rsBids2.getString("bid_status");
                int    currentAmt = rsBids2.getInt("current_amount");
                if (currentAmt == 0) currentAmt = rsBids2.getInt("bid_amount");
                int    roundNum   = rsBids2.getInt("round_number");

                String pillClass, pillLabel;
                if      ("Pending".equals(bStatus))              { pillClass="pill-pending";    pillLabel="Awaiting employer"; }
                else if ("Countered".equals(bStatus))            { pillClass="pill-countered";  pillLabel="Employer countered – your turn"; }
                else if ("JobseekerCountered".equals(bStatus))   { pillClass="pill-jscounter";  pillLabel="You countered – awaiting employer"; }
                else if ("JobseekerAccepted".equals(bStatus))    { pillClass="pill-jsAccepted"; pillLabel="You accepted – awaiting employer confirmation"; }
                else if ("Accepted".equals(bStatus))             { pillClass="pill-accepted";   pillLabel="✅ Accepted – Job Assigned!"; }
                else if ("Rejected".equals(bStatus) || "RejectedByJobseeker".equals(bStatus)) { pillClass="pill-rejected"; pillLabel="Rejected"; }
                else                                             { pillClass="pill-pending";    pillLabel=bStatus; }

                PreparedStatement psH = conApplied.prepareStatement(
                    "SELECT actor, action, amount, note, created_at " +
                    "FROM bid_negotiations WHERE bid_id = ? ORDER BY neg_id ASC");
                psH.setInt(1, bidId3);
                ResultSet rsH = psH.executeQuery();
        %>
            <div style="background:#fff; border:0.5px solid
                        <%= "Accepted".equals(bStatus) ? "#86efac" :
                           ("Rejected".equals(bStatus)||"RejectedByJobseeker".equals(bStatus)) ? "#fca5a5" :
                           "Countered".equals(bStatus) ? "#fcd34d" : "#e5e7eb" %>;
                        border-radius:12px; padding:18px 20px; margin-bottom:14px;">

                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:10px;">
                    <div>
                        <h3 style="margin:0 0 4px; font-size:16px; color:#1a2a3a;"><%= rsBids2.getString("title") %></h3>
                        <div style="font-size:13px; color:#6b7280;">
                            📍 <%= rsBids2.getString("locality") %>, <%= rsBids2.getString("city") %>
                            &nbsp;·&nbsp; Round <%= roundNum %>
                        </div>
                        <span class="bid-pill <%= pillClass %>"><%= pillLabel %></span>
                    </div>
                    <div style="text-align:right;">
                        <div style="font-size:20px; font-weight:800; color:#1a2a3a;">₹<%= currentAmt %></div>
                        <div style="font-size:11px; color:#9ca3af;">
                            <%= "Accepted".equals(bStatus) ? "Final salary" : "Current offer" %>
                        </div>
                    </div>
                </div>

                <%-- ══ NEGOTIATION THREAD — JOBSEEKER VIEW ══
                     isMine  = Jobseeker row  → right side ("you"), blue dot
                     !isMine = Employer row   → left  side,        green dot
                --%>
                <div class="neg-thread">
                <%
                boolean anyH = false;
                while (rsH.next()) {
                    anyH = true;
                    String hActor  = rsH.getString("actor");  // "Employer" or "Jobseeker"
                    String hAction = rsH.getString("action");
                    int    hAmt    = rsH.getInt("amount");
                    boolean amtNull = rsH.wasNull();           // check IMMEDIATELY after getInt
                    String hNote   = rsH.getString("note");
                    String hDate   = new java.text.SimpleDateFormat("dd MMM, HH:mm")
                                        .format(rsH.getTimestamp("created_at"));

                    // In jobseeker view: MY moves are Jobseeker rows → right side
                    boolean isMine   = "Jobseeker".equals(hActor);
                    String bubbleCls = isMine ? "you" : "";          // "you" = right-aligned
                    String dotCls    = isMine ? "js-dot" : "emp-dot"; // blue or green
                    String dotLbl    = isMine ? "You" : "Emp";

                    String aLabel;
                    if      ("Bid".equals(hAction))     aLabel = "Initial bid";
                    else if ("Counter".equals(hAction)) aLabel = "Counter offer";
                    else if ("Accept".equals(hAction))  aLabel = "Accepted ✓";
                    else if ("Reject".equals(hAction))  aLabel = "Rejected ✗";
                    else                                aLabel = hAction;
                %>
                    <div class="neg-bubble <%= bubbleCls %>">
                        <div class="neg-dot <%= dotCls %>"><%= dotLbl %></div>
                        <div class="neg-content">
                            <div class="neg-action"><%= aLabel %></div>
                            <% if (!amtNull && hAmt > 0) { %>
                            <div class="neg-amount">₹<%= hAmt %></div>
                            <% } %>
                            <% if (hNote != null && !hNote.isEmpty()) { %>
                            <div class="neg-note">"<%= hNote %>"</div>
                            <% } %>
                            <div class="neg-date"><%= hDate %></div>
                        </div>
                    </div>
                <%
                }
                if (!anyH) {
                %>
                    <div style="font-size:13px; color:#9ca3af; text-align:center;">
                        Bid placed – waiting for employer...
                    </div>
                <%
                }
                rsH.close(); psH.close();
                %>
                </div><%-- end neg-thread --%>

                <%
                if ("Countered".equalsIgnoreCase(bStatus)) {
                %>
                    <div style="background:#fffbeb; border:0.5px solid #fcd34d; border-radius:10px;
                                padding:12px 16px; margin-bottom:12px; font-size:13px; color:#92400e;">
                        🔔 Employer countered with <strong>₹<%= currentAmt %></strong>. Accept, reject, or propose a different amount.
                    </div>
                    <div style="display:flex; flex-wrap:wrap; gap:10px; align-items:flex-end;">
                        <a href="RespondCounterServlet?bid_id=<%= bidId3 %>&action=accept" style="text-decoration:none;">
                            <button style="background:#ecfdf5; color:#166534; border:0.5px solid #bbf7d0;
                                           border-radius:8px; padding:8px 20px; font-size:13px; font-weight:600; cursor:pointer;">
                                ✅ Accept Counter
                            </button>
                        </a>
                        <a href="RespondCounterServlet?bid_id=<%= bidId3 %>&action=reject"
                           onclick="return confirm('Decline this negotiation?');" style="text-decoration:none;">
                            <button style="background:#fef2f2; color:#991b1b; border:0.5px solid #fca5a5;
                                           border-radius:8px; padding:8px 20px; font-size:13px; font-weight:600; cursor:pointer;">
                                ❌ Reject
                            </button>
                        </a>
                        <form action="CounterBidServlet" method="post"
                              style="display:flex; gap:6px; align-items:center; flex:1; min-width:220px;">
                            <input type="hidden" name="bid_id" value="<%= bidId3 %>">
                            <input type="hidden" name="submitted_by" value="jobseeker">
                            <input type="number" name="counter_amount" placeholder="Your counter (₹)" required min="1"
                                   style="font-size:13px; padding:8px 12px; border-radius:8px; flex:1;
                                          border:0.5px solid #e5e7eb; background:#f9fafb; color:#374151;">
                            <input type="text" name="note" placeholder="Note (optional)"
                                   style="font-size:13px; padding:8px 10px; border-radius:8px;
                                          border:0.5px solid #e5e7eb; background:#f9fafb; color:#374151; width:110px;">
                            <button type="submit"
                                    style="background:#ede9fe; color:#6d28d9; border:0.5px solid #c4b5fd;
                                           border-radius:8px; padding:8px 16px; font-size:13px; font-weight:600; cursor:pointer;">
                                🔁 Counter Back
                            </button>
                        </form>
                    </div>
                <%
                } else if ("JobseekerAccepted".equalsIgnoreCase(bStatus)) {
                %>
                    <div style="background:#eff6ff; border:0.5px solid #bfdbfe; border-radius:10px;
                                padding:12px 16px; font-size:13px; color:#1d4ed8;">
                        ⏳ You accepted the employer's counter. Waiting for their final confirmation...
                    </div>
                <%
                } else if ("Accepted".equalsIgnoreCase(bStatus)) {
                %>
                    <div style="background:#dcfce7; border:0.5px solid #86efac; border-radius:10px;
                                padding:12px 16px; font-size:13px; color:#166534; font-weight:600;">
                        🎉 Congratulations! Job assigned at ₹<%= currentAmt %>. Check Assigned Jobs for details.
                    </div>
                <%
                } else if ("Rejected".equalsIgnoreCase(bStatus) || "RejectedByJobseeker".equalsIgnoreCase(bStatus)) {
                %>
                    <div style="background:#fee2e2; border:0.5px solid #fca5a5; border-radius:10px;
                                padding:12px 16px; font-size:13px; color:#991b1b;">
                        This negotiation has ended without agreement.
                    </div>
                <%
                } else {
                %>
                    <div style="background:#f9fafb; border:0.5px solid #e5e7eb; border-radius:10px;
                                padding:12px 16px; font-size:13px; color:#6b7280;">
                        ⏳ Waiting for employer to respond...
                    </div>
                <%
                }
                %>
            </div><%-- end bid card --%>
        <%
            }
            rsBids2.close(); psBids2.close();

            if (!anyReg && !anyBid) {
        %>
            <div style="text-align:center; padding:50px 20px; color:#9ca3af;">
                <div style="font-size:32px; margin-bottom:10px;">📋</div>
                <h3 style="color:#6b7280;">No applications yet</h3>
                <p>Find jobs that match your skills and apply or place a bid.</p>
            </div>
        <%
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            out.println("<p style='color:red;'>Error loading applications: " + ex.getMessage() + "</p>");
        } finally {
            if (conApplied != null) try { conApplied.close(); } catch (Exception ignored) {}
        }
        %>

    </div><%-- END appliedSection --%>


    <!-- ═══════════════════════════════════════════════════════════
         SECTION 3: ASSIGNED JOBS
    ═══════════════════════════════════════════════════════════ -->
    <div id="assignedSection" style="display:none;">
        <div class="cards">
        <%
        Connection conAss = null;
        try {
            conAss = DBConnection.getConnection();
            boolean found = false;
            PreparedStatement psAss = conAss.prepareStatement(
                "SELECT j.*, a.status, j.salary AS final_salary FROM applications a " +
                "JOIN jobs j ON j.job_id = a.job_id " +
                "WHERE a.jobseeker_id=? AND a.status='Accepted'");
            psAss.setInt(1, jobseekerId);
            ResultSet rsAss = psAss.executeQuery();
            while (rsAss.next()) {
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
            PreparedStatement psAssBid = conAss.prepareStatement(
                "SELECT j.*, b.bid_status, b.bid_amount, b.counter_bid, " +
                "CASE WHEN b.counter_bid IS NOT NULL AND b.counter_bid > 0 THEN b.counter_bid ELSE b.bid_amount END AS final_salary " +
                "FROM bids b JOIN jobs j ON j.job_id = b.job_id " +
                "WHERE b.job_seeker_id=? AND b.bid_status='Accepted'");
            psAssBid.setInt(1, jobseekerId);
            ResultSet rsAssBid = psAssBid.executeQuery();
            while (rsAssBid.next()) {
                found = true;
        %>
            <div class="card">
                <h3><%= rsAssBid.getString("title") %></h3>
                <p>Description: <%= rsAssBid.getString("description") %></p>
                <p>📍 <%= rsAssBid.getString("locality") %>, <%= rsAssBid.getString("city") %></p>
                <p><b>Final Salary:</b> ₹<%= rsAssBid.getInt("final_salary") %></p>
            </div>
        <%
            }
            rsAssBid.close(); psAssBid.close();
            if (!found) { %><h3>No Assigned Jobs</h3><% }
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conAss != null) try { conAss.close(); } catch (Exception ignored) {} }
        %>
        </div>
    </div><%-- END assignedSection --%>


    <!-- ═══════════════════════════════════════════════════════════
         SECTION 4: PAYMENTS
    ═══════════════════════════════════════════════════════════ -->
    <div id="paymentsSection" style="display:none;">
        <div class="cards">
        <%
        Connection conPay = null;
        try {
            conPay = DBConnection.getConnection();
            PreparedStatement psPay = conPay.prepareStatement(
                "SELECT a.application_id AS ref_id, j.title, j.salary, " +
                "COALESCE(p.status, 'Pending') AS payment_status, 'application' AS type " +
                "FROM applications a JOIN jobs j ON j.job_id = a.job_id " +
                "LEFT JOIN payments p ON a.application_id = p.application_id " +
                "WHERE a.jobseeker_id = ? AND a.status = 'Accepted' " +
                "UNION " +
                "SELECT b.bid_id AS ref_id, j.title, j.salary, " +
                "COALESCE(p.status, 'Pending') AS payment_status, 'bid' AS type " +
                "FROM bids b JOIN jobs j ON j.job_id = b.job_id " +
                "LEFT JOIN payments p ON b.bid_id = p.application_id " +
                "WHERE b.job_seeker_id = ? AND b.bid_status = 'Accepted'");
            psPay.setInt(1, jobseekerId);
            psPay.setInt(2, jobseekerId);
            ResultSet rsPay = psPay.executeQuery();
            boolean foundPay = false;
            while (rsPay.next()) {
                foundPay = true;
                String payStatus = rsPay.getString("payment_status");
                String color = "#ffc107";
                if ("Requested".equals(payStatus))  color = "#ff9800";
                else if ("Paid".equals(payStatus))  color = "#2196f3";
                else if ("Confirmed".equals(payStatus)) color = "#28a745";
        %>
            <div class="card" style="border-radius:12px; padding:20px; background:#fff;
                                     box-shadow:0 2px 8px rgba(0,0,0,0.08); margin-bottom:16px;">
                <h3 style="margin:0 0 8px;"><%= rsPay.getString("title") %></h3>
                <p style="margin:4px 0;"><b>Salary:</b> ₹<%= rsPay.getString("salary") %></p>
                <p style="margin:4px 0;">
                    <b>Payment Status:</b>
                    <span style="padding:4px 12px; border-radius:20px; color:#fff; background:<%= color %>; font-size:13px;">
                        <%= payStatus %>
                    </span>
                </p>
                <div style="margin-top:14px;">
                <% if ("Pending".equals(payStatus)) { %>
                    <p style="font-weight:600; margin-bottom:10px;">Have you received payment for this job?</p>
                    <div style="display:flex; gap:10px;">
                        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&type=<%= rsPay.getString("type") %>&action=confirm">
                            <button style="background:#28a745; color:#fff; padding:8px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px;">✅ Yes, Received</button>
                        </a>
                        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&type=<%= rsPay.getString("type") %>&action=request">
                            <button style="background:#ff9800; color:#fff; padding:8px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px;">❌ No, Request Payment</button>
                        </a>
                    </div>
                <% } else if ("Requested".equals(payStatus)) { %>
                    <div style="background:#fff8e1; border:1px solid #ffe082; border-radius:8px; padding:12px;">
                        <p style="margin:0; color:#795548;">⏳ Payment request sent. Waiting for employer to mark it as paid...</p>
                    </div>
                <% } else if ("Paid".equals(payStatus)) { %>
                    <p style="font-weight:600; margin-bottom:10px;">Employer has marked this as paid. Did you receive it?</p>
                    <div style="display:flex; gap:10px;">
                        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=confirm&type=<%= rsPay.getString("type") %>">
                            <button style="background:#28a745; color:#fff; padding:8px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px;">✅ Yes, Received</button>
                        </a>
                        <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=notreceived&type=<%= rsPay.getString("type") %>">
                            <button style="background:#dc3545; color:#fff; padding:8px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px;">❌ Not Received</button>
                        </a>
                    </div>
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
            rsPay.close(); psPay.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conPay != null) try { conPay.close(); } catch (Exception ignored) {} }
        %>
        </div>
    </div><%-- END paymentsSection --%>


    <!-- ═══════════════════════════════════════════════════════════
         SECTION 5: RATINGS & REVIEWS
    ═══════════════════════════════════════════════════════════ -->
    <div id="reviewsSection" style="display:none;">
    <div style="padding:2rem 1.5rem; max-width:820px; font-family:inherit;">

        <%
        String ratingSuccessJs = (String) currentSession.getAttribute("ratingMsg_js_success");
        String ratingErrorJs   = (String) currentSession.getAttribute("ratingMsg_js_error");
        if (ratingSuccessJs != null) currentSession.removeAttribute("ratingMsg_js_success");
        if (ratingErrorJs   != null) currentSession.removeAttribute("ratingMsg_js_error");
        %>
        <% if (ratingSuccessJs != null) { %>
        <div style="background:#EAF3DE; border:0.5px solid #97C459; border-radius:10px;
                    padding:12px 16px; color:#3B6D11; font-size:14px; margin-bottom:1.5rem;">
            ✓ &nbsp;<%= ratingSuccessJs %>
        </div>
        <% } %>
        <% if (ratingErrorJs != null) { %>
        <div style="background:#FCEBEB; border:0.5px solid #F09595; border-radius:10px;
                    padding:12px 16px; color:#A32D2D; font-size:14px; margin-bottom:1.5rem;">
            ! &nbsp;<%= ratingErrorJs %>
        </div>
        <% } %>

        <h2 style="font-size:20px; font-weight:500; color:var(--color-text-primary); margin:0 0 4px;">Rate Employers</h2>
        <p style="font-size:14px; color:var(--color-text-secondary); margin:0 0 1.5rem;">Leave a review after payment has been confirmed</p>

        <%
        Connection conJsRev = null;
        try {
            conJsRev = db.DBConnection.getConnection();
            PreparedStatement psJsRev = conJsRev.prepareStatement(
                "SELECT j.job_id, j.title, j.eid AS employer_id, " +
                "CONCAT(e.efirstname,' ',e.elastname) AS employer_name, e.ecompanyname, " +
                "r.rating_id AS already_rated " +
                "FROM applications a JOIN jobs j ON j.job_id = a.job_id " +
                "JOIN employer e ON e.eid = j.eid " +
                "JOIN payments p ON p.application_id = a.application_id " +
                "LEFT JOIN ratings r ON r.job_id = j.job_id AND r.employer_id = j.eid " +
                "    AND r.jobseeker_id = a.jobseeker_id AND r.rating_by = 'Jobseeker' " +
                "WHERE a.jobseeker_id = ? AND a.status = 'Accepted' AND p.status = 'Confirmed' " +
                "UNION " +
                "SELECT j.job_id, j.title, j.eid AS employer_id, " +
                "CONCAT(e.efirstname,' ',e.elastname) AS employer_name, e.ecompanyname, " +
                "r.rating_id AS already_rated " +
                "FROM bids b JOIN jobs j ON j.job_id = b.job_id " +
                "JOIN employer e ON e.eid = j.eid " +
                "JOIN payments p ON p.application_id = b.bid_id " +
                "LEFT JOIN ratings r ON r.job_id = j.job_id AND r.employer_id = j.eid " +
                "    AND r.jobseeker_id = b.job_seeker_id AND r.rating_by = 'Jobseeker' " +
                "WHERE b.job_seeker_id = ? AND b.bid_status = 'Accepted' AND p.status = 'Confirmed' " +
                "ORDER BY job_id DESC");
            psJsRev.setInt(1, jobseekerId);
            psJsRev.setInt(2, jobseekerId);
            ResultSet rsJsRev = psJsRev.executeQuery();
            boolean anyJsRow = false;
            while (rsJsRev.next()) {
                anyJsRow = true;
                boolean jsRated     = (rsJsRev.getObject("already_rated") != null);
                String  empName     = rsJsRev.getString("employer_name");
                String  companyName = rsJsRev.getString("ecompanyname");
                if (companyName == null) companyName = "";
                String initials = "";
                if (empName != null && empName.contains(" ")) {
                    String[] parts = empName.trim().split(" ");
                    initials = ("" + parts[0].charAt(0) + parts[parts.length-1].charAt(0)).toUpperCase();
                } else if (empName != null && empName.length() > 0) {
                    initials = ("" + empName.charAt(0)).toUpperCase();
                }
        %>
            <div style="background:var(--color-background-primary); border:0.5px solid var(--color-border-tertiary);
                        border-radius:var(--border-radius-lg); padding:1.25rem 1.5rem; margin-bottom:12px;
                        display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap;">
                <div style="width:42px; height:42px; border-radius:50%; background:#E6F1FB;
                            display:flex; align-items:center; justify-content:center;
                            font-size:14px; font-weight:500; color:#185FA5; flex-shrink:0;">
                    <%= initials %>
                </div>
                <div style="flex:1; min-width:0;">
                    <p style="font-size:15px; font-weight:500; color:var(--color-text-primary); margin:0 0 2px;
                              white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><%= empName %></p>
                    <p style="font-size:13px; color:var(--color-text-secondary); margin:0 0 8px;">
                        <%= companyName.isEmpty() ? "" : companyName + " &nbsp;·&nbsp; " %>
                        <%= rsJsRev.getString("title") %>
                    </p>
                    <% if (jsRated) { %>
                    <span style="background:#EAF3DE; color:#3B6D11; font-size:12px; padding:3px 10px; border-radius:20px;">Review submitted</span>
                    <% } else { %>
                    <span style="background:#FAEEDA; color:#854F0B; font-size:12px; padding:3px 10px; border-radius:20px;">Pending your review</span>
                    <% } %>
                </div>
                <% if (!jsRated) { %>
                <a href="rating_form.jsp?job_id=<%= rsJsRev.getInt("job_id") %>&employer_id=<%= rsJsRev.getInt("employer_id") %>&jobseeker_id=<%= jobseekerId %>&rating_by=Jobseeker"
                   style="text-decoration:none; flex-shrink:0;">
                    <button style="background:#1D9E75; color:#fff; border:none; border-radius:var(--border-radius-md);
                                   padding:9px 20px; font-size:14px; cursor:pointer;">Rate employer</button>
                </a>
                <% } else { %>
                <button disabled style="background:var(--color-background-secondary); color:var(--color-text-tertiary);
                                        border:0.5px solid var(--color-border-tertiary); border-radius:var(--border-radius-md);
                                        padding:9px 20px; font-size:14px; cursor:default;">Submitted</button>
                <% } %>
            </div>
        <%
            }
            if (!anyJsRow) {
        %>
            <div style="text-align:center; padding:3rem 1rem; background:var(--color-background-secondary); border-radius:var(--border-radius-lg);">
                <div style="font-size:28px; margin-bottom:12px;">⭐</div>
                <p style="font-size:15px; color:var(--color-text-secondary); margin:0 0 6px;">No completed jobs yet</p>
                <p style="font-size:13px; margin:0;">Review option appears after payment is confirmed.</p>
            </div>
        <%
            }
            rsJsRev.close(); psJsRev.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conJsRev != null) try { conJsRev.close(); } catch (Exception ignored) {} }
        %>

        <hr style="border:none; border-top:0.5px solid var(--color-border-tertiary); margin:2.5rem 0;">

        <h2 style="font-size:20px; font-weight:500; color:var(--color-text-primary); margin:0 0 4px;">Your Reviews</h2>
        <p style="font-size:14px; color:var(--color-text-secondary); margin:0 0 1.5rem;">What employers say about your work</p>

        <%
        Connection conJsMyRev = null;
        try {
            conJsMyRev = db.DBConnection.getConnection();
            PreparedStatement psAvgJs = conJsMyRev.prepareStatement(
                "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
                "FROM ratings WHERE jobseeker_id=? AND rating_by='Employer'");
            psAvgJs.setInt(1, jobseekerId);
            ResultSet rsAvgJs = psAvgJs.executeQuery();
            double avgRjs = 0; int totalRjs = 0;
            if (rsAvgJs.next()) { avgRjs = rsAvgJs.getDouble("avg_r"); totalRjs = rsAvgJs.getInt("total"); }
            rsAvgJs.close(); psAvgJs.close();
        %>
        <div style="background:var(--color-background-secondary); border-radius:var(--border-radius-lg);
                    padding:1.25rem 1.5rem; display:flex; align-items:center; gap:20px; margin-bottom:1.5rem;">
            <div>
                <div style="font-size:36px; font-weight:500; color:var(--color-text-primary); line-height:1;">
                    <%= totalRjs > 0 ? String.format("%.1f", avgRjs) : "—" %>
                </div>
                <div style="display:flex; gap:3px; margin-top:6px;">
                <% if (totalRjs > 0) { int full = (int)Math.floor(avgRjs); for (int si=1;si<=5;si++) { if(si<=full) out.print("<span style='color:#BA7517;font-size:16px;'>★</span>"); else out.print("<span style='color:var(--color-border-secondary);font-size:16px;'>★</span>"); } } %>
                </div>
            </div>
            <div>
                <div style="font-size:15px; font-weight:500; color:var(--color-text-primary);">Overall rating</div>
                <div style="font-size:13px; color:var(--color-text-secondary); margin-top:4px;">
                    <%= totalRjs > 0 ? "Based on " + totalRjs + " review" + (totalRjs!=1?"s":"") : "No reviews yet" %>
                </div>
            </div>
        </div>
        <%
            PreparedStatement psJsMyRev = conJsMyRev.prepareStatement(
                "SELECT r.rating_value, r.review_text, r.created_at, " +
                "r.work_quality, r.performance, r.punctuality, r.professional_behavior, " +
                "CONCAT(e.efirstname,' ',e.elastname) AS reviewer_name, " +
                "e.ecompanyname, j.title AS job_title " +
                "FROM ratings r JOIN employer e ON e.eid = r.employer_id " +
                "JOIN jobs j ON j.job_id = r.job_id " +
                "WHERE r.jobseeker_id=? AND r.rating_by='Employer' ORDER BY r.created_at DESC");
            psJsMyRev.setInt(1, jobseekerId);
            ResultSet rsJsMyRev = psJsMyRev.executeQuery();
            boolean anyJsReview = false;
            while (rsJsMyRev.next()) {
                anyJsReview = true;
                double rv = rsJsMyRev.getDouble("rating_value");
                String reviewerName = rsJsMyRev.getString("reviewer_name");
                String co2 = rsJsMyRev.getString("ecompanyname"); if (co2==null) co2="";
                String reviewText = rsJsMyRev.getString("review_text");
                int wq=rsJsMyRev.getInt("work_quality"), pf=rsJsMyRev.getInt("performance"),
                    pu=rsJsMyRev.getInt("punctuality"), pb=rsJsMyRev.getInt("professional_behavior");
                String dateStr = new java.text.SimpleDateFormat("dd MMM yyyy").format(rsJsMyRev.getTimestamp("created_at"));
        %>
            <div style="background:var(--color-background-primary); border:0.5px solid var(--color-border-tertiary);
                        border-radius:var(--border-radius-lg); padding:1.25rem 1.5rem; margin-bottom:12px;">
                <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:12px; margin-bottom:12px;">
                    <div>
                        <p style="font-size:14px; font-weight:500; color:var(--color-text-primary); margin:0 0 2px;"><%= reviewerName %></p>
                        <p style="font-size:12px; color:var(--color-text-tertiary); margin:0;">
                            <%= co2.isEmpty()?"":co2+" · " %><%= rsJsMyRev.getString("job_title") %> &nbsp;·&nbsp; <%= dateStr %>
                        </p>
                    </div>
                    <span style="background:#FAEEDA; color:#633806; font-size:13px; padding:4px 10px; border-radius:var(--border-radius-md); white-space:nowrap;">
                        <%= String.format("%.1f",rv) %> ★
                    </span>
                </div>
                <div style="display:flex; flex-wrap:wrap; gap:6px; margin-bottom:12px;">
                    <% if(wq>0){%><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Work quality: <%=wq%>/5</span><%}%>
                    <% if(pf>0){%><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Performance: <%=pf%>/5</span><%}%>
                    <% if(pu>0){%><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Punctuality: <%=pu%>/5</span><%}%>
                    <% if(pb>0){%><span style="background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);color:var(--color-text-secondary);font-size:12px;padding:3px 10px;border-radius:20px;">Professionalism: <%=pb%>/5</span><%}%>
                </div>
                <% if (reviewText != null && !reviewText.trim().isEmpty()) { %>
                <p style="font-size:14px; color:var(--color-text-secondary); line-height:1.6; margin:0;
                          border-left:2px solid var(--color-border-secondary); padding-left:12px;">
                    <%= reviewText.trim() %>
                </p>
                <% } %>
            </div>
        <%
            }
            if (!anyJsReview) {
        %>
            <div style="text-align:center; padding:3rem 1rem; background:var(--color-background-secondary); border-radius:var(--border-radius-lg);">
                <p style="font-size:15px; color:var(--color-text-secondary); margin:0;">No reviews received yet</p>
            </div>
        <%
            }
            rsJsMyRev.close(); psJsMyRev.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conJsMyRev != null) try { conJsMyRev.close(); } catch (Exception ignored) {} }
        %>

    </div>
    </div><%-- END reviewsSection --%>

</div><%-- END .main --%>

<script>
const jobseekerZip = "<%= currentSession.getAttribute("jzip") != null ? currentSession.getAttribute("jzip") : "" %>";

function loadAreas() {
    if (!jobseekerZip) return;
    fetch("https://api.postalpincode.in/pincode/" + jobseekerZip)
    .then(r => r.json())
    .then(data => {
        const container = document.getElementById("areaContainer");
        container.innerHTML = "";
        if (data && data[0] && data[0].Status === "Success") {
            data[0].PostOffice.forEach(post => {
                const label = document.createElement("label");
                label.innerHTML = '<input type="checkbox" name="area" value="'+post.Name+'"> ' + post.Name;
                container.appendChild(label);
            });
        } else { container.innerHTML = "No areas found"; }
    })
    .catch(() => { document.getElementById("areaContainer").innerHTML = "Error loading areas"; });
}
loadAreas();

const searchInput = document.getElementById("searchInput");
const suggestionBox = document.createElement("div");
suggestionBox.style.cssText = "position:absolute;background:#fff;border:1px solid #e8edf2;border-radius:8px;width:100%;max-height:220px;overflow-y:auto;z-index:999;box-shadow:0 4px 12px rgba(0,0,0,0.1);display:none;top:100%;left:0;";
searchInput.parentElement.style.position = "relative";
searchInput.parentNode.insertBefore(suggestionBox, searchInput.nextSibling);
searchInput.addEventListener("keyup", function () {
    const q = this.value.trim();
    if (q.length < 1) { suggestionBox.style.display = "none"; return; }
    fetch("SearchSuggestionServlet?q=" + encodeURIComponent(q))
    .then(r => r.json())
    .then(data => {
        suggestionBox.innerHTML = "";
        if (!data.length) { suggestionBox.style.display = "none"; return; }
        data.forEach(item => {
            const div = document.createElement("div");
            div.textContent = item;
            div.style.cssText = "padding:10px 14px;font-size:14px;cursor:pointer;border-bottom:1px solid #f0f2f5;color:#1a2a3a;";
            div.addEventListener("mouseenter", () => div.style.background = "#f5f8ff");
            div.addEventListener("mouseleave", () => div.style.background = "#fff");
            div.addEventListener("click", () => { searchInput.value = item; suggestionBox.style.display = "none"; });
            suggestionBox.appendChild(div);
        });
        suggestionBox.style.display = "block";
    });
});
document.addEventListener("click", e => { if (e.target !== searchInput) suggestionBox.style.display = "none"; });

document.getElementById("filterBtn").addEventListener("click", function () {
    const fb = document.getElementById("filterContainer");
    fb.style.display = fb.style.display === "block" ? "none" : "block";
});
document.getElementById("applyFilter").addEventListener("click", () => {
    document.getElementById("filterContainer").style.display = "none";
});

window.onload = function () { loadSubskills(); };
function loadSubskills() {
    const skillInput = document.getElementById("selectedSkillId");
    if (!skillInput || !skillInput.value) return;
    fetch("GetSubskillsServlet?skillId=" + skillInput.value)
    .then(r => r.json())
    .then(data => {
        const list = document.getElementById("subskillList");
        list.innerHTML = "";
        if (!data.length) { list.innerHTML = "No subskills found"; return; }
        data.forEach(sub => {
            const label = document.createElement("label");
            label.innerHTML = '<input type="checkbox" name="subskill" value="'+sub.id+'"> ' + sub.name;
            list.appendChild(label);
        });
    });
}

const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", e => {
    e.stopPropagation();
    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
});
profileMenu.addEventListener("click", e => e.stopPropagation());
document.addEventListener("click", () => profileMenu.style.display = "none");

function showSection(section, el) {
    ["dashboardSection","appliedSection","assignedSection","paymentsSection","reviewsSection"]
    .forEach(id => { const s = document.getElementById(id); if (s) s.style.display = "none"; });
    const map = { dashboard:"dashboardSection", applied:"appliedSection",
                  assigned:"assignedSection", payments:"paymentsSection", reviews:"reviewsSection" };
    if (map[section]) document.getElementById(map[section]).style.display = "block";
    document.querySelectorAll(".sidebar a").forEach(a => a.classList.remove("active"));
    if (el) el.classList.add("active");
}

document.addEventListener("DOMContentLoaded", function () {
    const section = new URLSearchParams(window.location.search).get("section");
    if (section) {
        document.querySelectorAll(".sidebar a").forEach(a => {
            const oc = a.getAttribute("onclick") || "";
            if (oc.includes("'" + section + "'") || oc.includes('"' + section + '"')) {
                showSection(section, a);
            }
        });
    }
});

function toggleSubskill() { const d=document.getElementById("subskillDropdown"); d.style.display=d.style.display==="block"?"none":"block"; }
function closeSubskill() {
    document.getElementById("subskillDropdown").style.display = "none";
    const checks = document.querySelectorAll("input[name='subskill']:checked");
    document.getElementById("subskillText").innerText = checks.length
        ? Array.from(checks).map(c=>c.parentElement.textContent.trim()).join(", ") : "Select Subskills";
}
function toggleArea() { const d=document.getElementById("areaDropdown"); d.style.display=d.style.display==="block"?"none":"block"; }
function closeArea() {
    document.getElementById("areaDropdown").style.display = "none";
    const checks = document.querySelectorAll("input[name='area']:checked");
    document.getElementById("areaText").innerText = checks.length
        ? Array.from(checks).map(c=>c.parentElement.textContent.trim()).join(", ") : "Select Area";
}

const hamburger   = document.getElementById("hamburger");
const sidebar     = document.getElementById("sidebar");
const mainContent = document.querySelector(".main");
const navbar      = document.querySelector(".navbar");
hamburger.addEventListener("click", function () {
    sidebar.classList.toggle("collapsed");
    hamburger.classList.toggle("collapsed");
    if (mainContent) mainContent.classList.toggle("collapsed");
    if (navbar)      navbar.classList.toggle("collapsed");
});
</script>
</body>
</html>
