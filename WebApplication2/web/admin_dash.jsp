<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<!-- jsPDF for PDF export -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
<!-- SheetJS for Excel export -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<%
    // Monthly registrations (last 12 months)
String empMonthlyJson = "[]", jsMonthlyJson = "[]", appMonthlyJson = "[]";
String jobStatusJson = "[]", jobTypeJson = "[]";

Connection conCharts = null;
try {
    conCharts = DBConnection.getConnection();

    // Employers per month
    ResultSet rsEM = conCharts.createStatement().executeQuery(
        "SELECT DATE_FORMAT(created_at,'%b') AS mon, MONTH(created_at) AS mnum, COUNT(*) AS cnt " +
        "FROM employer WHERE created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) " +
        "GROUP BY mnum, mon ORDER BY mnum");
    StringBuilder sbEM = new StringBuilder("[");
    while(rsEM.next()) sbEM.append("{\"m\":\"").append(rsEM.getString("mon")).append("\",\"c\":").append(rsEM.getInt("cnt")).append("},");
    if (sbEM.length()>1) sbEM.deleteCharAt(sbEM.length()-1);
    sbEM.append("]"); empMonthlyJson = sbEM.toString(); rsEM.close();

    // Jobseekers per month
    ResultSet rsJM = conCharts.createStatement().executeQuery(
        "SELECT DATE_FORMAT(created_at,'%b') AS mon, MONTH(created_at) AS mnum, COUNT(*) AS cnt " +
        "FROM jobseeker WHERE created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) " +
        "GROUP BY mnum, mon ORDER BY mnum");
    StringBuilder sbJM = new StringBuilder("[");
    while(rsJM.next()) sbJM.append("{\"m\":\"").append(rsJM.getString("mon")).append("\",\"c\":").append(rsJM.getInt("cnt")).append("},");
    if (sbJM.length()>1) sbJM.deleteCharAt(sbJM.length()-1);
    sbJM.append("]"); jsMonthlyJson = sbJM.toString(); rsJM.close();

    // Applications per month
    ResultSet rsAM = conCharts.createStatement().executeQuery(
        "SELECT DATE_FORMAT(applied_at,'%b') AS mon, MONTH(applied_at) AS mnum, COUNT(*) AS cnt " +
        "FROM applications WHERE applied_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) " +
        "GROUP BY mnum, mon ORDER BY mnum");
    StringBuilder sbAM = new StringBuilder("[");
    while(rsAM.next()) sbAM.append("{\"m\":\"").append(rsAM.getString("mon")).append("\",\"c\":").append(rsAM.getInt("cnt")).append("},");
    if (sbAM.length()>1) sbAM.deleteCharAt(sbAM.length()-1);
    sbAM.append("]"); appMonthlyJson = sbAM.toString(); rsAM.close();

    // Job status
    ResultSet rsJS = conCharts.createStatement().executeQuery(
        "SELECT status, COUNT(*) AS cnt FROM jobs GROUP BY status");
    int activeJ=0, inactiveJ=0;
    while(rsJS.next()) {
        if("Active".equalsIgnoreCase(rsJS.getString("status"))) activeJ=rsJS.getInt("cnt");
        else inactiveJ+=rsJS.getInt("cnt");
    }
    jobStatusJson = "[" + activeJ + "," + inactiveJ + "]"; rsJS.close();

    // Job type
    ResultSet rsJT = conCharts.createStatement().executeQuery(
        "SELECT job_type, COUNT(*) AS cnt FROM jobs WHERE job_type IS NOT NULL GROUP BY job_type");
    StringBuilder sbJT = new StringBuilder("{");
    while(rsJT.next()) sbJT.append("\"").append(rsJT.getString("job_type")).append("\":").append(rsJT.getInt("cnt")).append(",");
    if (sbJT.length()>1) sbJT.deleteCharAt(sbJT.length()-1);
    sbJT.append("}"); jobTypeJson = sbJT.toString(); rsJT.close();

} catch(Exception e){ e.printStackTrace(); }
finally { if(conCharts!=null) try{conCharts.close();}catch(Exception ig){} }

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("adminId") == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
    String adminUsername = (String) adminSession.getAttribute("adminUsername");

    int totalEmployers = 0, totalJobseekers = 0, totalJobs = 0, totalApplications = 0;
    Connection conStats = null;
    try {
        conStats = DBConnection.getConnection();
        ResultSet rs;
        rs = conStats.createStatement().executeQuery("SELECT COUNT(*) FROM employer");
        if (rs.next()) totalEmployers = rs.getInt(1); rs.close();
        rs = conStats.createStatement().executeQuery("SELECT COUNT(*) FROM jobseeker");
        if (rs.next()) totalJobseekers = rs.getInt(1); rs.close();
        rs = conStats.createStatement().executeQuery("SELECT COUNT(*) FROM jobs WHERE status='Active'");
        if (rs.next()) totalJobs = rs.getInt(1); rs.close();
        rs = conStats.createStatement().executeQuery("SELECT COUNT(*) FROM applications");
        if (rs.next()) totalApplications = rs.getInt(1); rs.close();
    } catch (Exception e) { e.printStackTrace(); }
    finally { if (conStats != null) try { conStats.close(); } catch (Exception ignored) {} }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard | SkillMitra</title>
    <link rel="stylesheet" href="admin_dash.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .tbl-rating {
            display: inline-flex; align-items: center; gap: 4px;
            background: #fffbeb; border: 1px solid #fde68a;
            border-radius: 20px; padding: 3px 10px;
            font-size: 12px; color: #92400e; font-weight: 600; white-space: nowrap;
        }
        .tbl-rating .stars { color: #f59e0b; font-size: 11px; }
        .tbl-no-rating { font-size: 11px; color: #9ca3af; font-style: italic; }
        .btn-view-profile {
            background: #eff6ff; color: #1d4ed8; padding: 5px 12px;
            border-radius: 6px; text-decoration: none; font-size: 12px;
            font-weight: 600; border: 1px solid #bfdbfe; margin-right: 6px; white-space: nowrap;
        }
        .btn-view-profile:hover { background: #dbeafe; }
        .sort-bar {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 12px; flex-wrap: wrap;
        }
        .sort-bar label { font-size: 13px; color: #6b7280; font-weight: 500; }
        .sort-select {
            padding: 7px 32px 7px 12px;
            border: 1px solid #e0e0e0; border-radius: 8px;
            font-size: 13px; color: #1a2a3a; background: #fff;
            appearance: none; outline: none; cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath fill='%239ca3af' d='M7 10l5 5 5-5z'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 8px center;
        }
        .sort-select:focus { border-color: #4a6fa5; }
    </style>
</head>
<body>

<!-- HEADER -->
<header>
    <div style="display:flex;align-items:center;gap:12px;">
        <button class="hamburger" id="hamburger">&#9776;</button>
        <img src="skillmitralogo.jpg" alt="Logo" style="width:35px;height:35px;border-radius:50%;object-fit:cover;">
        <span class="logo">SkillMitra</span>
    </div>
    <div style="display:flex;align-items:center;gap:16px;">
        <span style="font-size:13px;color:rgba(255,255,255,0.8);">👤 <%= adminUsername %></span>
        <a href="AdminLogoutServlet"
           style="background:rgba(255,255,255,0.15);color:#fff;padding:7px 16px;
                  border-radius:8px;text-decoration:none;font-size:13px;
                  border:1px solid rgba(255,255,255,0.25);transition:0.2s;"
           onmouseover="this.style.background='rgba(255,255,255,0.25)'"
           onmouseout="this.style.background='rgba(255,255,255,0.15)'">Logout</a>
    </div>
</header>

<!-- SIDEBAR -->
<aside class="sidebar" id="sidebar">
    <h2>Admin Panel</h2>
    <a class="active" onclick="showSection('dashboard',this)">
        <i class="fa-solid fa-house nav-icon"></i>
        <span class="nav-label"> Dashboard</span>
    </a>
    <a onclick="showSection('employers',this)">
        <i class="fa-solid fa-building nav-icon"></i>
        <span class="nav-label"> Employers</span>
    </a>
    <a onclick="showSection('jobseekers',this)">
        <i class="fa-solid fa-users nav-icon"></i>
        <span class="nav-label"> Job Seekers</span>
    </a>
    <a onclick="showSection('jobs',this)">
        <i class="fa-solid fa-briefcase nav-icon"></i>
        <span class="nav-label"> All Jobs</span>
    </a>
    <div style="margin-top:auto;padding:16px 12px;border-top:0.5px solid rgba(255,255,255,0.15);
                display:flex;align-items:center;gap:10px;">
        <div style="width:38px;height:38px;border-radius:50%;background:rgba(255,255,255,0.15);
                    display:flex;align-items:center;justify-content:center;
                    font-size:14px;font-weight:600;color:white;flex-shrink:0;">AD</div>
        <div style="overflow:hidden;">
            <p style="font-size:13px;font-weight:500;color:white;margin:0;"><%= adminUsername %></p>
            <p style="font-size:11px;color:rgba(255,255,255,0.6);margin:0;">Administrator</p>
        </div>
    </div>
</aside>

<!-- MAIN CONTENT -->
<div class="content" id="mainContent">

    <!-- ═══ DASHBOARD ═══ -->
    <div id="dashboardSection">
        <div class="topbar">Welcome, <b><%= adminUsername %></b></div>
        <div class="dashboard-header">
            <h2>Dashboard Overview</h2>
            <p>SkillMitra platform at a glance.</p>
        </div>
        <div class="stats-cards">
            <div class="stats-card">
                <span class="title">Total Employers</span>
                <span class="number" style="color:#3b5bdb;"><%= totalEmployers %></span>
                <span class="change">Registered companies</span>
            </div>
            <div class="stats-card">
                <span class="title">Total Job Seekers</span>
                <span class="number" style="color:#16a34a;"><%= totalJobseekers %></span>
                <span class="change">Registered workers</span>
            </div>
            <div class="stats-card">
                <span class="title">Active Jobs</span>
                <span class="number" style="color:#d97706;"><%= totalJobs %></span>
                <span class="change">Currently open</span>
            </div>
            <div class="stats-card">
                <span class="title">Total Applications</span>
                <span class="number" style="color:#7c3aed;"><%= totalApplications %></span>
                <span class="change">Across all jobs</span>
            </div>
        </div>
        <div class="lower-section">
            <div class="lower-card">
                <h3>Recent Employers</h3>
                <table>
                    <tr><th>Name</th><th>Company</th><th>Email</th><th>District</th></tr>
                    <%
                    Connection conRE = null;
                    try {
                        conRE = DBConnection.getConnection();
                        ResultSet rsRE = conRE.prepareStatement(
                            "SELECT efirstname,elastname,ecompanyname,eemail,edistrict FROM employer ORDER BY eid DESC LIMIT 5"
                        ).executeQuery();
                        boolean anyRE = false;
                        while (rsRE.next()) { anyRE = true;
                    %>
                    <tr>
                        <td><%= rsRE.getString("efirstname") %> <%= rsRE.getString("elastname") %></td>
                        <td><%= rsRE.getString("ecompanyname") %></td>
                        <td style="font-size:12px;"><%= rsRE.getString("eemail") %></td>
                        <td><%= rsRE.getString("edistrict")!=null?rsRE.getString("edistrict"):"—" %></td>
                    </tr>
                    <% } if (!anyRE) { %>
                    <tr><td colspan="4" style="text-align:center;color:#999;">No employers yet</td></tr>
                    <% } rsRE.close();
                    } catch (Exception e) { e.printStackTrace(); }
                    finally { if (conRE!=null) try{conRE.close();}catch(Exception ig){} } %>
                </table>
            </div>
            <div class="lower-card">
                <h3>Recent Job Seekers</h3>
                <table>
                    <tr><th>Name</th><th>Email</th><th>District</th><th>Education</th></tr>
                    <%
                    Connection conRJ = null;
                    try {
                        conRJ = DBConnection.getConnection();
                        ResultSet rsRJ = conRJ.prepareStatement(
                            "SELECT jfirstname,jlastname,jemail,jdistrict,jeducation FROM jobseeker ORDER BY jid DESC LIMIT 5"
                        ).executeQuery();
                        boolean anyRJ = false;
                        while (rsRJ.next()) { anyRJ = true;
                    %>
                    <tr>
                        <td><%= rsRJ.getString("jfirstname") %> <%= rsRJ.getString("jlastname") %></td>
                        <td style="font-size:12px;"><%= rsRJ.getString("jemail") %></td>
                        <td><%= rsRJ.getString("jdistrict")!=null?rsRJ.getString("jdistrict"):"—" %></td>
                        <td><%= rsRJ.getString("jeducation")!=null?rsRJ.getString("jeducation"):"—" %></td>
                    </tr>
                    <% } if (!anyRJ) { %>
                    <tr><td colspan="4" style="text-align:center;color:#999;">No job seekers yet</td></tr>
                    <% } rsRJ.close();
                    } catch (Exception e) { e.printStackTrace(); }
                    finally { if (conRJ!=null) try{conRJ.close();}catch(Exception ig){} } %>
                </table>
            </div>
        </div>
        <!-- ── CHARTS ROW ── -->
<div style="margin-top:28px;">
    <h3 style="font-size:16px;font-weight:600;color:#1a2a3a;margin-bottom:16px;">
        Platform Analytics
    </h3>

    <!-- Export full report -->
    <div style="display:flex;gap:10px;margin-bottom:18px;flex-wrap:wrap;">
        <button onclick="exportFullPDF()"
            style="display:flex;align-items:center;gap:6px;padding:8px 16px;
                   background:#fef2f2;color:#991b1b;border:1px solid #fca5a5;
                   border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;">
            &#128196; Download Full Report (PDF)
        </button>
        <button onclick="exportDashboardExcel()"
            style="display:flex;align-items:center;gap:6px;padding:8px 16px;
                   background:#f0fdf4;color:#166534;border:1px solid #86efac;
                   border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;">
            &#128202; Export Summary (Excel)
        </button>
    </div>

    <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:18px;">

        <!-- Chart 1: Monthly Registrations -->
        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    padding:20px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <p style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;">
                Monthly Registrations
            </p>
            <p style="font-size:11px;color:#9ca3af;margin-bottom:14px;">Last 12 months</p>
            <div style="display:flex;gap:14px;margin-bottom:10px;font-size:11px;color:#6b7280;">
                <span><span style="display:inline-block;width:10px;height:10px;
                    border-radius:2px;background:#3b82f6;margin-right:4px;"></span>Employers</span>
                <span><span style="display:inline-block;width:10px;height:10px;
                    border-radius:2px;background:#16a34a;margin-right:4px;"></span>Job Seekers</span>
            </div>
            <div style="position:relative;height:220px;">
                <canvas id="chartRegistrations"></canvas>
            </div>
        </div>

        <!-- Chart 2: Job Status Donut -->
        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    padding:20px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <p style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;">
                Job Status Breakdown
            </p>
            <p style="font-size:11px;color:#9ca3af;margin-bottom:14px;">Active vs Inactive</p>
            <div style="display:flex;gap:14px;margin-bottom:10px;font-size:11px;color:#6b7280;">
                <span><span style="display:inline-block;width:10px;height:10px;
                    border-radius:2px;background:#16a34a;margin-right:4px;"></span>Active</span>
                <span><span style="display:inline-block;width:10px;height:10px;
                    border-radius:2px;background:#ef4444;margin-right:4px;"></span>Inactive</span>
            </div>
            <div style="position:relative;height:220px;">
                <canvas id="chartJobStatus"></canvas>
            </div>
        </div>

        <!-- Chart 3: Applications Line -->
        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    padding:20px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <p style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;">
                Applications Over Time
            </p>
            <p style="font-size:11px;color:#9ca3af;margin-bottom:14px;">Monthly trend</p>
            <div style="position:relative;height:220px;">
                <canvas id="chartApplications"></canvas>
            </div>
        </div>

        <!-- Chart 4: Job Type Pie -->
        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    padding:20px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <p style="font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;">
                Job Type Distribution
            </p>
            <p style="font-size:11px;color:#9ca3af;margin-bottom:14px;">By employment type</p>
            <div style="position:relative;height:220px;">
                <canvas id="chartJobTypes"></canvas>
            </div>
        </div>

    </div>
</div>
    </div>

    <!-- ═══ EMPLOYERS ═══ -->
    <div id="employersSection" style="display:none;">
        <div class="manage-header">
            <div><h2>All Employers</h2><p>Manage registered employers on SkillMitra</p></div>
        </div>
        <%
        String empDelSuccess = (String) adminSession.getAttribute("adminMsg_success");
        String empDelError   = (String) adminSession.getAttribute("adminMsg_error");
        if (empDelSuccess != null) adminSession.removeAttribute("adminMsg_success");
        if (empDelError   != null) adminSession.removeAttribute("adminMsg_error");
        %>
        <% if (empDelSuccess != null) { %><div class="flash-success"><%= empDelSuccess %></div><% } %>
        <% if (empDelError   != null) { %><div class="flash-error"><%= empDelError %></div><% } %>

        <div class="sort-bar">
            <input type="text" id="empSearch" placeholder="🔍 Search by name, email or company..."
                   onkeyup="filterTable('empTableBody',this.value)"
                   style="flex:1;min-width:200px;padding:8px 14px;border:1px solid #e0e0e0;
                          border-radius:8px;font-size:14px;outline:none;
                          box-shadow:0 1px 4px rgba(0,0,0,0.06);">
            <label for="empSort">Sort by:</label>
            <select id="empSort" class="sort-select" onchange="sortTable('empTableBody',this.value)">
                <option value="default">Default</option>
                <option value="rating-desc">⭐ Rating (High → Low)</option>
                <option value="az">🔤 A → Z</option>
                <option value="za">🔤 Z → A</option>
            </select>
            <button onclick="exportEmpPDF()"  class="exp-btn-pdf">&#128196; PDF</button>
<button onclick="exportEmpExcel()" class="exp-btn-xl">&#128202; Excel</button>
        </div>

        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.05);">
            <table style="margin:0;">
                <thead>
                    <tr style="background:#f8fafc;">
                        <th>S.No.</th><th>Name</th><th>Company</th><th>Email</th>
                        <th>Phone</th><th>District</th><th>State</th>
                        <th>Rating ⭐</th><th>Action</th>
                    </tr>
                </thead>
                <tbody id="empTableBody">
                <%
                Connection conEmp = null;
                try {
                    conEmp = DBConnection.getConnection();
                    PreparedStatement psEmp = conEmp.prepareStatement(
                        "SELECT e.eid, e.efirstname, e.elastname, e.ecompanyname, e.eemail, " +
                        "       e.ephone, e.edistrict, e.estate, " +
                        "       ROUND(COALESCE(AVG(r.rating_value),0),1) AS avg_rating, " +
                        "       COUNT(r.rating_id) AS total_reviews " +
                        "FROM employer e " +
                        "LEFT JOIN ratings r ON r.employer_id=e.eid AND r.rating_by='Jobseeker' " +
                        "GROUP BY e.eid ORDER BY e.eid DESC"
                    );
                    ResultSet rsEmp = psEmp.executeQuery();
                    int empRow = 0;
                    while (rsEmp.next()) {
                        empRow++;
                        double eAvg = rsEmp.getDouble("avg_rating");
                        int    eTot = rsEmp.getInt("total_reviews");
                        String eName = rsEmp.getString("efirstname") + " " + rsEmp.getString("elastname");
                %>
                <tr data-name="<%= eName.toLowerCase().replace("\"","") %>" data-rating="<%= eAvg %>" data-idx="<%= empRow %>">
                    <td style="color:#9ca3af;font-size:12px;"><%= empRow %></td>
                    <td style="font-weight:500;"><%= eName %></td>
                    <td><%= rsEmp.getString("ecompanyname") %></td>
                    <td style="font-size:12px;color:#6b7280;"><%= rsEmp.getString("eemail") %></td>
                    <td style="font-size:13px;"><%= rsEmp.getString("ephone")!=null?rsEmp.getString("ephone"):"—" %></td>
                    <td><%= rsEmp.getString("edistrict")!=null?rsEmp.getString("edistrict"):"—" %></td>
                    <td><%= rsEmp.getString("estate")!=null?rsEmp.getString("estate"):"—" %></td>
                    <td>
                        <% if (eTot > 0) { %>
                            <span class="tbl-rating">
                                <span class="stars">★</span> <%= eAvg %>/5
                                <span style="color:#b45309;font-weight:400;">(<%= eTot %>)</span>
                            </span>
                        <% } else { %>
                            <span class="tbl-no-rating">No reviews</span>
                        <% } %>
                    </td>
                    <td style="white-space:nowrap;">
                        <a href="ad_view_employer_profile.jsp?eid=<%= rsEmp.getInt("eid") %>" class="btn-view-profile">
                            <i class="fa-solid fa-eye" style="margin-right:3px;"></i>View
                        </a>
                        <a href="AdminDeleteServlet?type=employer&id=<%= rsEmp.getInt("eid") %>"
                           onclick="return confirm('Delete employer and ALL their jobs/applications? This cannot be undone.');"
                           style="background:#fef2f2;color:#991b1b;padding:5px 12px;
                                  border-radius:6px;text-decoration:none;font-size:12px;
                                  font-weight:600;border:1px solid #fca5a5;">Delete</a>
                    </td>
                </tr>
                <%
                    }
                    if (empRow == 0) { %>
                <tr><td colspan="9" style="text-align:center;color:#999;padding:30px;">No employers registered yet.</td></tr>
                <% }
                    rsEmp.close(); psEmp.close();
                } catch (Exception e) { e.printStackTrace(); }
                finally { if (conEmp!=null) try{conEmp.close();}catch(Exception ig){} }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ═══ JOB SEEKERS ═══ -->
    <div id="jobseekersSection" style="display:none;">
        <div class="manage-header">
            <div><h2>All Job Seekers</h2><p>Manage registered job seekers on SkillMitra</p></div>
        </div>

        <div class="sort-bar">
            <input type="text" id="jsSearch" placeholder="🔍 Search by name or email..."
                   onkeyup="filterTable('jsTableBody',this.value)"
                   style="flex:1;min-width:200px;padding:8px 14px;border:1px solid #e0e0e0;
                          border-radius:8px;font-size:14px;outline:none;
                          box-shadow:0 1px 4px rgba(0,0,0,0.06);">
            <label for="jsSort">Sort by:</label>
            <select id="jsSort" class="sort-select" onchange="sortTable('jsTableBody',this.value)">
                <option value="default">Default</option>
                <option value="rating-desc">⭐ Rating (High → Low)</option>
                <option value="az">🔤 A → Z</option>
                <option value="za">🔤 Z → A</option>
            </select>
            <button onclick="exportJsPDF()"  class="exp-btn-pdf">&#128196; PDF</button>
<button onclick="exportJsExcel()" class="exp-btn-xl">&#128202; Excel</button>
        </div>

        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.05);">
            <table style="margin:0;">
                <thead>
                    <tr style="background:#f8fafc;">
                        <th>S.No.</th><th>Name</th><th>Email</th><th>Phone</th>
                        <th>District</th><th>Education</th><th>State</th>
                        <th>Rating ⭐</th><th>Action</th>
                    </tr>
                </thead>
                <tbody id="jsTableBody">
                <%
                Connection conJs = null;
                try {
                    conJs = DBConnection.getConnection();
                    PreparedStatement psJs = conJs.prepareStatement(
                        "SELECT j.jid, j.jfirstname, j.jlastname, j.jemail, j.jphone, " +
                        "       j.jdistrict, j.jeducation, j.jstate, " +
                        "       ROUND(COALESCE(AVG(r.rating_value),0),1) AS avg_rating, " +
                        "       COUNT(r.rating_id) AS total_reviews " +
                        "FROM jobseeker j " +
                        "LEFT JOIN ratings r ON r.jobseeker_id=j.jid AND r.rating_by='Employer' " +
                        "GROUP BY j.jid ORDER BY j.jid DESC"
                    );
                    ResultSet rsJs = psJs.executeQuery();
                    int jsRow = 0;
                    while (rsJs.next()) {
                        jsRow++;
                        double jsAvg = rsJs.getDouble("avg_rating");
                        int    jsTot = rsJs.getInt("total_reviews");
                        String jsName = rsJs.getString("jfirstname") + " " + rsJs.getString("jlastname");
                %>
                <tr data-name="<%= jsName.toLowerCase().replace("\"","") %>" data-rating="<%= jsAvg %>" data-idx="<%= jsRow %>">
                    <td style="color:#9ca3af;font-size:12px;"><%= jsRow %></td>
                    <td style="font-weight:500;"><%= jsName %></td>
                    <td style="font-size:12px;color:#6b7280;"><%= rsJs.getString("jemail") %></td>
                    <td style="font-size:13px;"><%= rsJs.getString("jphone")!=null?rsJs.getString("jphone"):"—" %></td>
                    <td><%= rsJs.getString("jdistrict")!=null?rsJs.getString("jdistrict"):"—" %></td>
                    <td><%= rsJs.getString("jeducation")!=null?rsJs.getString("jeducation"):"—" %></td>
                    <td><%= rsJs.getString("jstate")!=null?rsJs.getString("jstate"):"—" %></td>
                    <td>
                        <% if (jsTot > 0) { %>
                            <span class="tbl-rating">
                                <span class="stars">★</span> <%= jsAvg %>/5
                                <span style="color:#b45309;font-weight:400;">(<%= jsTot %>)</span>
                            </span>
                        <% } else { %>
                            <span class="tbl-no-rating">No reviews</span>
                        <% } %>
                    </td>
                    <td style="white-space:nowrap;">
                        <a href="ad_view_jobseeker_profile.jsp?jid=<%= rsJs.getInt("jid") %>" class="btn-view-profile">
                            <i class="fa-solid fa-eye" style="margin-right:3px;"></i>View
                        </a>
                        <a href="AdminDeleteServlet?type=jobseeker&id=<%= rsJs.getInt("jid") %>"
                           onclick="return confirm('Delete job seeker and ALL their data? This cannot be undone.');"
                           style="background:#fef2f2;color:#991b1b;padding:5px 12px;
                                  border-radius:6px;text-decoration:none;font-size:12px;
                                  font-weight:600;border:1px solid #fca5a5;">Delete</a>
                    </td>
                </tr>
                <%
                    }
                    if (jsRow == 0) { %>
                <tr><td colspan="9" style="text-align:center;color:#999;padding:30px;">No job seekers registered yet.</td></tr>
                <% }
                    rsJs.close(); psJs.close();
                } catch (Exception e) { e.printStackTrace(); }
                finally { if (conJs!=null) try{conJs.close();}catch(Exception ig){} }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ═══ ALL JOBS ═══ -->
    <div id="jobsSection" style="display:none;">
        <div class="manage-header">
            <div><h2>All Job Posts</h2><p>View and remove any job posted on SkillMitra</p></div>
        </div>

        <div class="sort-bar">
            <input type="text" id="jobSearch" placeholder="🔍 Search by job title or city..."
                   onkeyup="filterTable('jobTableBody',this.value)"
                   style="flex:1;min-width:200px;padding:8px 14px;border:1px solid #e0e0e0;
                          border-radius:8px;font-size:14px;outline:none;
                          box-shadow:0 1px 4px rgba(0,0,0,0.06);">
            <label for="jobSort">Sort by:</label>
            <select id="jobSort" class="sort-select" onchange="sortTable('jobTableBody',this.value)">
                <option value="default">Default (Newest)</option>
                <option value="az">🔤 Title A → Z</option>
                <option value="za">🔤 Title Z → A</option>
                <option value="date-desc">📅 Posted: Newest First</option>
                <option value="date-asc">📅 Posted: Oldest First</option>
            </select>
            <button onclick="exportJobPDF()"  class="exp-btn-pdf">&#128196; PDF</button>
<button onclick="exportJobExcel()" class="exp-btn-xl">&#128202; Excel</button>
        </div>

        <div style="background:#fff;border-radius:12px;border:1px solid #e8edf2;
                    overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.05);">
            <table style="margin:0;">
                <thead>
                    <tr style="background:#f8fafc;">
                        <th>S.No.</th><th>Title</th><th>Employer</th><th>Location</th>
                        <th>Salary</th><th>Type</th><th>Status</th><th>Posted</th><th>Action</th>
                    </tr>
                </thead>
                <tbody id="jobTableBody">
                <%
                Connection conAllJobs = null;
                try {
                    conAllJobs = DBConnection.getConnection();
                    PreparedStatement psAllJobs = conAllJobs.prepareStatement(
                        "SELECT j.job_id, j.title, j.city, j.salary, j.job_type, j.status, j.created_at, " +
                        "CONCAT(e.efirstname,' ',e.elastname) AS emp_name " +
                        "FROM jobs j JOIN employer e ON j.eid=e.eid ORDER BY j.job_id DESC"
                    );
                    ResultSet rsAllJobs = psAllJobs.executeQuery();
                    int jobRow = 0;
                    while (rsAllJobs.next()) {
                        jobRow++;
                        String jobStatus = rsAllJobs.getString("status");
                        String statusStyle = "Active".equalsIgnoreCase(jobStatus)
                            ? "background:#dcfce7;color:#166534;" : "background:#fee2e2;color:#991b1b;";
                        java.sql.Timestamp createdAt = rsAllJobs.getTimestamp("created_at");
                        String dateStr = createdAt != null
                            ? new java.text.SimpleDateFormat("dd MMM yyyy").format(createdAt) : "—";
                        long dateMs = createdAt != null ? createdAt.getTime() : 0L;
                        String titleLow = rsAllJobs.getString("title") != null
                            ? rsAllJobs.getString("title").toLowerCase().replace("\"","") : "";
                %>
                <tr data-name="<%= titleLow %>" data-date="<%= dateMs %>" data-idx="<%= jobRow %>">
                    <td style="color:#9ca3af;font-size:12px;"><%= jobRow %></td>
                    <td style="font-weight:500;"><%= rsAllJobs.getString("title") %></td>
                    <td style="font-size:13px;"><%= rsAllJobs.getString("emp_name") %></td>
                    <td style="font-size:13px;"><%= rsAllJobs.getString("city") %></td>
                    <td style="font-weight:600;color:#166534;">&#8377;<%= rsAllJobs.getString("salary") %></td>
                    <td style="font-size:12px;"><%= rsAllJobs.getString("job_type")!=null?rsAllJobs.getString("job_type"):"—" %></td>
                    <td>
                        <span style="padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;<%= statusStyle %>">
                            <%= jobStatus %>
                        </span>
                    </td>
                    <td style="font-size:12px;color:#9ca3af;"><%= dateStr %></td>
                    <td>
                        <a href="AdminDeleteServlet?type=job&id=<%= rsAllJobs.getInt("job_id") %>"
                           onclick="return confirm('Delete this job post? All related applications will also be removed.');"
                           style="background:#fef2f2;color:#991b1b;padding:5px 14px;
                                  border-radius:6px;text-decoration:none;font-size:12px;
                                  font-weight:600;border:1px solid #fca5a5;">Delete</a>
                    </td>
                </tr>
                <%
                    }
                    if (jobRow == 0) { %>
                <tr><td colspan="9" style="text-align:center;color:#999;padding:30px;">No jobs posted yet.</td></tr>
                <% }
                    rsAllJobs.close(); psAllJobs.close();
                } catch (Exception e) { e.printStackTrace(); }
                finally { if (conAllJobs!=null) try{conAllJobs.close();}catch(Exception ig){} }
                %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- end .content -->

