<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%
    // 🔐 Prevent browser cache (Back button protection)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 🔐 Check if employer is logged in
   HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("eid") == null) {
    response.sendRedirect("login.jsp");
    return;
}


//String email = (String) currentSession.getAttribute("eemail");

%>


<%
//String email = (String) session.getAttribute("eemail");

try {
   
    Connection con = DBConnection.getConnection();

   Integer employerId = (Integer) currentSession.getAttribute("eid");

PreparedStatement ps = con.prepareStatement(
    "SELECT efirstname, elastname, ecompanyname FROM employer WHERE eid = ?");
ps.setInt(1, employerId);


    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        currentSession.setAttribute("efirstname", rs.getString("efirstname"));
        currentSession.setAttribute("elastname", rs.getString("elastname"));
        currentSession.setAttribute("ecompanyname", rs.getString("ecompanyname"));
    }
    con.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

<%
    String successMsg = (String) currentSession.getAttribute("jobSuccess");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Employer Dashboard | SkillMitra</title>
    <link rel="stylesheet" href="emp_dash.css">
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
.section-container{
max-width:950px;
margin:auto;
}

.job-group{
border:1px solid #e6e6e6;
border-radius:10px;
padding:20px;
margin-top:25px;
background:#fff;
box-shadow:0 2px 6px rgba(0,0,0,0.05);
}

.applications-list{
display:flex;
flex-direction:column;
gap:15px;
}

.review-card{
display:flex;
justify-content:space-between;
align-items:center;
border:1px solid #eee;
padding:15px;
border-radius:8px;
background:#fafafa;
}

.worker-details h4{
margin:0;
font-size:17px;
}

.worker-details p{
margin:3px 0;
color:#666;
font-size:14px;
}

.meta{
font-size:13px;
color:#777;
margin-top:4px;
}

.actions{
display:flex;
gap:10px;
}

.accept-btn{
background:#22c55e;
color:white;
padding:7px 14px;
border-radius:6px;
text-decoration:none;
}

.reject-btn{
background:#ef4444;
color:white;
padding:7px 14px;
border-radius:6px;
text-decoration:none;
}

.counter-btn{
background:#ff9800;
color:white;
border:none;
padding:6px 10px;
border-radius:5px;
}

.empty-msg{
color:#777;
font-size:14px;
margin-top:10px;
}
</style>

</head>



<body>
<% if (successMsg != null) { %>
<div id="successModal" class="modal-overlay">
    <div class="modal-box">
        <span class="close-btn" onclick="closeModal()">&times;</span>
        <h2>✅ Success</h2>
        <p><%= successMsg %></p>
    </div>
</div>
<%
    currentSession.removeAttribute("jobSuccess");
}
%>

<header style="display:flex; align-items:center; justify-content:space-between; position:relative;">

    <div style="display:flex; align-items:center; gap:12px;">
    <button class="hamburger" id="hamburger">&#9776;</button>
    <img src="skillmitralogo.jpg" alt="Logo" style="width:35px; height:35px; border-radius:50%; object-fit:cover;">
    <div class="logo">SkillMitra</div>
