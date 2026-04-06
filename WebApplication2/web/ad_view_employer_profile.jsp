<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* ── Only admin can view this page ── */
HttpSession adminSession = request.getSession(false);
if (adminSession == null || adminSession.getAttribute("adminId") == null) {
    response.sendRedirect("admin_login.jsp");
    return;
}
String adminUsername = (String) adminSession.getAttribute("adminUsername");

String eidParam = request.getParameter("eid");
if (eidParam == null) {
    response.sendRedirect("admin_dash.jsp");
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
        /* optional columns — use getObject to avoid crash if column missing */
        try { area    = rs.getString("earea");    } catch (Exception ignored) {}
        try { country = rs.getString("ecountry"); } catch (Exception ignored) {}
        try { website = rs.getString("ewebsite"); } catch (Exception ignored) {}
        try { bio     = rs.getString("ebio");     } catch (Exception ignored) {}
    }
    rs.close(); ps.close();

    /* Average overall rating + sub-ratings (from Jobseekers) */
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
        "SELECT " +
        "  COUNT(*) AS total_jobs, " +
        "  SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END) AS active_jobs " +
        "FROM jobs WHERE eid=?"
    );
    psJ.setInt(1, eid);
    ResultSet rsJ = psJ.executeQuery();
    if (rsJ.next()) {
        totalJobs  = rsJ.getInt("total_jobs");
        activeJobs = rsJ.getInt("active_jobs");
    }
    rsJ.close(); psJ.close();

    /* Total applications across all employer jobs */
    PreparedStatement psA = con.prepareStatement(
        "SELECT COUNT(*) FROM applications a " +
        "JOIN jobs j ON a.job_id = j.job_id WHERE j.eid=?"
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
<title><%= fname %> <%= lname %> | Admin — SkillMitra</title>
<link rel="stylesheet" href="admin_dash.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ── Page base ── */
body { font-family:"Segoe UI",sans-serif; background:#f4f6f9; margin:0; padding:0; }

.page-wrapper {
    max-width: 780px;
    margin: 80px auto 60px;
    padding: 0 16px;
}

/* ── Back link ── */
.back-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: #4a6fa5;
    text-decoration: none;
    margin-bottom: 18px;
    font-weight: 500;
}
.back-link:hover { color: #2d4f80; }

/* ── Cards ── */
.card {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    padding: 28px 32px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

/* ── Profile top ── */
.profile-top {
    display: flex;
    align-items: flex-start;
    gap: 24px;
    padding-bottom: 24px;
    border-bottom: 1px solid #f0f2f5;
    margin-bottom: 24px;
}

.profile-photo {
    width: 88px; height: 88px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #e5e7eb;
    flex-shrink: 0;
}

.profile-initials {
    width: 88px; height: 88px;
    border-radius: 50%;
    background: #dbeafe;
    color: #1d4ed8;
    display: flex; align-items: center; justify-content: center;
    font-size: 28px; font-weight: 700;
    flex-shrink: 0;
}

.profile-name  { font-size: 22px; font-weight: 700; color: #1a2a3a; margin: 0 0 3px; }
.profile-company { font-size: 15px; color: #4a6fa5; font-weight: 600; margin: 0 0 4px; }
.profile-meta  { font-size: 13px; color: #6b7280; line-height: 1.8; margin: 0; }

/* ── Rating pill ── */
.rating-pill {
    display: inline-flex; align-items: center; gap: 8px;
    background: #fffbeb; border: 1px solid #fde68a;
    border-radius: 20px; padding: 5px 14px;
    margin-top: 8px; font-size: 13px; color: #92400e;
}
.star-filled { color: #f59e0b; }
.star-empty  { color: #d1d5db; }

/* ── Stats strip ── */
.stats-strip {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 20px;
}
.stat-box {
    background: #f8fafc;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    padding: 14px;
    text-align: center;
}
.stat-box .stat-num { font-size: 24px; font-weight: 700; color: #3b5bdb; }
.stat-box .stat-lbl { font-size: 11px; color: #9ca3af; margin-top: 2px; }

/* ── Section label ── */
.section-label {
    font-size: 11px; font-weight: 700; color: #9ca3af;
    text-transform: uppercase; letter-spacing: .06em;
    margin: 0 0 14px;
}

/* ── Info grid ── */
.info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 20px;
}
.info-item {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    padding: 12px 14px;
}
.info-label { font-size: 11px; color: #9ca3af; text-transform: uppercase; letter-spacing:.04em; margin-bottom: 4px; }
.info-value { font-size: 14px; color: #1a2a3a; font-weight: 500; }

/* ── Rating breakdown bars ── */
.rating-breakdown { display: flex; flex-direction: column; gap: 10px; }
.rb-row { display: flex; align-items: center; gap: 10px; }
.rb-label { font-size: 12px; color: #6b7280; width: 180px; flex-shrink: 0; }
.rb-bar-wrap { flex: 1; background: #f3f4f6; border-radius: 20px; height: 8px; overflow: hidden; }
.rb-bar-fill { height: 100%; border-radius: 20px; background: #f59e0b; transition: width .3s; }
.rb-val { font-size: 12px; font-weight: 600; color: #92400e; width: 30px; text-align: right; }

/* ── Recent reviews ── */
.review-card {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 10px;
}
.review-card:last-child { margin-bottom: 0; }
.review-stars { font-size: 13px; margin-bottom: 6px; }
.review-text { font-size: 13px; color: #374151; line-height: 1.6; }
.review-date { font-size: 11px; color: #9ca3af; margin-top: 6px; }

/* ── Admin badge ── */
.admin-badge {
    display: inline-flex; align-items: center; gap: 5px;
    background: #fef3c7; color: #92400e;
    font-size: 11px; font-weight: 600; padding: 3px 10px;
    border-radius: 20px; border: 1px solid #fde68a;
    margin-bottom: 14px;
}

hr.divider { border: none; border-top: 1px solid #f0f2f5; margin: 20px 0; }
</style>
</head>
<body>

<!-- ═══ HEADER (Admin) ═══ -->
<header style="display:flex; align-items:center; justify-content:space-between;
               padding:0 24px; background:#2d4f80; height:60px;
               position:fixed; top:0; left:0; width:100%;
               box-sizing:border-box; z-index:999;">
    <div style="display:flex; align-items:center; gap:12px;">
        <img src="skillmitralogo.jpg" alt="Logo"
             style="width:34px; height:34px; border-radius:50%; object-fit:cover;">
        <span style="color:#fff; font-size:19px; font-weight:700;">SkillMitra</span>
    </div>
    <div style="display:flex; align-items:center; gap:14px;">
        <span style="font-size:13px; color:rgba(255,255,255,0.8);">
            <i class="fa-solid fa-user-shield" style="margin-right:4px;"></i><%= adminUsername %>
        </span>
        <a href="admin_dash.jsp"
           style="background:rgba(255,255,255,0.12); color:#fff; padding:6px 14px;
                  border-radius:8px; text-decoration:none; font-size:13px;
                  border:1px solid rgba(255,255,255,0.25);">
            <i class="fa-solid fa-arrow-left" style="margin-right:4px;"></i>Dashboard
        </a>
    </div>
</header>

<!-- ═══ PAGE CONTENT ═══ -->
<div class="page-wrapper">

    <!-- ✅ Back button at TOP -->
    <a href="admin_dash.jsp?section=employers" class="back-link">
        <i class="fa-solid fa-arrow-left"></i> Back to Employers
    </a>

    <!-- Admin context badge -->
    <div class="admin-badge">
        <i class="fa-solid fa-user-shield"></i> Admin View — Employer Profile
    </div>

    <!-- ── CARD 1: Profile top ── -->
    <div class="card">
        <div class="profile-top">
            <% if (imgPath != null && !imgPath.isEmpty()) { %>
                <img src="<%= imgPath %>" class="profile-photo" alt="<%= fname %>">
            <% } else { %>
                <div class="profile-initials"><%= initials %></div>
            <% } %>

            <div style="flex:1;">
                <p class="profile-name"><%= fname %> <%= lname %></p>
                <% if (company != null && !company.isEmpty()) { %>
                    <p class="profile-company">
                        <i class="fa-solid fa-building" style="margin-right:5px; font-size:13px;"></i><%= company %>
                    </p>
                <% } %>
                <div class="profile-meta">
                    <% if (email != null && !email.isEmpty()) { %>
                        <i class="fa-solid fa-envelope" style="width:14px; color:#9ca3af;"></i> <%= email %><br>
                    <% } %>
                    <% if (phone != null && !phone.isEmpty()) { %>
                        <i class="fa-solid fa-phone" style="width:14px; color:#9ca3af;"></i> <%= phone %>
                    <% } %>
                    <% if (website != null && !website.isEmpty()) { %>
                        <br><i class="fa-solid fa-globe" style="width:14px; color:#9ca3af;"></i>
                        <a href="<%= website %>" target="_blank" style="color:#4a6fa5;"><%= website %></a>
                    <% } %>
                </div>

                <!-- Rating pill -->
                <div class="rating-pill">
                    <span>
                        <% for (int i = 1; i <= 5; i++) {
                            if (i <= Math.floor(avgRating)) { %><span class="star-filled">★</span><%
                            } else { %><span class="star-empty">★</span><% }
                        } %>
                    </span>
                    <% if (totalRatings > 0) { %>
                        <strong><%= avgRating %>/5</strong>
                        <span style="color:#b45309;">(<%= totalRatings %> review<%= totalRatings != 1 ? "s" : "" %>)</span>
                    <% } else { %>
                        <span style="color:#9ca3af;">No reviews yet</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Stats strip -->
        <div class="stats-strip">
            <div class="stat-box">
                <div class="stat-num"><%= totalJobs %></div>
                <div class="stat-lbl">Total Jobs Posted</div>
            </div>
            <div class="stat-box">
                <div class="stat-num" style="color:#16a34a;"><%= activeJobs %></div>
                <div class="stat-lbl">Active Jobs</div>
            </div>
            <div class="stat-box">
                <div class="stat-num" style="color:#7c3aed;"><%= totalApplications %></div>
                <div class="stat-lbl">Total Applications</div>
            </div>
        </div>

        <!-- Info grid -->
        <div class="section-label">Company & Location</div>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Company Name</div>
                <div class="info-value"><%= (company == null || company.isEmpty()) ? "Not added" : company %></div>
            </div>
            <div class="info-item">
                <div class="info-label">District</div>
                <div class="info-value"><%= (district == null || district.isEmpty()) ? "—" : district %></div>
            </div>
            <% if (area != null && !area.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Area</div>
                <div class="info-value"><%= area %></div>
            </div>
            <% } %>
            <div class="info-item">
                <div class="info-label">State</div>
                <div class="info-value"><%= (state == null || state.isEmpty()) ? "—" : state %></div>
            </div>
            <% if (country != null && !country.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Country</div>
                <div class="info-value"><%= country %></div>
            </div>
            <% } %>
        </div>

        <% if (bio != null && !bio.isEmpty()) { %>
        <hr class="divider">
        <div class="section-label">About / Bio</div>
        <p style="font-size:14px; color:#374151; line-height:1.7; margin:0;"><%= bio %></p>
        <% } %>
    </div>

    <!-- ── CARD 2: Rating Breakdown ── -->
    <% if (totalRatings > 0) { %>
    <div class="card">
        <div class="section-label">Rating Breakdown (by Job Seekers)</div>

        <div style="display:flex; align-items:center; gap:28px; margin-bottom:20px;">
            <div style="text-align:center;">
                <div style="font-size:48px; font-weight:800; color:#f59e0b; line-height:1;">
                    <%= avgRating %>
                </div>
                <div style="font-size:13px; color:#9ca3af; margin-top:4px;">out of 5</div>
                <div style="margin-top:6px;">
                    <% for (int i = 1; i <= 5; i++) {
                        if (i <= Math.floor(avgRating)) { %><span class="star-filled" style="font-size:18px;">★</span><%
                        } else { %><span class="star-empty" style="font-size:18px;">★</span><% }
                    } %>
                </div>
                <div style="font-size:12px; color:#6b7280; margin-top:4px;">
                    <%= totalRatings %> review<%= totalRatings != 1 ? "s" : "" %>
                </div>
            </div>

            <div class="rating-breakdown" style="flex:1;">
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

        <!-- Recent reviews -->
        <hr class="divider">
        <div class="section-label" style="margin-bottom:14px;">Recent Reviews</div>
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
                    ? new java.text.SimpleDateFormat("dd MMM yyyy").format(rsRev.getTimestamp("created_at"))
                    : "";
                String jsFname = rsRev.getString("jfirstname");
                String jsLname = rsRev.getString("jlastname");
        %>
            <div class="review-card">
                <div class="review-stars">
                    <% for (int i = 1; i <= 5; i++) {
                        if (i <= rv) { %><span class="star-filled">★</span><%
                        } else { %><span class="star-empty">★</span><% }
                    } %>
                    <span style="font-size:12px; font-weight:600; color:#92400e; margin-left:6px;"><%= rv %>/5</span>
                    <% if (jsFname != null) { %>
                        <span style="font-size:12px; color:#6b7280; margin-left:8px;">
                            — <%= jsFname %> <%= jsLname != null ? jsLname : "" %>
                        </span>
                    <% } %>
                </div>
                <% if (rText != null && !rText.trim().isEmpty()) { %>
                    <div class="review-text">"<%= rText %>"</div>
                <% } else { %>
                    <div class="review-text" style="color:#9ca3af; font-style:italic;">No written review.</div>
                <% } %>
                <div class="review-date"><%= revDate %></div>
            </div>
        <%
            }
            if (!anyRev) {
        %>
            <p style="font-size:13px; color:#9ca3af; text-align:center; padding:16px 0;">No reviews yet.</p>
        <%
            }
            rsRev.close(); psRev.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conRev != null) try { conRev.close(); } catch (Exception ignored) {} }
        %>
    </div>
    <% } %>

    <!-- ── CARD 3: Recent Jobs ── -->
    <div class="card">
        <div class="section-label">Recent Job Posts</div>
        <%
        Connection conJobs = null;
        try {
            conJobs = DBConnection.getConnection();
            PreparedStatement psJobs = conJobs.prepareStatement(
                "SELECT job_id, title, city, salary, job_type, status, created_at " +
                "FROM jobs WHERE eid=? ORDER BY job_id DESC LIMIT 6"
            );
            psJobs.setInt(1, eid);
            ResultSet rsJobs = psJobs.executeQuery();
            boolean anyJob = false;
            while (rsJobs.next()) {
                anyJob = true;
                String jobStatus = rsJobs.getString("status");
                String statusColor = "Active".equalsIgnoreCase(jobStatus)
                    ? "background:#dcfce7; color:#166534;"
                    : "background:#fee2e2; color:#991b1b;";
                String dStr = rsJobs.getTimestamp("created_at") != null
                    ? new java.text.SimpleDateFormat("dd MMM yyyy").format(rsJobs.getTimestamp("created_at"))
                    : "";
        %>
            <div style="display:flex; justify-content:space-between; align-items:center;
                        padding:12px 0; border-bottom:1px solid #f3f4f6;">
                <div>
                    <div style="font-size:14px; font-weight:600; color:#1a2a3a;">
                        <%= rsJobs.getString("title") %>
                    </div>
                    <div style="font-size:12px; color:#6b7280; margin-top:2px;">
                        <%= rsJobs.getString("city") != null ? rsJobs.getString("city") : "—" %> &nbsp;|&nbsp;
                        ₹<%= rsJobs.getString("salary") != null ? rsJobs.getString("salary") : "—" %> &nbsp;|&nbsp;
                        <%= rsJobs.getString("job_type") != null ? rsJobs.getString("job_type") : "—" %>
                    </div>
                </div>
                <div style="display:flex; align-items:center; gap:12px;">
                    <span style="padding:3px 10px; border-radius:20px; font-size:11px;
                                 font-weight:600; <%= statusColor %>">
                        <%= jobStatus %>
                    </span>
                    <span style="font-size:11px; color:#9ca3af;"><%= dStr %></span>
                </div>
            </div>
        <%
            }
            if (!anyJob) {
        %>
            <p style="font-size:13px; color:#9ca3af; text-align:center; padding:16px 0;">No jobs posted yet.</p>
        <%
            }
            rsJobs.close(); psJobs.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conJobs != null) try { conJobs.close(); } catch (Exception ignored) {} }
        %>
    </div>


</div><!-- end .page-wrapper -->
</body>
</html>