<script>
// ── Auto-open section from ?section= param ──
(function() {
    const param = new URLSearchParams(window.location.search).get('section');
    if (param) {
        const links = document.querySelectorAll('.sidebar a');
        const idx = { dashboard:0, employers:1, jobseekers:2, jobs:3 };
        if (idx[param] !== undefined) showSection(param, links[idx[param]]);
    }
})();

// ── Section switching ──
function showSection(section, el) {
    ['dashboard','employers','jobseekers','jobs'].forEach(function(s) {
        var e = document.getElementById(s + 'Section');
        if (e) e.style.display = 'none';
    });
    document.getElementById(section + 'Section').style.display = 'block';
    document.querySelectorAll('.sidebar a').forEach(function(a) { a.classList.remove('active'); });
    if (el) el.classList.add('active');
}

// ── Live search filter ──
function filterTable(tbodyId, query) {
    var q = query.toLowerCase();
    document.getElementById(tbodyId).querySelectorAll('tr').forEach(function(row) {
        row.style.display = row.innerText.toLowerCase().includes(q) ? '' : 'none';
    });
}

// ── Sort table ──
function sortTable(tbodyId, mode) {
    var tbody = document.getElementById(tbodyId);
    var rows  = Array.from(tbody.querySelectorAll('tr'));

    rows.sort(function(a, b) {
        switch (mode) {
            case 'az':
                return (a.dataset.name || '').localeCompare(b.dataset.name || '');
            case 'za':
                return (b.dataset.name || '').localeCompare(a.dataset.name || '');
            case 'rating-desc':
                return parseFloat(b.dataset.rating || 0) - parseFloat(a.dataset.rating || 0);
            case 'date-desc':
                return parseInt(b.dataset.date || 0) - parseInt(a.dataset.date || 0);
            case 'date-asc':
                return parseInt(a.dataset.date || 0) - parseInt(b.dataset.date || 0);
            default: // restore original order
                return parseInt(a.dataset.idx || 0) - parseInt(b.dataset.idx || 0);
        }
    });

    rows.forEach(function(row, i) {
        var firstTd = row.querySelector('td');
        if (firstTd && firstTd.textContent.trim().match(/^\d+$/)) {
            firstTd.textContent = i + 1;
        }
        tbody.appendChild(row);
    });
}