</div>

    <%-- ── NOTIFICATION BELL ── --%>
    <%
    int unreadCount = 0;
    Connection conNotif = null;
    PreparedStatement psNotif = null;
    ResultSet rsNotif = null;
    try {
        Integer empIdNotif = (Integer) currentSession.getAttribute("eid");
        if (empIdNotif != null) {
            conNotif = DBConnection.getConnection();
            psNotif = conNotif.prepareStatement(
                "SELECT COUNT(*) FROM notifications WHERE employer_id=? AND is_read=0"
            );
            psNotif.setInt(1, empIdNotif);
            rsNotif = psNotif.executeQuery();
            if (rsNotif.next()) unreadCount = rsNotif.getInt(1);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rsNotif  != null) try { rsNotif.close();  } catch (Exception ignored) {}
        if (psNotif  != null) try { psNotif.close();  } catch (Exception ignored) {}
        if (conNotif != null) try { conNotif.close(); } catch (Exception ignored) {}
    }
    %>

    <%-- Bell + Profile wrapper on right side --%>
    <div style="display:flex; align-items:center; gap:20px; margin-left:auto;">

        <%-- Bell icon --%>
        <div style="position:relative; cursor:pointer;" onclick="toggleNotifPanel()">
            <span style="font-size:22px; filter:brightness(0) invert(1);">🔔</span>
            <% if (unreadCount > 0) { %>
            <span id="notifBadge"
                  style="position:absolute; top:-6px; right:-8px;
                         background:#ff1744; color:#fff; border-radius:50%;
                         font-size:11px; padding:2px 6px; font-weight:700;">
                <%= unreadCount %>
            </span>
            <% } %>
        </div>

        <%-- Notification Panel --%>
        <div id="notifPanel"
             style="display:none; position:absolute; top:55px; right:60px;
                    width:340px; background:#fff; border:1px solid #e0e0e0;
                    border-radius:10px; box-shadow:0 4px 20px rgba(0,0,0,0.12);
                    z-index:9999; max-height:400px; overflow-y:auto;">

            <div style="padding:14px 16px; border-bottom:1px solid #f0f0f0;
                        font-weight:600; color:#1b5e20; font-size:15px;">
                🔔 Notifications
                <% if (unreadCount > 0) { %>
                <a href="javascript:void(0)" onclick="markAllRead()">
                   style="float:right; font-size:12px; color:#1976d2;
                          font-weight:400; text-decoration:none;">
                    Mark all read
                </a>
                <% } %>
            </div>

            <%
            Connection conN2 = null;
            PreparedStatement psN2 = null;
            ResultSet rsN2 = null;
            try {
                Integer empIdN = (Integer) currentSession.getAttribute("eid");
                if (empIdN != null) {
                    conN2 = DBConnection.getConnection();
                    psN2 = conN2.prepareStatement(
                        "SELECT notification_id, message, is_read, created_at " +
                        "FROM notifications WHERE employer_id=? " +
                        "ORDER BY created_at DESC LIMIT 20"
                    );
                    psN2.setInt(1, empIdN);
                    rsN2 = psN2.executeQuery();
                    boolean anyNotif = false;
                    while (rsN2.next()) {
                        anyNotif = true;
                        boolean isRead = rsN2.getInt("is_read") == 1;
                        String bg = isRead ? "#fff" : "#fff8e1";
            %>
            <div style="padding:12px 16px; border-bottom:1px solid #f5f5f5;
                        background:<%= bg %>; font-size:14px; color:#333;">
                <%= rsN2.getString("message") %>
                <div style="font-size:11px; color:#999; margin-top:4px;">
                    <%= rsN2.getTimestamp("created_at") %>
                </div>
            </div>
            <%
                    }
                    if (!anyNotif) {
            %>
            <div style="padding:24px; text-align:center; color:#999; font-size:14px;">
                No notifications yet.
            </div>
            <%
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }
            finally {
                if (rsN2  != null) try { rsN2.close();  } catch (Exception ignored) {}
                if (psN2  != null) try { psN2.close();  } catch (Exception ignored) {}
                if (conN2 != null) try { conN2.close(); } catch (Exception ignored) {}
            }
            %>
        </div>

        <%-- Profile dropdown --%>
        <div class="profile-dropdown">
            <%
            String photo = (String) currentSession.getAttribute("ephoto");
            String imgPath;
            if(photo != null && !photo.trim().isEmpty()){
                imgPath = "uploads/" + photo;
            }else{
                imgPath = "images/default-user.png";
            }
            %>
            <img src="<%= imgPath %>" class="profile-icon" id="profileIcon">
            <div class="profile-menu" id="profileMenu">
                <div class="profile-name" style="background:none; color:#000; font-weight:600; border-bottom:none;">
                    <%
                    String fname = (String) currentSession.getAttribute("efirstname");
                    String lname = (String) currentSession.getAttribute("elastname");
                    %>
                    <%= fname != null ? fname : "" %> <%= lname != null ? lname : "" %>
                </div>
                <a href="employer_profile.jsp">View Profile</a>
                <a href="LogoutServlet">Logout</a>
            </div>
        </div>

    </div>


   
   
</header>

<div class="dashboard">
<aside class="sidebar" id="sidebar">
<h2>Employer Dashboard</h2>
<a class="active" href="#" onclick="showSection('dashboard')">
    <i class="fa-solid fa-house nav-icon"></i>
    <span class="nav-label"> Dashboard</span>
</a>
<a href="#" onclick="showSection('manageJobs')">
    <i class="fa-solid fa-briefcase nav-icon"></i>
    <span class="nav-label"> Manage Jobs</span>
</a>
<a href="#" onclick="showSection('reviewApplications')">
    <i class="fa-solid fa-file-lines nav-icon"></i>
    <span class="nav-label"> Review Applications</span>
</a>
<a href="#" onclick="showSection('acceptedApplications')">
    <i class="fa-solid fa-circle-check nav-icon"></i>
    <span class="nav-label"> Accepted Applications</span>
</a>
<a href="#" onclick="showSection('rejectedApplications')">
    <i class="fa-solid fa-circle-xmark nav-icon"></i>
    <span class="nav-label"> Rejected Applications</span>
</a>
<a href="#" onclick="showSection('payments')">
    <i class="fa-solid fa-wallet nav-icon"></i>
    <span class="nav-label"> Payments</span>
</a>
<a href="#" onclick="showSection('reviews', event)">
    <i class="fa-solid fa-star nav-icon"></i>
    <span class="nav-label"> Rate & Review</span>
</a>
</aside>

    <main class="content">

<div class="topbar" style="display:flex; justify-content:space-between; align-items:center;">
    <div>
        Welcome,
        <b><%= currentSession.getAttribute("efirstname") %>
        <%= currentSession.getAttribute("elastname") %></b>
    </div>
    <a id="postJobBtn" href="<%= request.getContextPath() %>/post-job" style="text-decoration:none;">
        <button style="background:#3b5bdb; color:#fff; border:none; border-radius:10px;
                       padding:10px 20px; font-size:14px; font-weight:600; cursor:pointer;
                       display:flex; align-items:center; gap:8px;">
            ➕ Post New Job
        </button>
    </a>
</div>


        <!-- DASHBOARD SECTION -->
<div id="dashboardSection">
    <div class="dashboard-header">
        <h2>Dashboard Overview</h2>
        <p>Welcome back! Here's what's happening with your jobs.</p>
    </div>

<%
/* ── REAL STATS FROM DB ── */
Integer empDashId = (Integer) currentSession.getAttribute("eid");

int empActiveJobs = 0, empTotalApps = 0, empHired = 0, empTotalBids = 0;

Connection conDash = null;
try {
    conDash = DBConnection.getConnection();

    // Active Jobs
    PreparedStatement psDash1 = conDash.prepareStatement(
        "SELECT COUNT(*) FROM jobs WHERE eid=? AND status='Active'"
    );
    psDash1.setInt(1, empDashId);
    ResultSet rsDash1 = psDash1.executeQuery();
    if (rsDash1.next()) empActiveJobs = rsDash1.getInt(1);
    rsDash1.close(); psDash1.close();

    // Total Applications
    PreparedStatement psDash2 = conDash.prepareStatement(
        "SELECT COUNT(*) FROM applications a JOIN jobs j ON a.job_id=j.job_id WHERE j.eid=?"
    );
    psDash2.setInt(1, empDashId);
    ResultSet rsDash2 = psDash2.executeQuery();
    if (rsDash2.next()) empTotalApps = rsDash2.getInt(1);
    rsDash2.close(); psDash2.close();

    // Hired (Accepted apps + Accepted bids)
    PreparedStatement psDash3 = conDash.prepareStatement(
        "SELECT " +
        "(SELECT COUNT(*) FROM applications a JOIN jobs j ON a.job_id=j.job_id WHERE j.eid=? AND a.status='Accepted') + " +
        "(SELECT COUNT(*) FROM bids b JOIN jobs j ON b.job_id=j.job_id WHERE j.eid=? AND b.bid_status='Accepted') AS total"
    );
    psDash3.setInt(1, empDashId);
    psDash3.setInt(2, empDashId);
    ResultSet rsDash3 = psDash3.executeQuery();
    if (rsDash3.next()) empHired = rsDash3.getInt("total");
    rsDash3.close(); psDash3.close();

    // Total Bids
    PreparedStatement psDash4 = conDash.prepareStatement(
        "SELECT COUNT(*) FROM bids b JOIN jobs j ON b.job_id=j.job_id WHERE j.eid=?"
    );
    psDash4.setInt(1, empDashId);
    ResultSet rsDash4 = psDash4.executeQuery();
    if (rsDash4.next()) empTotalBids = rsDash4.getInt(1);
    rsDash4.close(); psDash4.close();

} catch(Exception e){ e.printStackTrace(); }
finally { if(conDash != null) try{ conDash.close(); }catch(Exception ignored){} }
%>

    <div class="stats-cards">
        <div class="stats-card">
            <span class="title">Active Jobs</span>
            <span class="number"><%= empActiveJobs %></span>
            <span class="change">Currently open</span>
        </div>
        <div class="stats-card">
            <span class="title">Total Applications</span>
            <span class="number"><%= empTotalApps %></span>
            <span class="change">Across all jobs</span>
        </div>
        <div class="stats-card">
            <span class="title">Hired</span>
            <span class="number"><%= empHired %></span>
            <span class="change">Apps + Bids accepted</span>
        </div>
        <div class="stats-card">
            <span class="title">Total Bids</span>
            <span class="number"><%= empTotalBids %></span>
            <span class="change">Received on your jobs</span>
        </div>
    </div>
    <%-- ── PENDING ALERTS ── --%>
<%
int alertPendingApps = 0, alertPendingBids = 0, alertPayRequests = 0;
Connection conAlert = null;
try {
    conAlert = DBConnection.getConnection();
    Integer empAlertId = (Integer) currentSession.getAttribute("eid");

    // Pending applications
    PreparedStatement psAl1 = conAlert.prepareStatement(
        "SELECT COUNT(*) FROM applications a JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE j.eid=? AND a.status='Pending' AND a.is_bid=0"
    );
    psAl1.setInt(1, empAlertId);
    ResultSet rsAl1 = psAl1.executeQuery();
    if(rsAl1.next()) alertPendingApps = rsAl1.getInt(1);
    rsAl1.close(); psAl1.close();

    // Pending bids
    PreparedStatement psAl2 = conAlert.prepareStatement(
        "SELECT COUNT(*) FROM bids b JOIN jobs j ON b.job_id=j.job_id " +
        "WHERE j.eid=? AND b.bid_status='Pending'"
    );
    psAl2.setInt(1, empAlertId);
    ResultSet rsAl2 = psAl2.executeQuery();
    if(rsAl2.next()) alertPendingBids = rsAl2.getInt(1);
    rsAl2.close(); psAl2.close();

    // Payment requests from workers
    PreparedStatement psAl3 = conAlert.prepareStatement(
        "SELECT COUNT(*) FROM payments p " +
        "JOIN applications a ON p.application_id=a.application_id " +
        "JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE j.eid=? AND p.status='Requested'"
    );
    psAl3.setInt(1, empAlertId);
    ResultSet rsAl3 = psAl3.executeQuery();
    if(rsAl3.next()) alertPayRequests = rsAl3.getInt(1);
    rsAl3.close(); psAl3.close();

} catch(Exception e){ e.printStackTrace(); }
finally { if(conAlert != null) try{ conAlert.close(); }catch(Exception ignored){} }
%>

<%-- Pending Applications Alert --%>
<% if(alertPendingApps > 0){ %>
<div style="background:#fffbeb; border:1.5px solid #fcd34d; border-radius:10px;
            padding:14px 18px; margin-bottom:10px;
            display:flex; align-items:center; justify-content:space-between;">
    <span style="font-size:14px; color:#92400e; font-weight:500;">
        ⚠️ You have <b><%= alertPendingApps %></b>
        pending application<%= alertPendingApps > 1 ? "s" : "" %> waiting for review
    </span>
    <button onclick="showSection('reviewApplications', event)"
            style="background:#f59e0b; color:#fff; border:none; border-radius:8px;
                   padding:7px 16px; font-size:13px; font-weight:600; cursor:pointer;">
        Review Now →
    </button>
</div>
<% } %>

<%-- Pending Bids Alert --%>
<% if(alertPendingBids > 0){ %>
<div style="background:#fffbeb; border:1.5px solid #fcd34d; border-radius:10px;
            padding:14px 18px; margin-bottom:10px;
            display:flex; align-items:center; justify-content:space-between;">
    <span style="font-size:14px; color:#92400e; font-weight:500;">
        🔔 You have <b><%= alertPendingBids %></b>
        pending bid<%= alertPendingBids > 1 ? "s" : "" %> waiting for response
    </span>
    <button onclick="showSection('reviewApplications', event)"
            style="background:#f59e0b; color:#fff; border:none; border-radius:8px;
                   padding:7px 16px; font-size:13px; font-weight:600; cursor:pointer;">
        Review Bids →
    </button>
</div>
<% } %>

<%-- Payment Requests Warning --%>
<% if(alertPayRequests > 0){ %>
<div style="background:#fff5f5; border:1.5px solid #fca5a5; border-radius:10px;
            padding:14px 18px; margin-bottom:10px;
            display:flex; align-items:center; justify-content:space-between;">
    <span style="font-size:14px; color:#991b1b; font-weight:500;">
        💸 <b><%= alertPayRequests %></b>
        worker<%= alertPayRequests > 1 ? "s have" : " has" %> requested payment
    </span>
    <button onclick="showSection('payments', event)"
            style="background:#ef4444; color:#fff; border:none; border-radius:8px;
                   padding:7px 16px; font-size:13px; font-weight:600; cursor:pointer;">
        Pay Now →
    </button>
</div>
<% } %>

<%
/* ── APPLICATION STATUS BREAKDOWN ── */
int empPending = 0, empAccepted = 0, empRejected = 0;
Connection conDashStatus = null;
try {
    conDashStatus = DBConnection.getConnection();
    PreparedStatement psStatus = conDashStatus.prepareStatement(
        "SELECT a.status, COUNT(*) as cnt " +
        "FROM applications a JOIN jobs j ON a.job_id=j.job_id " +
        "WHERE j.eid=? GROUP BY a.status"
    );
    psStatus.setInt(1, empDashId);
    ResultSet rsStatus = psStatus.executeQuery();
    while(rsStatus.next()){
        String st = rsStatus.getString("status");
        int cnt = rsStatus.getInt("cnt");
        if("Pending".equalsIgnoreCase(st))  empPending  = cnt;
        if("Accepted".equalsIgnoreCase(st)) empAccepted = cnt;
        if("Rejected".equalsIgnoreCase(st)) empRejected = cnt;
    }
    rsStatus.close(); psStatus.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conDashStatus != null) try{ conDashStatus.close(); }catch(Exception ignored){} }
%>

    <div class="lower-section">

        <%-- Application Status Card --%>
        <div class="lower-card" style="flex:0 0 260px;">
            <h3>Application Status</h3>
            <div style="display:flex; flex-direction:column; gap:14px; margin-top:16px;">
                <div style="display:flex; justify-content:space-between; align-items:center;
                            padding:10px 14px; background:#fff8e1; border-radius:10px;">
                    <span style="font-size:14px; color:#555;">Pending</span>
                    <span style="background:#ffc107; color:#fff; border-radius:20px;
                                 padding:3px 12px; font-weight:700; font-size:14px;">
                        <%= empPending %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center;
                            padding:10px 14px; background:#e8f5e9; border-radius:10px;">
                    <span style="font-size:14px; color:#555;">Accepted</span>
                    <span style="background:#28a745; color:#fff; border-radius:20px;
                                 padding:3px 12px; font-weight:700; font-size:14px;">
                        <%= empAccepted %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center;
                            padding:10px 14px; background:#fdecea; border-radius:10px;">
                    <span style="font-size:14px; color:#555;">Rejected</span>
                    <span style="background:#ef4444; color:#fff; border-radius:20px;
                                 padding:3px 12px; font-weight:700; font-size:14px;">
                        <%= empRejected %>
                    </span>
                </div>
            </div>
        </div>

        <%-- Recent Applications --%>
        <div class="lower-card" style="flex:1;">
            <h3>Recent Applications</h3>
            <table>
                <tr><th>Worker Name</th><th>Position</th><th>Date</th><th>Status</th></tr>
<%
Connection conRecApp = null;
try {
    conRecApp = DBConnection.getConnection();
    PreparedStatement psRecApp = conRecApp.prepareStatement(
        "SELECT js.jfirstname, js.jlastname, j.title, a.applied_at, a.status " +
        "FROM applications a " +
        "JOIN jobs j ON a.job_id=j.job_id " +
        "JOIN jobseeker js ON a.jobseeker_id=js.jid " +
        "WHERE j.eid=? ORDER BY a.applied_at DESC LIMIT 5"
    );
    psRecApp.setInt(1, empDashId);
    ResultSet rsRecApp = psRecApp.executeQuery();
    boolean anyRecApp = false;
    while(rsRecApp.next()){
        anyRecApp = true;
        String appStatus = rsRecApp.getString("status");
        String badgeColor = "#ffc107";
        if("Accepted".equals(appStatus)) badgeColor = "#28a745";
        else if("Rejected".equals(appStatus)) badgeColor = "#ef4444";
        String dateStr = new java.text.SimpleDateFormat("dd MMM yyyy")
                            .format(rsRecApp.getTimestamp("applied_at"));
%>
                <tr>
                    <td><%= rsRecApp.getString("jfirstname") %> <%= rsRecApp.getString("jlastname") %></td>
                    <td><%= rsRecApp.getString("title") %></td>
                    <td><%= dateStr %></td>
                    <td>
                        <span style="padding:2px 10px; border-radius:12px; color:#fff;
                                     background:<%= badgeColor %>; font-size:12px;">
                            <%= appStatus %>
                        </span>
                    </td>
                </tr>
<%
    }
    if(!anyRecApp){
%>
                <tr><td colspan="4" style="text-align:center; color:#999;">No applications yet</td></tr>
<%
    }
    rsRecApp.close(); psRecApp.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conRecApp != null) try{ conRecApp.close(); }catch(Exception ignored){} }
