<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* ── Only logged-in jobseeker can view this page ── */
HttpSession jsSession = request.getSession(false);
if (jsSession == null || jsSession.getAttribute("jobseekerId") == null) {
    response.sendRedirect("jobseeker_login.jsp");
    return;
}
Object obj = jsSession.getAttribute("jobseekerId");
int jobseekerId = (obj != null) ? (Integer) obj : 0;
String jsName = (String) jsSession.getAttribute("jobseekerName");

String eidParam = request.getParameter("eid");
if (eidParam == null) {
    response.sendRedirect("jobseeker_dash.jsp");
    return;
}
int eid = Integer.parseInt(eidParam);

/* ── Employer fields ── */
String fname = "", lname = "", company = "", email = "", phone = "";
String district = "", area = "", state = "", country = "";
String photo = "", website = "", bio = "";

/* ── Rating fields (given BY Jobseekers TO this employer) ── */
double avgRating = 0;
int    totalRatings = 0;
double avgEmpBehavior = 0, avgTimelyPay = 0, avgWorkEnv = 0, avgFairness = 0;

/* ── Job stats ── */
int totalJobs = 0, activeJobs = 0, totalApplications = 0;

Connection con = null;
try {
    con = DBConnection.getConnection();

    /* Employer basic info */
    PreparedStatement ps = con.prepareStatement("SELECT * FROM employer WHERE eid=?");
    ps.setInt(1, eid);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        fname    = rs.getString("efirstname");
        lname    = rs.getString("elastname");
        company  = rs.getString("ecompanyname");
        email    = rs.getString("eemail");
        phone    = rs.getString("ephone");
        district = rs.getString("edistrict");
        state    = rs.getString("estate");
        photo    = rs.getString("ephoto");
        try { area    = rs.getString("earea");    } catch (Exception ignored) {}
        try { country = rs.getString("ecountry"); } catch (Exception ignored) {}
        try { website = rs.getString("ecompanywebsite"); } catch (Exception ignored) {}
    }
    rs.close(); ps.close();

    /* Average overall rating + sub-ratings */
    PreparedStatement psR = con.prepareStatement(
        "SELECT " +
        "  ROUND(AVG(rating_value),1)           AS avg_r, " +
        "  COUNT(*)                              AS total, " +
        "  ROUND(AVG(employer_behavior),1)       AS avg_eb, " +
        "  ROUND(AVG(timely_payment),1)          AS avg_tp, " +
        "  ROUND(AVG(work_environment),1)        AS avg_we, " +
        "  ROUND(AVG(fairness_communication),1)  AS avg_fc " +
        "FROM ratings WHERE employer_id=? AND rating_by='Jobseeker'"
    );
    psR.setInt(1, eid);
    ResultSet rsR = psR.executeQuery();
    if (rsR.next() && rsR.getInt("total") > 0) {
        avgRating        = rsR.getDouble("avg_r");
        totalRatings     = rsR.getInt("total");
        avgEmpBehavior   = rsR.getDouble("avg_eb");
        avgTimelyPay     = rsR.getDouble("avg_tp");
        avgWorkEnv       = rsR.getDouble("avg_we");
        avgFairness      = rsR.getDouble("avg_fc");
    }
    rsR.close(); psR.close();

    /* Job stats */
    PreparedStatement psJ = con.prepareStatement(
        "SELECT COUNT(*) AS total_jobs, " +
        "SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END) AS active_jobs " +
        "FROM jobs WHERE eid=?"
    );
    psJ.setInt(1, eid);
    ResultSet rsJ = psJ.executeQuery();
    if (rsJ.next()) {
        totalJobs  = rsJ.getInt("total_jobs");
        activeJobs = rsJ.getInt("active_jobs");
    }
    rsJ.close(); psJ.close();

    /* Total applications */
    PreparedStatement psA = con.prepareStatement(
        "SELECT COUNT(*) FROM applications a JOIN jobs j ON a.job_id = j.job_id WHERE j.eid=?"
    );
    psA.setInt(1, eid);
    ResultSet rsA = psA.executeQuery();
    if (rsA.next()) totalApplications = rsA.getInt(1);
    rsA.close(); psA.close();

} catch (Exception e) { e.printStackTrace(); }
finally { if (con != null) try { con.close(); } catch (Exception ignored) {} }