// ── Hamburger ──
document.getElementById('hamburger').addEventListener('click', function() {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('collapsed');
    document.querySelector('header').classList.toggle('collapsed');
});
// ── Chart.js CDN ──
(function(){
  var s = document.createElement('script');
  s.src = 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js';
  s.onload = initCharts;
  document.head.appendChild(s);
})();

function initCharts() {
    var empData   = <%=empMonthlyJson%>;
    var jsData    = <%=jsMonthlyJson%>;
    var appData   = <%=appMonthlyJson%>;
    var jobStatus = <%=jobStatusJson%>;
    var jobTypes  = <%=jobTypeJson%>;

    // ── Build a unified month label list preserving calendar order ──
    var monthOrder = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var monthSet = {};
    empData.forEach(function(d){ monthSet[d.m] = true; });
    jsData.forEach(function(d){  monthSet[d.m] = true; });
    // Sort by calendar order
    var allMonths = monthOrder.filter(function(m){ return monthSet[m]; });

    // Map data to aligned arrays so bars line up correctly
    var empMap = {}, jsMap = {};
    empData.forEach(function(d){ empMap[d.m] = d.c; });
    jsData.forEach(function(d){  jsMap[d.m]  = d.c; });

    var empCounts = allMonths.map(function(m){ return empMap[m] || 0; });
    var jsCounts  = allMonths.map(function(m){ return jsMap[m]  || 0; });

    var appLabels = appData.map(function(d){ return d.m; });
    var appCounts = appData.map(function(d){ return d.c; });

    // ── Chart 1 – Monthly Registrations (grouped bar) ──
    new Chart(document.getElementById('chartRegistrations'), {
        type: 'bar',
        data: {
            labels: allMonths.length ? allMonths : ['No data'],
            datasets: [
                {
                    label: 'Employers',
                    data: empCounts,
                    backgroundColor: '#3b82f6',
                    borderRadius: 4,
                    barPercentage: 0.55,
                    categoryPercentage: 0.7
                },
                {
                    label: 'Job Seekers',
                    data: jsCounts,
                    backgroundColor: '#16a34a',
                    borderRadius: 4,
                    barPercentage: 0.55,
                    categoryPercentage: 0.7
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: {
                    ticks: { font: { size: 10 } },
                    grid: { display: false }
                },
                y: {
                    ticks: {
                        font: { size: 10 },
                        stepSize: 1,
                        // Always show whole numbers only
                        callback: function(val) {
                            return Number.isInteger(val) ? val : null;
                        }
                    },
                    beginAtZero: true,
                    // Make sure max is at least 2 so single-value data doesn't show 0-1
                    suggestedMax: Math.max(2, Math.max.apply(null, empCounts.concat(jsCounts)) + 1)
                }
            }
        }
    });

    // ── Chart 2 – Job Status Donut ──
    new Chart(document.getElementById('chartJobStatus'), {
        type: 'doughnut',
        data: {
            labels: ['Active', 'Inactive'],
            datasets: [{
                data: jobStatus,
                backgroundColor: ['#16a34a', '#ef4444'],
                borderWidth: 0,
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '62%',
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            return ' ' + ctx.label + ': ' + ctx.parsed;
                        }
                    }
                }
            }
        }
    });

    // ── Chart 3 – Applications Over Time (line) ──
    new Chart(document.getElementById('chartApplications'), {
        type: 'line',
        data: {
            labels: appLabels.length ? appLabels : ['No data'],
            datasets: [{
                label: 'Applications',
                data: appCounts.length ? appCounts : [0],
                borderColor: '#7c3aed',
                backgroundColor: 'rgba(124,58,237,0.08)',
                fill: true,
                tension: 0.4,
                pointRadius: 4,
                pointBackgroundColor: '#7c3aed'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: {
                    ticks: { font: { size: 10 } },
                    grid: { display: false }
                },
                y: {
                    ticks: {
                        font: { size: 10 },
                        stepSize: 1,
                        callback: function(val) {
                            return Number.isInteger(val) ? val : null;
                        }
                    },
                    beginAtZero: true,
                    suggestedMax: Math.max(2, Math.max.apply(null, appCounts.concat([0])) + 1)
                }
            }
        }
    });

    // ── Chart 4 – Job Type Pie (your actual 4 types) ──
    var jtLabels = Object.keys(jobTypes);
    var jtData   = Object.values(jobTypes);

    // Fixed color map matching your actual job types
    var typeColorMap = {
        'Full-Time': '#3b82f6',
        'Part-Time': '#f59e0b',
        'Daily':     '#16a34a',
        'Contract':  '#8b5cf6'
    };
    var jtColors = jtLabels.map(function(l) {
        return typeColorMap[l] || '#9ca3af';
    });

    new Chart(document.getElementById('chartJobTypes'), {
        type: 'pie',
        data: {
            labels: jtLabels.length ? jtLabels : ['No data'],
            datasets: [{
                data: jtData.length ? jtData : [1],
                backgroundColor: jtColors,
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        font: { size: 11 },
                        boxWidth: 12,
                        padding: 16
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            var total = ctx.dataset.data.reduce(function(a,b){ return a+b; }, 0);
                            var pct = total > 0 ? Math.round(ctx.parsed / total * 100) : 0;
                            return ' ' + ctx.label + ': ' + ctx.parsed + ' (' + pct + '%)';
                        }
                    }
                }
            }
        }
    });
}