%>
            </table>
        </div>

    </div>

    <%-- Second Row: Active Job Posts + Recent Bids --%>
    <div class="lower-section" style="margin-top:20px;">

        <%-- Active Job Posts with real applicant count --%>
        <div class="lower-card" style="flex:1;">
            <h3>Active Job Posts</h3>
            <table>
                <tr><th>Job Title</th><th>Location</th><th>Applicants</th><th>Bids</th></tr>
<%
Connection conActiveJobs = null;
try {
    conActiveJobs = DBConnection.getConnection();
    PreparedStatement psAJ = conActiveJobs.prepareStatement(
        "SELECT j.job_id, j.title, j.city, " +
        "(SELECT COUNT(*) FROM applications a WHERE a.job_id=j.job_id) AS app_count, " +
        "(SELECT COUNT(*) FROM bids b WHERE b.job_id=j.job_id) AS bid_count " +
        "FROM jobs j WHERE j.eid=? AND j.status='Active' ORDER BY j.job_id DESC LIMIT 5"
    );
    psAJ.setInt(1, empDashId);
    ResultSet rsAJ = psAJ.executeQuery();
    boolean anyAJ = false;
    while(rsAJ.next()){
        anyAJ = true;
%>
                <tr>
                    <td><%= rsAJ.getString("title") %></td>
                    <td><%= rsAJ.getString("city") %></td>
                    <td><%= rsAJ.getInt("app_count") %></td>
                    <td><%= rsAJ.getInt("bid_count") %></td>
                </tr>
<%
    }
    if(!anyAJ){
%>
                <tr><td colspan="4" style="text-align:center; color:#999;">No active jobs</td></tr>
<%
    }
    rsAJ.close(); psAJ.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conActiveJobs != null) try{ conActiveJobs.close(); }catch(Exception ignored){} }
%>
            </table>
        </div>

        <%-- Recent Bids --%>
        <div class="lower-card" style="flex:1;">
            <h3>Recent Bids</h3>
            <table>
                <tr><th>Worker</th><th>Job</th><th>Bid Amount</th><th>Status</th></tr>
<%
Connection conRecentBids = null;
try {
    conRecentBids = DBConnection.getConnection();
    PreparedStatement psRB = conRecentBids.prepareStatement(
        "SELECT js.jfirstname, js.jlastname, j.title, b.bid_amount, b.bid_status " +
        "FROM bids b " +
        "JOIN jobs j ON b.job_id=j.job_id " +
        "JOIN jobseeker js ON b.job_seeker_id=js.jid " +
        "WHERE j.eid=? ORDER BY b.created_at DESC LIMIT 5"
    );
    psRB.setInt(1, empDashId);
    ResultSet rsRB = psRB.executeQuery();
    boolean anyRB = false;
    while(rsRB.next()){
        anyRB = true;
        String bidSt = rsRB.getString("bid_status");
        String bidColor = "#ffc107";
        if("Accepted".equals(bidSt)) bidColor = "#28a745";
        else if("Rejected".equals(bidSt)) bidColor = "#ef4444";
        else if("Countered".equals(bidSt)) bidColor = "#ff9800";
%>
                <tr>
                    <td><%= rsRB.getString("jfirstname") %> <%= rsRB.getString("jlastname") %></td>
                    <td><%= rsRB.getString("title") %></td>
                    <td>₹<%= rsRB.getInt("bid_amount") %></td>
                    <td>
                        <span style="padding:2px 10px; border-radius:12px; color:#fff;
                                     background:<%= bidColor %>; font-size:12px;">
                            <%= bidSt %>
                        </span>
                    </td>
                </tr>
<%
    }
    if(!anyRB){
%>
                <tr><td colspan="4" style="text-align:center; color:#999;">No bids yet</td></tr>
<%
    }
    rsRB.close(); psRB.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conRecentBids != null) try{ conRecentBids.close(); }catch(Exception ignored){} }
%>
            </table>
        </div>

    </div>

</div>