String imgPath  = (photo != null && !photo.trim().isEmpty()) ? "uploads/" + photo : "";
String initials = (fname.isEmpty() ? "?" : String.valueOf(fname.charAt(0)))
                + (lname.isEmpty() ? ""  : String.valueOf(lname.charAt(0)));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= fname %> <%= lname %> | Employer Profile — SkillMitra</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=DM+Serif+Display&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
    --primary: #3b5bdb;
    --primary-light: #dbe4ff;
    --accent: #7c3aed;
    --gold: #f59e0b;
    --gold-light: #fffbeb;
    --success: #16a34a;
    --success-light: #dcfce7;
    --text-dark: #1a2a3a;
    --text-mid: #4b5563;
    --text-soft: #9ca3af;
    --border: #e8ecf0;
    --bg: #f4f6f9;
    --white: #ffffff;
    --shadow-sm: 0 1px 4px rgba(0,0,0,0.06);
    --shadow-md: 0 4px 16px rgba(0,0,0,0.08);
    --shadow-lg: 0 8px 32px rgba(0,0,0,0.12);
    --radius: 16px;
    --radius-sm: 10px;
}

body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background: var(--bg);
    color: var(--text-dark);
    min-height: 100vh;
}

/* ── HEADER ── */
.site-header {
    position: fixed; top: 0; left: 0; right: 0; z-index: 999;
    height: 62px;
    background: linear-gradient(135deg, #1e3a5f, #2d4f80);
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 28px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.18);
}
.header-brand {
    display: flex; align-items: center; gap: 10px;
    text-decoration: none;
}
.header-brand img {
    width: 36px; height: 36px; border-radius: 50%; object-fit: cover;
}
.header-brand span {
    color: #fff; font-size: 19px; font-weight: 800; letter-spacing: -0.02em;
}
.header-actions { display: flex; align-items: center; gap: 10px; }
.btn-back-header {
    display: inline-flex; align-items: center; gap: 7px;
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.22);
    color: #fff; padding: 7px 16px; border-radius: 8px;
    font-size: 13px; font-weight: 600; text-decoration: none;
    transition: background 0.2s;
}
.btn-back-header:hover { background: rgba(255,255,255,0.22); }
.header-user {
    font-size: 13px; color: rgba(255,255,255,0.75);
    display: flex; align-items: center; gap: 6px;
}