// ── PDF export ──
function exportTablePDF(tbodyId, title, headers) {
    var { jsPDF } = window.jspdf;
    var doc = new jsPDF();
    
    doc.setFontSize(15);
    doc.text(title.replace(/_/g,' '), 14, 18);
    doc.setFontSize(9);
    doc.setTextColor(120);
    doc.text('SkillMitra Admin Report — ' + new Date().toLocaleDateString(), 14, 25);
    doc.setTextColor(0);

    var rows = [];
    document.getElementById(tbodyId).querySelectorAll('tr').forEach(function(tr) {
        if (tr.style.display === 'none') return;
        var cells = tr.querySelectorAll('td');
        if (!cells.length) return;
        var row = [];
        headers.forEach(function(h) {
            row.push(h.colIndex !== undefined ? cleanCell(cells[h.colIndex]) : '');
        });
        rows.push(row);
    });

    doc.autoTable({
        head: [headers.map(function(h){ return h.label; })],
        body: rows,
        startY: 30,
        styles: { fontSize: 8, cellPadding: 3 },
        headStyles: { fillColor: [59, 91, 219], textColor: 255, fontStyle: 'bold' },
        alternateRowStyles: { fillColor: [245, 247, 255] }
    });

    doc.save(title + '.pdf');
}

function cleanCell(td) {
    if (!td) return '—';
    var ratingSpan = td.querySelector('.tbl-rating');
    if (ratingSpan) {
        var clone = ratingSpan.cloneNode(true);
        var star = clone.querySelector('.stars');
        if (star) star.remove();
        return clone.innerText.trim();
    }
    var noRating = td.querySelector('.tbl-no-rating');
    if (noRating) return 'No reviews';
    if (td.querySelector('a')) return '';
    return td.innerText.trim();
}