<!-- MANAGE JOBS SECTION -->
<div id="manageJobsSection" style="display:none; width:100%; max-width:900px;">
   

    <div class="manage-header">
        <h2>Manage Jobs</h2>
        <a href="<%= request.getContextPath() %>/post-job">
            <button class="post-job-btn">+ Post Job</button>
        </a>
    </div>
    <div class="cards-grid">
<%
Integer employerId = (Integer) currentSession.getAttribute("eid");

if(employerId != null){

    try{


        Connection con2 = DBConnection.getConnection();

        // ✅ FIXED QUERY (Distinct + Proper Grouping)
        PreparedStatement ps2 = con2.prepareStatement(
            "SELECT j.*, " +
            "GROUP_CONCAT(DISTINCT s.subskill_name SEPARATOR ', ') AS subskills " +
            "FROM jobs j " +
            "LEFT JOIN job_skills js ON j.job_id = js.job_id " +
            "LEFT JOIN subskill s ON js.subskill_id = s.subskill_id " +
            "WHERE j.eid = ? " +
            "GROUP BY j.job_id " +
            "ORDER BY j.job_id DESC"
        );

        ps2.setInt(1, employerId);

        ResultSet rs2 = ps2.executeQuery();

        boolean hasJobs = false;

        while(rs2.next()){
            hasJobs = true;
%>

    <!-- JOB CARD -->
    <div class="job-card">

    <!-- TOP ROW: Title + Status + Actions -->
    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px;">
        <div>
            <h3 style="font-size:18px; font-weight:700; color:#1a2a3a; margin-bottom:6px;">
                <%= rs2.getString("title") %>
            </h3>
            <div style="display:flex; flex-wrap:wrap; gap:10px; font-size:13px; color:#6b7280;">
                <span>📍 <%= rs2.getString("locality") %>, <%= rs2.getString("city") %></span>
                <span>🕒 <%= rs2.getString("working_hours") %></span>
                <span>💼 <%= rs2.getString("job_type") %></span>
            </div>
        </div>
        <div style="display:flex; flex-direction:column; align-items:flex-end; gap:8px;">
            <%
            java.sql.Date expiry2 = rs2.getDate("expiry_date");
            java.sql.Date today2 = new java.sql.Date(System.currentTimeMillis());
            String status2 = (expiry2 != null && expiry2.before(today2)) ? "EXPIRED" : "ACTIVE";
            String statusBg = "ACTIVE".equals(status2) ? "#dcfce7" : "#fee2e2";
            String statusColor = "ACTIVE".equals(status2) ? "#166534" : "#991b1b";
            %>
            <span style="background:<%= statusBg %>; color:<%= statusColor %>;
                         padding:4px 12px; border-radius:20px; font-size:12px; font-weight:700;">
                <%= status2 %>
            </span>
            <div style="display:flex; gap:8px;">
                <a href="EditJobServlet?job_id=<%= rs2.getInt("job_id") %>"
                   style="background:#4f6d84; color:#fff; padding:6px 16px;
                          border-radius:7px; text-decoration:none; font-size:13px; font-weight:600;">
                    Edit
                </a>
                <a href="DeleteJobServlet?job_id=<%= rs2.getInt("job_id") %>"
                   onclick="return confirm('Are you sure you want to delete this job?');"
                   style="background:#fee2e2; color:#991b1b; padding:6px 16px;
                          border-radius:7px; text-decoration:none; font-size:13px; font-weight:600;
                          border:1px solid #fca5a5;">
                    Delete
                </a>
            </div>
        </div>
    </div>

    <!-- DIVIDER -->
    <hr style="border:none; border-top:1px solid #f0f2f5; margin-bottom:16px;">

    <!-- INFO GRID -->
    <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:16px;">

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Salary</div>
            <div style="font-size:14px; font-weight:700; color:#166534;">
                ₹<%= rs2.getString("salary") %>
                <span style="color:#9ca3af; font-weight:400; font-size:12px;">Maximum Salary
                    — ₹<%= rs2.getString("min_salary") %> max
                </span>
            </div>
        </div>

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Experience</div>
            <div style="font-size:14px; font-weight:700; color:#1a2a3a;">
                <%= rs2.getString("experience_required") != null ? rs2.getString("experience_required") : "Not specified" %>
            </div>
        </div>

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Workers Required</div>
            <div style="font-size:14px; font-weight:700; color:#1a2a3a;">
                <%= rs2.getInt("workers_required") %>
            </div>
        </div>

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Gender Preference</div>
            <div style="font-size:14px; font-weight:700; color:#1a2a3a;">
                <%= rs2.getString("gender_preference") != null ? rs2.getString("gender_preference") : "Any" %>
            </div>
        </div>

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Languages</div>
            <div style="font-size:14px; font-weight:700; color:#1a2a3a;">
                <%= rs2.getString("languages_preferred") != null ? rs2.getString("languages_preferred") : "Any" %>
            </div>
        </div>

        <div style="background:#f9fafb; border-radius:8px; padding:12px; border:1px solid #e8edf2;">
            <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                        letter-spacing:0.05em; margin-bottom:4px;">Expiry Date</div>
            <div style="font-size:14px; font-weight:700; color:<%= "EXPIRED".equals(status2) ? "#991b1b" : "#1a2a3a" %>;">
                <%= expiry2 != null ? expiry2.toString() : "Not set" %>
            </div>
        </div>

    </div>

    <!-- SUBSKILLS -->
    <%
    String subs2 = rs2.getString("subskills");
    if(subs2 != null && !subs2.trim().isEmpty()){
    %>
    <div style="margin-bottom:14px;">
        <div style="font-size:11px; color:#9ca3af; font-weight:600; text-transform:uppercase;
                    letter-spacing:0.05em; margin-bottom:8px;">Required Subskills</div>
        <div style="display:flex; flex-wrap:wrap; gap:6px;">
        <%
        for(String sub : subs2.split(",")){
        %>
            <span style="background:#eff6ff; color:#1d4ed8; font-size:12px;
                         padding:3px 12px; border-radius:20px; font-weight:500;">
                <%= sub.trim() %>
            </span>
        <%
        }
        %>
        </div>
    </div>
    <% } %>

    <!-- DESCRIPTION -->
    <div style="font-size:13px; color:#6b7280; border-top:1px solid #f0f2f5; padding-top:12px;">
        <span style="font-weight:600; color:#374151;">Description: </span>
        <%= rs2.getString("description") %>
    </div>

</div>

<%
        }

        if(!hasJobs){
%>
        <p style="margin-top:20px;">No jobs posted yet.</p>
<%
        }

        con2.close();

    } catch(Exception e){
        e.printStackTrace();
    }
}
%>

</div>
 </div>






<!-- Review Applications SECTION -->
<div id="reviewApplicationsSection" style="display:none; width:100%; max-width:900px; margin:auto;">

<div class="manage-header" style="margin-bottom:6px;">
    <div>
        <h2 style="font-size:20px; font-weight:600; color:#1a2a3a; margin:0;">Review Applications</h2>
        <p style="font-size:13px; color:#6b7280; margin:4px 0 0;">Approve or reject candidates for your open positions</p>
    </div>
</div>