/* ── HERO BAND ── */
.hero-band {
    background: linear-gradient(135deg, #1e3a5f 0%, #3b5bdb 50%, #7c3aed 100%);
    padding: 110px 24px 60px;
    text-align: center;
    position: relative;
    overflow: hidden;
}
.hero-band::before {
    content: '';
    position: absolute; inset: 0;
    background: radial-gradient(ellipse at 60% 0%, rgba(255,255,255,0.08) 0%, transparent 70%);
}
.hero-avatar-wrap {
    position: relative; display: inline-block; margin-bottom: 16px;
}
.hero-avatar {
    width: 96px; height: 96px; border-radius: 50%; object-fit: cover;
    border: 4px solid rgba(255,255,255,0.4);
    box-shadow: 0 8px 24px rgba(0,0,0,0.3);
}
.hero-initials {
    width: 96px; height: 96px; border-radius: 50%;
    background: rgba(255,255,255,0.18);
    border: 4px solid rgba(255,255,255,0.4);
    display: flex; align-items: center; justify-content: center;
    font-size: 34px; font-weight: 800; color: #fff;
    box-shadow: 0 8px 24px rgba(0,0,0,0.3);
}
.verified-badge {
    position: absolute; bottom: 2px; right: 2px;
    width: 26px; height: 26px; border-radius: 50%;
    background: #16a34a; border: 2px solid #fff;
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; color: #fff;
}
.hero-name {
    font-family: 'DM Serif Display', serif;
    font-size: 30px; color: #fff; margin-bottom: 4px;
    text-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.hero-company {
    font-size: 15px; color: rgba(255,255,255,0.8);
    font-weight: 500; margin-bottom: 16px;
    display: flex; align-items: center; gap: 6px; justify-content: center;
}
.hero-rating-pill {
    display: inline-flex; align-items: center; gap: 10px;
    background: rgba(255,255,255,0.14);
    border: 1px solid rgba(255,255,255,0.28);
    border-radius: 30px; padding: 8px 20px;
    backdrop-filter: blur(8px);
}
.hero-stars { color: var(--gold); font-size: 16px; letter-spacing: 1px; }
.hero-rating-val { font-size: 15px; font-weight: 700; color: #fff; }
.hero-rating-count { font-size: 13px; color: rgba(255,255,255,0.65); }

/* ── PAGE WRAPPER ── */
.page-wrapper {
    max-width: 800px;
    margin: 0 auto;
    padding: 28px 16px 60px;
}

/* ── STATS STRIP ── */
.stats-strip {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
    margin-bottom: 24px;
    margin-top: -36px;
    position: relative; z-index: 10;
}
.stat-card {
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 18px 14px;
    text-align: center;
    box-shadow: var(--shadow-md);
}
.stat-num {
    font-size: 26px; font-weight: 800;
    background: linear-gradient(135deg, var(--primary), var(--accent));
    -webkit-background-clip: text; -webkit-text-fill-color: transparent;
}
.stat-num.green { background: linear-gradient(135deg, #16a34a, #4ade80); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.stat-num.purple { background: linear-gradient(135deg, #7c3aed, #a78bfa); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.stat-lbl { font-size: 11px; color: var(--text-soft); margin-top: 3px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; }

/* ── CARD ── */
.card {
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 26px 28px;
    margin-bottom: 20px;
    box-shadow: var(--shadow-sm);
}
.card-title {
    font-size: 11px; font-weight: 700; color: var(--text-soft);
    text-transform: uppercase; letter-spacing: 0.07em;
    margin-bottom: 18px;
    display: flex; align-items: center; gap: 8px;
}
.card-title::after {
    content: ''; flex: 1; height: 1px; background: var(--border);
}

/* ── INFO GRID ── */
.info-grid {
    display: grid; grid-template-columns: 1fr 1fr; gap: 12px;
}
.info-item {
    background: #f9fafb; border: 1px solid var(--border);
    border-radius: var(--radius-sm); padding: 13px 15px;
}
.info-label { font-size: 11px; color: var(--text-soft); text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 5px; }
.info-value { font-size: 14px; color: var(--text-dark); font-weight: 600; }
.info-value a { color: var(--primary); text-decoration: none; }
.info-value a:hover { text-decoration: underline; }

/* ── CONTACT CHIPS ── */
.contact-chips { display: flex; flex-wrap: wrap; gap: 10px; }
.contact-chip {
    display: inline-flex; align-items: center; gap: 8px;
    background: var(--primary-light);
    color: var(--primary);
    padding: 8px 14px; border-radius: 30px;
    font-size: 13px; font-weight: 500;
}
.contact-chip i { font-size: 12px; }

/* ── RATING BREAKDOWN ── */
.rating-hero {
    display: flex; align-items: center; gap: 30px;
    margin-bottom: 24px;
}
.rating-big {
    text-align: center; flex-shrink: 0;
}
.rating-big-num {
    font-size: 52px; font-weight: 800; line-height: 1;
    color: var(--gold);
}
.rating-big-stars { font-size: 20px; color: var(--gold); margin: 4px 0; }
.rating-big-count { font-size: 12px; color: var(--text-soft); }

.rb-list { flex: 1; display: flex; flex-direction: column; gap: 11px; }
.rb-row { display: flex; align-items: center; gap: 12px; }
.rb-label { font-size: 12px; color: var(--text-mid); width: 175px; flex-shrink: 0; font-weight: 500; }
.rb-bar-wrap { flex: 1; background: #f3f4f6; border-radius: 20px; height: 9px; overflow: hidden; }
.rb-bar-fill {
    height: 100%; border-radius: 20px;
    background: linear-gradient(90deg, var(--gold), #f97316);
    transition: width 0.6s cubic-bezier(0.34,1.56,0.64,1);
}
.rb-val { font-size: 12px; font-weight: 700; color: #92400e; width: 28px; text-align: right; }

/* ── REVIEWS ── */
.review-card {
    background: #f9fafb; border: 1px solid var(--border);
    border-radius: var(--radius-sm); padding: 16px 18px;
    margin-bottom: 12px;
}
.review-card:last-child { margin-bottom: 0; }
.review-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
.reviewer-info { display: flex; align-items: center; gap: 10px; }
.reviewer-avatar {
    width: 32px; height: 32px; border-radius: 50%;
    background: var(--primary-light); color: var(--primary);
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; font-weight: 700;
}
.reviewer-name { font-size: 13px; font-weight: 600; color: var(--text-dark); }
.reviewer-date { font-size: 11px; color: var(--text-soft); }
.review-stars-sm { font-size: 13px; color: var(--gold); }
.review-text { font-size: 13px; color: var(--text-mid); line-height: 1.65; font-style: italic; }
.no-review-text { font-size: 13px; color: var(--text-soft); font-style: italic; }

/* ── JOB ROWS ── */
.job-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 13px 0; border-bottom: 1px solid #f3f4f6;
}
.job-row:last-child { border-bottom: none; }
.job-title { font-size: 14px; font-weight: 600; color: var(--text-dark); margin-bottom: 3px; }
.job-meta { font-size: 12px; color: var(--text-soft); }
.job-meta span { margin: 0 4px; }
.status-pill {
    padding: 3px 11px; border-radius: 20px; font-size: 11px; font-weight: 700;
}
.status-active { background: var(--success-light); color: var(--success); }
.status-inactive { background: #fee2e2; color: #991b1b; }

/* ── BIO BOX ── */
.bio-box {
    background: linear-gradient(135deg, #f0f4ff, #faf5ff);
    border: 1px solid #c7d2fe;
    border-radius: var(--radius-sm);
    padding: 16px 18px;
    font-size: 14px; color: var(--text-mid); line-height: 1.75;
}

/* ── EMPTY STATE ── */
.empty-state { text-align: center; padding: 24px; color: var(--text-soft); font-size: 13px; }

/* ── MOBILE ── */
@media (max-width: 600px) {
    .stats-strip { grid-template-columns: repeat(3,1fr); gap: 8px; }
    .stat-card { padding: 12px 8px; }
    .stat-num { font-size: 20px; }
    .info-grid { grid-template-columns: 1fr; }
    .rating-hero { flex-direction: column; gap: 20px; }
    .rb-label { width: 130px; }
    .card { padding: 20px 16px; }
}
</style>
</head>
<body>

<!-- ═══ HEADER ═══ -->
<header class="site-header">
    <a class="header-brand" href="jobseeker_dash.jsp">
        <img src="skillmitralogo.jpg" alt="SkillMitra">
        <span>SkillMitra</span>
    </a>
    <div class="header-actions">
        <span class="header-user">
            <i class="fa-solid fa-circle-user"></i> <%= jsName != null ? jsName : "Jobseeker" %>
        </span>
        <a href="javascript:history.back()" class="btn-back-header">
            <i class="fa-solid fa-arrow-left"></i> Back
        </a>
    </div>
</header>

<!-- ═══ HERO BAND ═══ -->
<div class="hero-band">
    <div class="hero-avatar-wrap">
        <% if (imgPath != null && !imgPath.isEmpty()) { %>
            <img src="<%= imgPath %>" class="hero-avatar" alt="<%= fname %>">
        <% } else { %>
            <div class="hero-initials"><%= initials %></div>
        <% } %>
        <div class="verified-badge"><i class="fa-solid fa-check"></i></div>
    </div>

    <div class="hero-name"><%= fname %> <%= lname %></div>

    <% if (company != null && !company.isEmpty()) { %>
    <div class="hero-company">
        <i class="fa-solid fa-building"></i> <%= company %>
    </div>
    <% } %>

    <% if (district != null && !district.isEmpty()) { %>
    <div style="font-size:13px; color:rgba(255,255,255,0.6); margin-bottom:16px;">
        <i class="fa-solid fa-location-dot" style="margin-right:5px;"></i><%= district %><%= state != null && !state.isEmpty() ? ", " + state : "" %>
    </div>
    <% } %>

    <div class="hero-rating-pill">
        <span class="hero-stars">
            <% for (int i = 1; i <= 5; i++) {
                if (i <= Math.floor(avgRating)) { %>★<% } else { %><span style="opacity:0.3;">★</span><% }
            } %>
        </span>
        <% if (totalRatings > 0) { %>
            <span class="hero-rating-val"><%= avgRating %>/5</span>
            <span class="hero-rating-count">(<%= totalRatings %> review<%= totalRatings != 1 ? "s" : "" %>)</span>
        <% } else { %>
            <span class="hero-rating-count">No reviews yet</span>
        <% } %>
    </div>
</div>

<!-- ═══ PAGE CONTENT ═══ -->
<div class="page-wrapper">

    <!-- Stats Strip -->


    <!-- ── CARD: Contact Info ── -->
    <div class="card">
        <div class="card-title"><i class="fa-solid fa-address-card"></i> Contact & Location</div>
        <div class="contact-chips" style="margin-bottom:16px;">
            <% if (email != null && !email.isEmpty()) { %>
            <span class="contact-chip">
                <i class="fa-solid fa-envelope"></i> <%= email %>
            </span>
            <% } %>
            <% if (phone != null && !phone.isEmpty()) { %>
            <span class="contact-chip">
                <i class="fa-solid fa-phone"></i> <%= phone %>
            </span>
            <% } %>
            <% if (website != null && !website.isEmpty()) { %>
            <span class="contact-chip" style="background:#f0fdf4; color:#15803d;">
                <i class="fa-solid fa-globe"></i>
                <a href="<%= website %>" target="_blank" style="color:inherit; text-decoration:none;"><%= website %></a>
            </span>
            <% } %>
        </div>

        <div class="info-grid">
            <% if (company != null && !company.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Company</div>
                <div class="info-value"><%= company %></div>
            </div>
            <% } %>
            <% if (district != null && !district.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">District</div>
                <div class="info-value"><%= district %></div>
            </div>
            <% } %>
            <% if (area != null && !area.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Area</div>
                <div class="info-value"><%= area %></div>
            </div>
            <% } %>
            <% if (state != null && !state.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">State</div>
                <div class="info-value"><%= state %></div>
            </div>
            <% } %>
            <% if (country != null && !country.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Country</div>
                <div class="info-value"><%= country %></div>
            </div>
            <% } %>
        </div>

        <% if (bio != null && !bio.isEmpty()) { %>
        <div style="margin-top:18px;">
            <div class="card-title" style="margin-bottom:10px;"><i class="fa-solid fa-quote-left"></i> About</div>
            <div class="bio-box"><%= bio %></div>
        </div>
        <% } %>
    </div>

    <!-- ── CARD: Rating Breakdown ── -->
    <% if (totalRatings > 0) { %>
    <div class="card">
        <div class="card-title"><i class="fa-solid fa-star"></i> Ratings & Reviews</div>

        <div class="rating-hero">
            <div class="rating-big">
                <div class="rating-big-num"><%= avgRating %></div>
                <div class="rating-big-stars">
                    <% for (int i = 1; i <= 5; i++) {
                        if (i <= Math.floor(avgRating)) { %>★<% } else { %><span style="opacity:0.3;">★</span><% }
                    } %>
                </div>
                <div class="rating-big-count"><%= totalRatings %> review<%= totalRatings != 1 ? "s" : "" %></div>
            </div>

            <div class="rb-list">
                <div class="rb-row">
                    <span class="rb-label">Employer Behaviour</span>
                    <div class="rb-bar-wrap">
                        <div class="rb-bar-fill" style="width:<%= (avgEmpBehavior/5.0*100) %>%;"></div>
                    </div>
                    <span class="rb-val"><%= avgEmpBehavior %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Timely Payment</span>
                    <div class="rb-bar-wrap">
                        <div class="rb-bar-fill" style="width:<%= (avgTimelyPay/5.0*100) %>%;"></div>
                    </div>
                    <span class="rb-val"><%= avgTimelyPay %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Work Environment</span>
                    <div class="rb-bar-wrap">
                        <div class="rb-bar-fill" style="width:<%= (avgWorkEnv/5.0*100) %>%;"></div>
                    </div>
                    <span class="rb-val"><%= avgWorkEnv %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Fairness & Communication</span>
                    <div class="rb-bar-wrap">
                        <div class="rb-bar-fill" style="width:<%= (avgFairness/5.0*100) %>%;"></div>
                    </div>
                    <span class="rb-val"><%= avgFairness %></span>
                </div>
            </div>
        </div>

        <!-- Recent Reviews -->
        <div style="border-top:1px solid var(--border); padding-top:20px;">
            <div class="card-title" style="margin-bottom:16px;"><i class="fa-solid fa-comments"></i> Recent Reviews</div>
            <%
            Connection conRev = null;
            try {
                conRev = DBConnection.getConnection();
                PreparedStatement psRev = conRev.prepareStatement(
                    "SELECT r.rating_value, r.review_text, r.created_at, " +
                    "       j.jfirstname, j.jlastname " +
                    "FROM ratings r " +
                    "LEFT JOIN jobseeker j ON r.jobseeker_id = j.jid " +
                    "WHERE r.employer_id = ? AND r.rating_by = 'Jobseeker' " +
                    "ORDER BY r.created_at DESC LIMIT 5"
                );
                psRev.setInt(1, eid);
                ResultSet rsRev = psRev.executeQuery();
                boolean anyRev = false;
                while (rsRev.next()) {
                    anyRev = true;
                    int rv = rsRev.getInt("rating_value");
                    String rText  = rsRev.getString("review_text");
                    String revDate = rsRev.getTimestamp("created_at") != null
                        ? new java.text.SimpleDateFormat("dd MMM yyyy").format(rsRev.getTimestamp("created_at")) : "";
                    String jsFname2 = rsRev.getString("jfirstname");
                    String jsLname2 = rsRev.getString("jlastname");
                    String revInit = (jsFname2 != null && !jsFname2.isEmpty() ? String.valueOf(jsFname2.charAt(0)) : "?")
                                   + (jsLname2 != null && !jsLname2.isEmpty() ? String.valueOf(jsLname2.charAt(0)) : "");
            %>
                <div class="review-card">
                    <div class="review-header">
                        <div class="reviewer-info">
                            <div class="reviewer-avatar"><%= revInit %></div>
                            <div>
                                <div class="reviewer-name"><%= jsFname2 != null ? jsFname2 : "Anonymous" %> <%= jsLname2 != null ? jsLname2 : "" %></div>
                                <div class="reviewer-date"><%= revDate %></div>
                            </div>
                        </div>
                        <div class="review-stars-sm">
                            <% for (int i = 1; i <= 5; i++) {
                                if (i <= rv) { %>★<% } else { %><span style="opacity:0.25;">★</span><% }
                            } %>
                            <span style="font-size:12px; font-weight:700; color:#92400e; margin-left:4px;"><%= rv %>/5</span>
                        </div>
                    </div>
                    <% if (rText != null && !rText.trim().isEmpty()) { %>
                        <div class="review-text">"<%= rText %>"</div>
                    <% } else { %>
                        <div class="no-review-text">No written review.</div>
                    <% } %>
                </div>
            <%
                }
                if (!anyRev) { %><div class="empty-state">No reviews yet.</div><% }
                rsRev.close(); psRev.close();
            } catch (Exception e) { e.printStackTrace(); }
            finally { if (conRev != null) try { conRev.close(); } catch (Exception ignored) {} }
            %>
        </div>
    </div>
    <% } %>

    <!-- ── CARD: Recent Jobs ── -->


</div><!-- end page-wrapper -->
</body>
</html>