// Employers PDF
function exportEmpPDF() {
    exportTablePDF('empTableBody', 'Employers_Report', [
        {label:'S.No.',        colIndex:0},
        {label:'Name',     colIndex:1},
        {label:'Company',  colIndex:2},
        {label:'Email',    colIndex:3},
        {label:'Phone',    colIndex:4},
        {label:'District', colIndex:5},
        {label:'State',    colIndex:6},
        {label:'Rating',   colIndex:7}
    ]);
}

// Job Seekers PDF
function exportJsPDF() {
    exportTablePDF('jsTableBody', 'JobSeekers_Report', [
        {label:'S.No.',         colIndex:0},
        {label:'Name',      colIndex:1},
        {label:'Email',     colIndex:2},
        {label:'Phone',     colIndex:3},
        {label:'District',  colIndex:4},
        {label:'Education', colIndex:5},
        {label:'State',     colIndex:6},
        {label:'Rating',    colIndex:7}
    ]);
}

// Jobs PDF
function exportJobPDF() {
    exportTablePDF('jobTableBody', 'Jobs_Report', [
        {label:'S.No.',        colIndex:0},
        {label:'Title',    colIndex:1},
        {label:'Employer', colIndex:2},
        {label:'Location', colIndex:3},
        {label:'Salary',   colIndex:4},
        {label:'Type',     colIndex:5},
        {label:'Status',   colIndex:6},
        {label:'Posted',   colIndex:7}
    ]);
}