<%
Integer employerId2 = (Integer) currentSession.getAttribute("eid");
if(employerId2 != null){
try{
    Connection con3 = DBConnection.getConnection();
    PreparedStatement ps3 = con3.prepareStatement(
        "SELECT j.job_id, j.title, " +
"a.application_id, a.applied_at, " +
"js.jid AS jobseeker_id, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, js.jeducation " +
        "FROM jobs j " +
        "INNER JOIN applications a ON j.job_id = a.job_id " +
        "INNER JOIN jobseeker js ON a.jobseeker_id = js.jid " +
        "WHERE j.eid = ? AND a.status='Pending' AND a.is_bid=0 " +
        "ORDER BY j.title ASC, a.applied_at DESC"
    );
    ps3.setInt(1, employerId2);
    ResultSet rs3 = ps3.executeQuery();
    String currentJobTitle = "";
    boolean hasApps = false;

    while(rs3.next()){
        String jobTitle = rs3.getString("title");
        if(!jobTitle.equals(currentJobTitle)){
            if(!currentJobTitle.equals("")){
%>
        </div><!-- close applications-list -->
    </div><!-- close job-group -->
<%
            }
            currentJobTitle = jobTitle;
%>
    <!-- Job Group -->
    <div style="margin-top:24px;">
        <div style="font-size:11px; font-weight:600; color:#9ca3af; text-transform:uppercase;
                    letter-spacing:0.05em; margin-bottom:10px; padding:0 2px;">
            <%= jobTitle %>
        </div>
        <div class="applications-list" style="display:flex; flex-direction:column; gap:10px;">
<%
        }
        if(rs3.getObject("application_id") != null){
            hasApps = true;
            String initials = rs3.getString("jfirstname").substring(0,1) + rs3.getString("jlastname").substring(0,1);
%>
        <!-- Application Card -->
        <div style="display:flex; justify-content:space-between; align-items:center;
                    background:#fff; border:0.5px solid #e5e7eb; border-radius:12px;
                    padding:14px 18px; transition:border-color 0.15s;">

            <div style="display:flex; align-items:center; gap:14px;">
                <!-- Avatar -->
                <div style="width:40px; height:40px; border-radius:50%;
                            background:#dbeafe; color:#1d4ed8;
                            display:flex; align-items:center; justify-content:center;
                            font-size:14px; font-weight:600; flex-shrink:0;">
                    <%= initials %>
                </div>
                <div>
                    <div style="font-size:15px; font-weight:600; color:#1a2a3a; margin-bottom:2px;">
                        <%= rs3.getString("jfirstname") %> <%= rs3.getString("jlastname") %>
                    </div>
                    <div style="font-size:13px; color:#6b7280; line-height:1.5;">
                        <%= rs3.getString("jemail") %><br>
                        <%= rs3.getString("jdistrict") %> &nbsp;·&nbsp; <%= rs3.getString("jeducation") %>
                    </div>
                    <span style="display:inline-block; margin-top:5px; font-size:11px; font-weight:500;
                                 padding:2px 10px; border-radius:20px;
                                 background:#eff6ff; color:#1d4ed8; border:0.5px solid #bfdbfe;">
                        Application
                    </span>
                </div>
            </div>

            <div style="display:flex; gap:8px; flex-shrink:0;">

                <a href="view_jobseeker_profile.jsp?jid=<%= rs3.getInt("jobseeker_id") %>"
                   target="_blank"
                   style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                          background:#f9fafb; color:#374151; border:0.5px solid #d1d5db;
                          text-decoration:none;">
                    View Profile
                </a>

                <a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Accepted"
                   style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                          background:#ecfdf5; color:#166634; border:0.5px solid #bbf7d0;
                          text-decoration:none;">
                    Accept
                </a>

                <a href="UpdateApplicationStatusServlet?application_id=<%= rs3.getInt("application_id") %>&status=Rejected"
                   style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                          background:#fef2f2; color:#991b1b; border:0.5px solid #fca5a5;
                          text-decoration:none;">
                    Reject
                </a>

            </div>
        </div>
<%
        }
    }
    if(!currentJobTitle.equals("")){
%>
        </div><!-- close applications-list -->
    </div><!-- close job-group -->
<%
    }
    if(!hasApps){
%>
    <div style="font-size:14px; color:#9ca3af; padding:16px 18px; margin-top:16px;
                background:#f9fafb; border-radius:10px; border:0.5px solid #e5e7eb;">
        No pending applications at this time.
    </div>
<%
    }
    con3.close();
}catch(Exception e){ e.printStackTrace(); }
}
%>

<hr style="margin:40px 0; border:none; border-top:0.5px solid #e5e7eb;">


<div class="manage-header" style="margin-bottom:6px;">
    <div>
        <h2 style="font-size:20px; font-weight:600; color:#1a2a3a; margin:0;">Review Bids</h2>
        <p style="font-size:13px; color:#6b7280; margin:4px 0 0;">Workers who placed bids on your jobs</p>
    </div>
</div>

<%
Integer employerBidId = (Integer) currentSession.getAttribute("eid");
if(employerBidId != null){
try{
    Connection conBid = DBConnection.getConnection();
    PreparedStatement psBid = conBid.prepareStatement(
        "SELECT j.job_id, j.title, " +
        "b.bid_id, b.bid_amount, b.bid_status, b.created_at, b.counter_bid, " +
        "b.job_seeker_id, " +
        "js.jfirstname, js.jlastname, js.jemail, js.jdistrict " +
        "FROM jobs j " +
        "INNER JOIN bids b ON j.job_id = b.job_id " +
        "INNER JOIN jobseeker js ON b.job_seeker_id = js.jid " +
        "WHERE j.eid = ? AND (b.bid_status='Pending' OR b.bid_status='Countered' OR b.bid_status='Rejected') " +
        "ORDER BY j.title ASC, b.bid_amount ASC"
    );
    psBid.setInt(1, employerBidId);
    ResultSet rsBid = psBid.executeQuery();
    String currentBidJobTitle = "";
    boolean hasBidsOverall = false;

    while(rsBid.next()){
        String jobTitle = rsBid.getString("title");
        if(!jobTitle.equals(currentBidJobTitle)){
            if(!currentBidJobTitle.equals("")){
%>
        </div><!-- close applications-list -->
    </div><!-- close job-group -->
<%
            }
            currentBidJobTitle = jobTitle;
            hasBidsOverall = true;
%>
    <div style="margin-top:24px;">
        <div style="font-size:11px; font-weight:600; color:#9ca3af; text-transform:uppercase;
                    letter-spacing:0.05em; margin-bottom:10px; padding:0 2px;">
            <%= jobTitle %>
        </div>
        <div class="applications-list" style="display:flex; flex-direction:column; gap:10px;">
<%
        }
        if(rsBid.getInt("bid_id") != 0){
            String bidInitials = rsBid.getString("jfirstname").substring(0,1) + rsBid.getString("jlastname").substring(0,1);
%>
        <!-- Bid Card -->
        <div style="display:flex; justify-content:space-between; align-items:center;
                    background:#fff; border:0.5px solid #e5e7eb; border-radius:12px;
                    padding:14px 18px;">

            <div style="display:flex; align-items:center; gap:14px;">
                <!-- Avatar -->
                <div style="width:40px; height:40px; border-radius:50%;
                            background:#fef3c7; color:#92400e;
                            display:flex; align-items:center; justify-content:center;
                            font-size:14px; font-weight:600; flex-shrink:0;">
                    <%= bidInitials %>
                </div>
                <div>
                    <div style="font-size:15px; font-weight:600; color:#1a2a3a; margin-bottom:2px;">
                        <%= rsBid.getString("jfirstname") %> <%= rsBid.getString("jlastname") %>
                    </div>
                    <div style="font-size:13px; color:#6b7280; line-height:1.5;">
                        <%= rsBid.getString("jemail") %><br>
                        Bid: ₹<%= rsBid.getInt("bid_amount") %>
                        <% if(rsBid.getInt("counter_bid") > 0){ %>
                            &nbsp;·&nbsp; Countered: ₹<%= rsBid.getInt("counter_bid") %>
                        <% } %>
                        &nbsp;·&nbsp; <%= rsBid.getString("jdistrict") %>
                    </div>
                    <span style="display:inline-block; margin-top:5px; font-size:11px; font-weight:500;
                                 padding:2px 10px; border-radius:20px;
                                 background:#fffbeb; color:#92400e; border:0.5px solid #fcd34d;">
                        Bid
                    </span>
                </div>
            </div>

            <div style="display:flex; flex-direction:column; align-items:flex-end; gap:8px;">
                <div style="display:flex; gap:8px;">
                    <a href="view_jobseeker_profile.jsp?jid=<%= rsBid.getInt("job_seeker_id") %>"
                       target="_blank"
                       style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                              background:#f9fafb; color:#374151; border:0.5px solid #d1d5db;
                              text-decoration:none;">
                        View Profile
                    </a>
                    <a href="RespondBidByEmployerServlet?bid_id=<%= rsBid.getInt("bid_id") %>&action=accept"
                       style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                              background:#ecfdf5; color:#166534; border:0.5px solid #bbf7d0;
                              text-decoration:none;">
                        Accept
                    </a>
                    <a href="RespondBidByEmployerServlet?bid_id=<%= rsBid.getInt("bid_id") %>&action=reject"
                       style="font-size:13px; font-weight:500; padding:7px 18px; border-radius:8px;
                              background:#fef2f2; color:#991b1b; border:0.5px solid #fca5a5;
                              text-decoration:none;">
                        Reject
                    </a>
                </div>
                <form action="CounterBidServlet" method="post" style="display:flex; gap:6px; align-items:center;">
                    <input type="hidden" name="bid_id" value="<%= rsBid.getInt("bid_id") %>">
                    <input type="number" name="counter_amount" placeholder="Counter amount (₹)" required
                           style="font-size:13px; padding:6px 10px; border-radius:8px; width:160px;
                                  border:0.5px solid #e5e7eb; background:#f9fafb; color:#374151;">
                    <button type="submit"
                            style="font-size:12px; font-weight:500; padding:6px 14px; border-radius:8px;
                                   background:#fffbeb; color:#92400e; border:0.5px solid #fcd34d; cursor:pointer;">
                        Counter
                    </button>
                </form>
            </div>
        </div>
<%
        }
    }
    if(!currentBidJobTitle.equals("")){
%>
        </div><!-- close applications-list -->
    </div><!-- close job-group -->
<%
    }
    if(!hasBidsOverall){
%>
    <div style="font-size:14px; color:#9ca3af; padding:16px 18px; margin-top:16px;
                background:#f9fafb; border-radius:10px; border:0.5px solid #e5e7eb;">
        No bids received yet.
    </div>
<%
    }
    conBid.close();
}catch(Exception e){ e.printStackTrace(); }
}
%>

</div><!-- closes reviewApplicationsSection -->

<!-- ACCEPTED APPLICATIONS SECTION -->
<div id="acceptedApplicationsSection"
     style="display:none; width:100%; max-width:900px;">

<div class="manage-header">
<div>
<h2>Accepted Applications</h2>
<p>Candidates you've accepted for positions</p>
</div>
</div>

<%
Integer employerId3 = (Integer) currentSession.getAttribute("eid");

if(employerId3 != null){

Connection con4 = null;
PreparedStatement ps4 = null;
ResultSet rs4 = null;

try{



con4 = DBConnection.getConnection();

String query =
"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, a.applied_at, 'Application' AS source " +
"FROM applications a " +
"JOIN jobs j ON a.job_id=j.job_id " +
"JOIN jobseeker js ON a.jobseeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(a.status)='accepted' " +

" UNION ALL " +

"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, b.created_at AS applied_at, 'Bid' AS source " +
"FROM bids b " +
"JOIN jobs j ON b.job_id=j.job_id " +
"JOIN jobseeker js ON b.job_seeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(b.bid_status)='accepted' " +

"ORDER BY applied_at DESC";

ps4 = con4.prepareStatement(query);
ps4.setInt(1, employerId3);
ps4.setInt(2, employerId3);

rs4 = ps4.executeQuery();

boolean hasAccepted=false;

while(rs4.next()){
hasAccepted=true;
%>

<div class="review-card" style="border:1.5px solid #b9f5c8;">

<div class="worker-info">
<div style="display:flex; align-items:center; gap:12px;">
<div class="avatar">
<%= rs4.getString("jfirstname").substring(0,1) %>
<%= rs4.getString("jlastname").substring(0,1) %>
</div>
</div>
<div class="worker-details">
<h3>
    <%= rs4.getString("title") %>   <!-- 🔥 JOB TITLE FIRST -->
</h3>

<p style="margin:5px 0; font-weight:600;">
    👤 <%= rs4.getString("jfirstname") %> 
    <%= rs4.getString("jlastname") %>
    <span style="color:#1dbf73;">✔ Accepted (<%= rs4.getString("source") %>)</span>
</p>

<p style="color:#666;">
    📍 <%= rs4.getString("jdistrict") %>
</p>
</div>
</div>

</div>

<%
}

if(!hasAccepted){
%>

<p>No accepted applications.</p>

<%
}

}catch(Exception e){
out.println(e);
}

}
%>
</div>
<!-- REJECTED APPLICATIONS SECTION -->
<div id="rejectedApplicationsSection"
     style="display:none; width:100%; max-width:900px;">

<div class="manage-header">
<div>
<h2>Rejected Applications</h2>
<p>Candidates not selected for the role</p>
</div>
</div>

<%
Integer employerId4 = (Integer) currentSession.getAttribute("eid");

if(employerId4 != null){

Connection con5 = null;
PreparedStatement ps5 = null;
ResultSet rs5 = null;

try{


con5 = DBConnection.getConnection();

String query2 =
"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, a.applied_at, 'Application' AS source " +
"FROM applications a " +
"JOIN jobs j ON a.job_id=j.job_id " +
"JOIN jobseeker js ON a.jobseeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(a.status)='rejected' " +

" UNION ALL " +

"SELECT j.title, js.jfirstname, js.jlastname, js.jemail, js.jdistrict, b.created_at AS applied_at, 'Bid' AS source " +
"FROM bids b " +
"JOIN jobs j ON b.job_id=j.job_id " +
"JOIN jobseeker js ON b.job_seeker_id=js.jid " +
"WHERE j.eid=? AND LOWER(b.bid_status)='rejected' " +

"ORDER BY applied_at DESC";

ps5 = con5.prepareStatement(query2);
ps5.setInt(1, employerId4);
ps5.setInt(2, employerId4);

rs5 = ps5.executeQuery();

boolean hasRejected=false;

while(rs5.next()){
hasRejected=true;
%>

<div class="review-card" style="border:2px solid rgba(229,57,53,0.5);">

<div class="worker-info">

<div class="avatar">
<%= rs5.getString("jfirstname").substring(0,1) %>
<%= rs5.getString("jlastname").substring(0,1) %>
</div>

<div class="worker-details">

<!-- 🔥 JOB TITLE FIRST -->
<h3 style="color:#2563eb;">
    <%= rs5.getString("title") %>
</h3>

<p style="margin:5px 0; font-weight:600;">
    👤 <%= rs5.getString("jfirstname") %> 
    <%= rs5.getString("jlastname") %>
    <span style="color:#e53935;">✖ Rejected (<%= rs5.getString("source") %>)</span>
</p>

<p style="color:#666;">
    📍 <%= rs5.getString("jdistrict") %>
</p>

</div>
</div>

</div>

<%
}

if(!hasRejected){
%>

<p>No rejected applications.</p>

<%
}

}catch(Exception e){
out.println(e);
}

}
%>

</div>
<!-- ================= PAYMENTS SECTION ================= -->


<div id="paymentsSection" style="display:none; width:100%; max-width:900px;">

    <div class="manage-header">
        <div>
            <h2>Payments</h2>
            <p>Track and confirm payments with workers</p>
        </div>
    </div>

<%
Integer empIdPay = (Integer) currentSession.getAttribute("eid");

if(empIdPay != null){

    try{
       

        Connection conPay = DBConnection.getConnection();
        String query =
"SELECT a.application_id AS ref_id, j.title, " +
"js.jfirstname, js.jlastname, " +
"'application' AS type, " +
"IFNULL(p.status,'Pending') AS payment_status " +
"FROM applications a " +
"JOIN jobs j ON a.job_id = j.job_id " +
"JOIN jobseeker js ON a.jobseeker_id = js.jid " +
"LEFT JOIN payments p ON a.application_id = p.application_id " +
"WHERE j.eid=? AND a.status='Accepted' " +

"UNION " +

"SELECT b.bid_id AS ref_id, j.title, " +
"js.jfirstname, js.jlastname, " +
"'bid' AS type, " +
"IFNULL(p.status,'Pending') AS payment_status " +
"FROM bids b " +
"JOIN jobs j ON b.job_id = j.job_id " +
"JOIN jobseeker js ON b.job_seeker_id = js.jid " +
"LEFT JOIN payments p ON b.bid_id = p.application_id " +
"WHERE j.eid=? AND b.bid_status='Accepted'";

PreparedStatement psPay = conPay.prepareStatement(query);
psPay.setInt(1, empIdPay);
psPay.setInt(2, empIdPay);   // ⚠️ IMPORTANT
        ResultSet rsPay = psPay.executeQuery();

        boolean hasData = false;

        while(rsPay.next()){
            hasData = true;

            String status = rsPay.getString("payment_status");

            String color = "#ffc107"; // Pending
            if("Requested".equals(status)) color="#ff9800";
            else if("Paid".equals(status)) color="#2196f3";
            else if("Confirmed".equals(status)) color="#28a745";
            else if("Failed".equals(status)) color="#dc3545";
%>

<div class="review-card">

    <div class="worker-info">
        <div class="avatar">
            <%= rsPay.getString("jfirstname").charAt(0) %>
            <%= rsPay.getString("jlastname").charAt(0) %>
        </div>

        <div class="worker-details">
            <h3>
                <%= rsPay.getString("jfirstname") %>
                <%= rsPay.getString("jlastname") %>
            </h3>

            <div class="meta">
                <span>Job: <%= rsPay.getString("title") %></span>
            </div>

            <p>
                <strong>Status:</strong>
                <span style="padding:5px 12px;border-radius:12px;color:white;background:<%= color %>;">
                    <%= status %>
                </span>
            </p>
        </div>
    </div>

    <div class="actions">

<% if("Pending".equals(status)) { %>

    <p style="color:#777;">Waiting for worker to request payment</p>

<% } else if("Requested".equals(status)) { %>

    <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=paid&type=<%= rsPay.getString("type") %>"
       class="accept-btn">Mark Paid 💸</a>

<% } else if("Failed".equals(status)) { %>

    <div style="color:#dc3545; font-weight:600; margin-bottom:8px;">
        ⚠️ Worker reported payment NOT received
    </div>

    <a href="UpdatePaymentServlet?applicationId=<%= rsPay.getInt("ref_id") %>&action=paid&type=<%= rsPay.getString("type") %>"
       style="background:#dc3545; color:#fff; padding:8px 18px;
              border-radius:8px; text-decoration:none;">
        🔁 Re-Pay Now
    </a>

<% } else if("Paid".equals(status)) { %>

    <p style="color:#555;">Waiting for worker confirmation...</p>

<% } else if("Confirmed".equals(status)) { %>

    <p style="color:green; font-weight:600;">✔ Payment Completed</p>

<% } %>

    </div>

</div>

<%
        }

        if(!hasData){
%>

<p>No payment records yet.</p>

<%
        }

        conPay.close();

    }catch(Exception e){
        e.printStackTrace();
    }
}
%>