// Full dashboard PDF
function exportFullPDF() {
    var { jsPDF } = window.jspdf;
    var doc = new jsPDF();

    doc.setFontSize(16);
    doc.text('SkillMitra — Full Platform Report', 14, 18);
    doc.setFontSize(9);
    doc.setTextColor(120);
    doc.text('Generated: ' + new Date().toLocaleString(), 14, 26);
    doc.setTextColor(0);

    doc.setFontSize(12);
    doc.text('Platform Summary', 14, 38);

    doc.autoTable({
        head: [['Metric', 'Count']],
        body: [
            ['Total Employers',    '<%=totalEmployers%>'],
            ['Total Job Seekers',  '<%=totalJobseekers%>'],
            ['Active Jobs',        '<%=totalJobs%>'],
            ['Total Applications', '<%=totalApplications%>']
        ],
        startY: 42,
        styles: { fontSize: 10, cellPadding: 4 },
        headStyles: { fillColor: [59, 91, 219], textColor: 255, fontStyle: 'bold' },
        alternateRowStyles: { fillColor: [245, 247, 255] }
    });

    doc.save('SkillMitra_Full_Report.pdf');
}

// ── Excel export per table ──
function exportTableExcel(tbodyId, sheetName) {
    var rows = [];
    var thead = document.getElementById(tbodyId).closest('table').querySelector('thead tr');
    var headers = [];
    thead.querySelectorAll('th').forEach(function(th, i) {
        // skip last column (Action)
        var txt = th.innerText.trim();
        if (txt.toLowerCase() !== 'action') headers.push({label: txt, colIndex: i});
    });
    rows.push(headers.map(function(h){ return h.label; }));

    document.getElementById(tbodyId).querySelectorAll('tr').forEach(function(tr) {
        if (tr.style.display === 'none') return;
        var cells = tr.querySelectorAll('td');
        if (!cells.length) return;
        var row = [];
        headers.forEach(function(h) {
            row.push(cleanCell(cells[h.colIndex]));
        });
        rows.push(row);
    });

    var wb = XLSX.utils.book_new();
    var ws = XLSX.utils.aoa_to_sheet(rows);

    // Auto column width
    var colWidths = rows[0].map(function(_, ci) {
        return { wch: Math.max.apply(null, rows.map(function(r){ return r[ci] ? r[ci].toString().length : 10; })) + 2 };
    });
    ws['!cols'] = colWidths;

    XLSX.utils.book_append_sheet(wb, ws, sheetName);
    XLSX.writeFile(wb, sheetName + '.xlsx');
}

function exportEmpExcel()  { exportTableExcel('empTableBody',  'Employers');   }
function exportJsExcel()   { exportTableExcel('jsTableBody',   'JobSeekers');  }
function exportJobExcel()  { exportTableExcel('jobTableBody',  'Jobs');        }

function exportDashboardExcel() {
    var wb = XLSX.utils.book_new();
    var summary = [
        ['Metric',              'Count'],
        ['Total Employers',     '<%=totalEmployers%>'],
        ['Total Job Seekers',   '<%=totalJobseekers%>'],
        ['Active Jobs',         '<%=totalJobs%>'],
        ['Total Applications',  '<%=totalApplications%>']
    ];
    var ws = XLSX.utils.aoa_to_sheet(summary);
    ws['!cols'] = [{wch:22},{wch:10}];
    XLSX.utils.book_append_sheet(wb, ws, 'Summary');
    XLSX.writeFile(wb, 'SkillMitra_Dashboard.xlsx');
}
</script>
</body>
</html>