</div>


<!-- ================= EMPLOYER → RATE & REVIEW SECTION ================= -->
<div id="reviewsSection" style="display:none; width:100%; max-width:900px;">

<%
/* ── Flash messages ─────────────────────────────────────────────────────── */
String ratingSuccessEmp = (String) currentSession.getAttribute("ratingMsg_emp_success");
String ratingErrorEmp   = (String) currentSession.getAttribute("ratingMsg_emp_error");
if (ratingSuccessEmp != null) { currentSession.removeAttribute("ratingMsg_emp_success"); }
if (ratingErrorEmp   != null) { currentSession.removeAttribute("ratingMsg_emp_error"); }
%>

<% if (ratingSuccessEmp != null) { %>
<div style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:10px;
            padding:14px 18px;color:#065f46;font-weight:600;margin-bottom:20px;">
    ✅ <%= ratingSuccessEmp %>
</div>
<% } %>

<% if (ratingErrorEmp != null) { %>
<div style="background:#fef2f2;border:1px solid #fca5a5;border-radius:10px;
            padding:14px 18px;color:#b91c1c;font-weight:600;margin-bottom:20px;">
    ⚠️ <%= ratingErrorEmp %>
</div>
<% } %>

<div class="manage-header">
    <div>
        <h2>Rate & Review Workers</h2>
        <p>Rate workers whose payment has been confirmed</p>
    </div>
</div>

<%
/*
 * Show all accepted + payment-confirmed workers that the employer
 * has NOT yet rated.
 */
Integer empIdRev = (Integer) currentSession.getAttribute("eid");
if (empIdRev != null) {
    Connection conRev = null;
    PreparedStatement psRev = null;
    ResultSet rsRev = null;
    try {
        conRev = db.DBConnection.getConnection();

        /*
         * Union: application-based + bid-based accepted & payment confirmed
         * Left-join ratings to detect already-rated rows.
         */
        String sqlRev =
            "SELECT j.job_id, j.title, " +
            "js.jid AS jobseeker_id, CONCAT(js.jfirstname,' ',js.jlastname) AS worker_name, " +
            "js.jdistrict, " +
            "r.rating_id AS already_rated " +
            "FROM applications a " +
            "JOIN jobs j ON j.job_id = a.job_id " +
            "JOIN jobseeker js ON js.jid = a.jobseeker_id " +
            "JOIN payments p ON p.application_id = a.application_id " +
            "LEFT JOIN ratings r ON r.job_id = j.job_id " +
            "    AND r.employer_id = j.eid " +
            "    AND r.jobseeker_id = js.jid " +
            "    AND r.rating_by = 'Employer' " +
            "WHERE j.eid = ? AND a.status = 'Accepted' AND p.status = 'Confirmed' " +

            "UNION " +

            "SELECT j.job_id, j.title, " +
            "js.jid AS jobseeker_id, CONCAT(js.jfirstname,' ',js.jlastname) AS worker_name, " +
            "js.jdistrict, " +
            "r.rating_id AS already_rated " +
            "FROM bids b " +
            "JOIN jobs j ON j.job_id = b.job_id " +
            "JOIN jobseeker js ON js.jid = b.job_seeker_id " +
            "JOIN payments p ON p.application_id = b.bid_id " +
            "LEFT JOIN ratings r ON r.job_id = j.job_id " +
            "    AND r.employer_id = j.eid " +
            "    AND r.jobseeker_id = js.jid " +
            "    AND r.rating_by = 'Employer' " +
            "WHERE j.eid = ? AND b.bid_status = 'Accepted' AND p.status = 'Confirmed' " +

            "ORDER BY job_id DESC";

        psRev = conRev.prepareStatement(sqlRev);
        psRev.setInt(1, empIdRev);
        psRev.setInt(2, empIdRev);
        rsRev = psRev.executeQuery();

        boolean anyRow = false;
        while (rsRev.next()) {
            anyRow = true;
            boolean rated = (rsRev.getObject("already_rated") != null);
%>

<div style="display:flex; justify-content:space-between; align-items:center;
            border:1px solid #e5e7eb; border-radius:12px; padding:18px 22px;
            margin-bottom:14px; background:#fff;
            box-shadow:0 1px 4px rgba(0,0,0,0.05);">

    <div>
        <h4 style="margin:0; font-size:16px; color:#1a2a3a;">
            👤 <%= rsRev.getString("worker_name") %>
        </h4>
        <p style="margin:4px 0; font-size:13px; color:#6b7280;">
            Job: <strong><%= rsRev.getString("title") %></strong> |
            📍 <%= rsRev.getString("jdistrict") %>
        </p>
        <% if (rated) { %>
        <span style="display:inline-block; margin-top:6px; padding:3px 12px;
                     background:#dcfce7; color:#166534; border-radius:20px;
                     font-size:12px; font-weight:600;">
            ✅ Already Rated
        </span>
        <% } else { %>
        <span style="display:inline-block; margin-top:6px; padding:3px 12px;
                     background:#fef9c3; color:#854d0e; border-radius:20px;
                     font-size:12px; font-weight:600;">
            ⏳ Pending Your Review
        </span>
        <% } %>
    </div>

    <% if (!rated) { %>
    <a href="rating_form.jsp?job_id=<%= rsRev.getInt("job_id") %>&employer_id=<%= empIdRev %>&jobseeker_id=<%= rsRev.getInt("jobseeker_id") %>&rating_by=Employer">
        <button style="background:linear-gradient(135deg,#1b5e20,#2e7d32);
                       color:#fff; border:none; border-radius:10px;
                       padding:10px 20px; font-size:14px; font-weight:600;
                       cursor:pointer; white-space:nowrap;">
            ⭐ Rate Worker
        </button>
    </a>
    <% } else { %>
    <a href="view_reviews.jsp?job_id=<%= rsRev.getInt("job_id") %>&target=jobseeker&id=<%= rsRev.getInt("jobseeker_id") %>">
        <button style="background:#f3f4f6; color:#374151; border:1px solid #e5e7eb;
                       border-radius:10px; padding:10px 20px; font-size:14px;
                       cursor:pointer; white-space:nowrap;">
            👁 View Review
        </button>
    </a>
    <% } %>

</div>

<%
        }
        if (!anyRow) {
%>
<div style="text-align:center; padding:50px 20px; color:#9ca3af;">
    <p style="font-size:40px; margin-bottom:10px;">⭐</p>
    <h3 style="color:#6b7280;">No completed jobs to review yet</h3>
    <p>Rating becomes available after payment is confirmed.</p>
</div>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsRev  != null) try { rsRev.close();  } catch(Exception ignored){}
        if (psRev  != null) try { psRev.close();  } catch(Exception ignored){}
        if (conRev != null) try { conRev.close(); } catch(Exception ignored){}
    }
}
%>

<hr style="margin:40px 0; border:none; border-top:1px solid #f3f4f6;">

<!-- ── Reviews received by this employer from jobseekers ────────────────── -->
<div class="manage-header">
    <div>
        <h2>Reviews You've Received</h2>
        <p>What workers say about you</p>
    </div>
</div>

<%
if (empIdRev != null) {
    Connection conMyRev = null;
    PreparedStatement psMyRev = null;
    ResultSet rsMyRev = null;
    try {
        conMyRev = db.DBConnection.getConnection();

        // Average rating for this employer
        PreparedStatement psAvg = conMyRev.prepareStatement(
            "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
            "FROM ratings WHERE employer_id=? AND rating_by='Jobseeker'"
        );
        psAvg.setInt(1, empIdRev);
        ResultSet rsAvg = psAvg.executeQuery();
        double avgR = 0; int totalR = 0;
        if (rsAvg.next()) { avgR = rsAvg.getDouble("avg_r"); totalR = rsAvg.getInt("total"); }
        rsAvg.close(); psAvg.close();
%>

<div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:14px;
            padding:20px 24px; margin-bottom:24px; display:flex;
            align-items:center; gap:16px;">
    <div style="font-size:40px; line-height:1;">⭐</div>
    <div>
        <div style="font-size:28px; font-weight:800; color:#166534;">
            <%= totalR > 0 ? avgR : "—" %><span style="font-size:16px; color:#4b5563;">/5</span>
        </div>
        <div style="font-size:14px; color:#6b7280;">
            <%
            if (totalR > 0) {
                out.print(starHtml(avgR));
            } else {
                out.print("No reviews yet");
            }
            %>
            <% if (totalR > 0) { %> &nbsp;(<%= totalR %> review<%= totalR!=1?"s":"" %>)<% } %>
        </div>
    </div>
</div>

<%
        psMyRev = conMyRev.prepareStatement(
            "SELECT r.rating_value, r.review_text, r.created_at, " +
            "r.employer_behavior, r.timely_payment, r.work_environment, r.fairness_communication, " +
            "CONCAT(js.jfirstname,' ',js.jlastname) AS reviewer_name, " +
            "j.title AS job_title " +
            "FROM ratings r " +
            "JOIN jobseeker js ON js.jid = r.jobseeker_id " +
            "JOIN jobs j ON j.job_id = r.job_id " +
            "WHERE r.employer_id=? AND r.rating_by='Jobseeker' " +
            "ORDER BY r.created_at DESC"
        );
        psMyRev.setInt(1, empIdRev);
        rsMyRev = psMyRev.executeQuery();
        boolean anyReview = false;

        while (rsMyRev.next()) {
            anyReview = true;
            double rv = rsMyRev.getDouble("rating_value");
%>

<div style="border:1px solid #e5e7eb; border-radius:12px; padding:18px 22px;
            margin-bottom:14px; background:#fff;">
    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:8px;">
        <div>
            <strong style="font-size:15px;"><%= rsMyRev.getString("reviewer_name") %></strong>
            <span style="font-size:12px; color:#9ca3af; margin-left:8px;">
                • <%= rsMyRev.getString("job_title") %>
            </span>
        </div>
        <div style="font-size:20px; color:#f59e0b;">
            <%= starHtml(rv) %>
            <span style="font-size:13px; color:#6b7280; font-weight:600;">
                <%= String.format("%.1f", rv) %>
            </span>
        </div>
    </div>

    <!-- Criteria breakdown -->
    <div style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px;">
        <%= miniCriteria("Behavior",    rsMyRev.getInt("employer_behavior")) %>
        <%= miniCriteria("Timely Pay",  rsMyRev.getInt("timely_payment")) %>
        <%= miniCriteria("Work Env",    rsMyRev.getInt("work_environment")) %>
        <%= miniCriteria("Fairness",    rsMyRev.getInt("fairness_communication")) %>
    </div>

    <% String review = rsMyRev.getString("review_text");
       if (review != null && !review.trim().isEmpty()) { %>
    <p style="font-size:14px; color:#374151; line-height:1.6; margin:0;">
        "<%= review.trim() %>"
    </p>
    <% } %>

    <div style="font-size:12px; color:#9ca3af; margin-top:8px;">
        <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(rsMyRev.getTimestamp("created_at")) %>
    </div>
</div>

<%
        }
        if (!anyReview) {
%>
<p style="color:#9ca3af; text-align:center; padding:20px 0;">No reviews received yet.</p>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsMyRev  != null) try { rsMyRev.close();  } catch(Exception ignored){}
        if (psMyRev  != null) try { psMyRev.close();  } catch(Exception ignored){}
        if (conMyRev != null) try { conMyRev.close(); } catch(Exception ignored){}
    }
}
%>

</div><!-- end reviewsSection -->

<%!
/* Renders filled/empty star HTML for a given rating (0‑5) */
private String starHtml(double rating) {
    StringBuilder sb = new StringBuilder();
    for (int i = 1; i <= 5; i++) {
        if (i <= Math.floor(rating))       sb.append("<span style='color:#f59e0b;'>★</span>");
        else if (i - rating < 1 && i - rating > 0) sb.append("<span style='color:#f59e0b;'>½</span>");
        else                               sb.append("<span style='color:#d1d5db;'>★</span>");
    }
    return sb.toString();
}

/* Small criteria badge */
private String miniCriteria(String label, int val) {
    if (val == 0) return "";
    return "<span style='background:#f0f9ff;color:#0369a1;border:1px solid #bae6fd;" +
           "border-radius:20px;font-size:12px;padding:2px 10px;'>" +
           label + ": " + val + "/5</span>";
}
%>



    </main>
</div>

<!-- JS  -->
<script>
const filters = document.querySelectorAll("select, input");
const cards = document.querySelectorAll(".review-card");
filters.forEach(f => f.addEventListener("input", applyFilters));
function applyFilters() {
    cards.forEach(card => {
        card.style.display =
            card.innerText.toLowerCase()
            .includes(searchInput.value.toLowerCase())
            ? "block" : "none";
    });
}
</script>


<script>
document.addEventListener("DOMContentLoaded", function () {
    const params = new URLSearchParams(window.location.search);
    const section = params.get("section");

    if (section) {
        showSection(section, null);
    }
});
</script>

<script>
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", () => {
    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
});
</script>
<script>
function closeModal() {
    document.getElementById("successModal").style.display = "none";
}
setTimeout(() => {
    const modal = document.getElementById("successModal");
    if (modal) modal.style.display = "none";
}, 3000);


function showSection(section, event) {
    // Show Post New Job button only on dashboard
    const postJobBtn = document.getElementById("postJobBtn");
    if (postJobBtn) {
        postJobBtn.style.display = (section === "dashboard") ? "inline" : "none";
    }
    const sections = [
        "dashboardSection",
        "manageJobsSection",
        "reviewApplicationsSection",
        "acceptedApplicationsSection",
        "rejectedApplicationsSection",
        "paymentsSection",
        "reviewsSection" 
    ];

    // Hide all sections
    sections.forEach(function(id) {
        const el = document.getElementById(id);
        if(el){
            el.style.display = "none";
        }
    });

    // Show selected section
    if(section === "dashboard"){
        document.getElementById("dashboardSection").style.display = "block";
    }
    else if(section === "manageJobs"){
        document.getElementById("manageJobsSection").style.display = "block";
    }
    else if(section === "reviewApplications"){
        document.getElementById("reviewApplicationsSection").style.display = "block";
    }
    else if(section === "acceptedApplications"){
        document.getElementById("acceptedApplicationsSection").style.display = "block";
    }
    else if(section === "rejectedApplications"){
        document.getElementById("rejectedApplicationsSection").style.display = "block";
    }
    else if(section === "payments"){
        document.getElementById("paymentsSection").style.display = "block";
    }
    else if(section === "reviews"){
    document.getElementById("reviewsSection").style.display = "block";
}

    // Remove active class from all sidebar links
    document.querySelectorAll(".sidebar a").forEach(function(a){
        a.classList.remove("active");
    });

    // Add active class to clicked link
    if(event){
        event.target.classList.add("active");
    }
}

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

<script>
window.onload = function() {
    // Check if there are any accepted applications
   
};
</script>
<script>
document.querySelectorAll(".respondBidBtn").forEach(function(button) {
    button.addEventListener("click", function() {
        const bidId = this.dataset.bidid;
        const action = this.dataset.action;
        const card = document.getElementById("bidCard_" + bidId);

        fetch(`RespondBidByEmployerServlet?bid_id=${bidId}&action=${action}`)
            .then(response => response.text())
            .then(data => {
                // Remove card from review section
                card.remove();

                // Create new card for Accepted/Rejected section
                const newCard = card.cloneNode(true);
                newCard.querySelectorAll("button").forEach(b => b.remove()); // remove buttons

                if(action === "accept") {
                    newCard.querySelector("h3").innerHTML += ' <span style="color:#1dbf73;">✔ Accepted</span>';
                    const acceptedSection = document.getElementById("acceptedApplicationsSection");
                    acceptedSection.style.display = "block";
                    acceptedSection.appendChild(newCard);
                } else {
                    newCard.querySelector("h3").innerHTML += ' <span style="color:#e53935;">✖ Rejected</span>';
                    const rejectedSection = document.getElementById("rejectedApplicationsSection");
                    rejectedSection.style.display = "block";
                    rejectedSection.appendChild(newCard);
                }
            })
            .catch(err => console.error(err));
    });
});


</script>
<script>
// ================= NOTIFICATION BELL =================
function toggleNotifPanel() {
    var panel = document.getElementById("notifPanel");
    if (panel.style.display === "block") {
        panel.style.display = "none";
    } else {
        panel.style.display = "block";
        // mark all as read silently
        fetch("MarkAllNotifReadServlet").then(function() {
            var badge = document.getElementById("notifBadge");
            if (badge) badge.remove();
        });
    }
}

// close panel when clicking outside
document.addEventListener("click", function(e) {
    var panel = document.getElementById("notifPanel");
    if (!panel) return;
    var bell = document.querySelector("[onclick='toggleNotifPanel()']");
    if (!panel.contains(e.target) && !bell.contains(e.target)) {
        panel.style.display = "none";
    }
});
function markAllRead() {
    fetch("MarkAllNotifReadServlet")
    .then(res => res.text())
    .then(data => {
        console.log(data);

        // remove badge
        var badge = document.getElementById("notifBadge");
        if (badge) badge.remove();

        // update UI
        document.querySelectorAll("#notifPanel div").forEach(function(item, index) {
            if(index !== 0) item.style.background = "#fff";
        });
    });
}
</script>
</body>
</html> 
