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

String jidParam = request.getParameter("jid");
if (jidParam == null) {
    response.sendRedirect("admin_dash.jsp?section=jobseekers");
    return;
}
int jid = Integer.parseInt(jidParam);

/* ── Jobseeker fields ── */
String fname = "", lname = "", email = "", phone = "";
String district = "", area = "", state = "", country = "";
String education = "", dob = "", photo = "";

/* ── Rating fields (given BY Employers TO this jobseeker) ── */
double avgRating = 0;
int    totalRatings = 0;
double avgWorkQuality = 0, avgPerformance = 0, avgPunctuality = 0, avgProfBehavior = 0;

/* ── Application stats ── */
int totalApplications = 0, acceptedApplications = 0;

Connection con = null;
try {
    con = DBConnection.getConnection();

    /* Jobseeker basic info */
    PreparedStatement ps = con.prepareStatement("SELECT * FROM jobseeker WHERE jid=?");
    ps.setInt(1, jid);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        fname     = rs.getString("jfirstname");
        lname     = rs.getString("jlastname");
        email     = rs.getString("jemail");
        phone     = rs.getString("jphone");
        district  = rs.getString("jdistrict");
        education = rs.getString("jeducation");
        dob       = rs.getString("jdob");
        photo     = rs.getString("jphoto");
        try { area    = rs.getString("jarea");    } catch (Exception ignored) {}
        try { state   = rs.getString("jstate");   } catch (Exception ignored) {}
        try { country = rs.getString("jcountry"); } catch (Exception ignored) {}
    }
    rs.close(); ps.close();

    /* Average overall rating + sub-ratings (from Employers) */
    PreparedStatement psR = con.prepareStatement(
        "SELECT " +
        "  ROUND(AVG(rating_value),1)            AS avg_r, " +
        "  COUNT(*)                               AS total, " +
        "  ROUND(AVG(work_quality),1)             AS avg_wq, " +
        "  ROUND(AVG(performance),1)              AS avg_perf, " +
        "  ROUND(AVG(punctuality),1)              AS avg_punct, " +
        "  ROUND(AVG(professional_behavior),1)    AS avg_pb " +
        "FROM ratings WHERE jobseeker_id=? AND rating_by='Employer'"
    );
    psR.setInt(1, jid);
    ResultSet rsR = psR.executeQuery();
    if (rsR.next() && rsR.getInt("total") > 0) {
        avgRating       = rsR.getDouble("avg_r");
        totalRatings    = rsR.getInt("total");
        avgWorkQuality  = rsR.getDouble("avg_wq");
        avgPerformance  = rsR.getDouble("avg_perf");
        avgPunctuality  = rsR.getDouble("avg_punct");
        avgProfBehavior = rsR.getDouble("avg_pb");
    }
    rsR.close(); psR.close();

    /* Application stats */
    PreparedStatement psA = con.prepareStatement(
        "SELECT COUNT(*) AS total, " +
        "SUM(CASE WHEN status='Accepted' THEN 1 ELSE 0 END) AS accepted " +
        "FROM applications WHERE jobseeker_id=?"
    );
    psA.setInt(1, jid);
    ResultSet rsA = psA.executeQuery();
    if (rsA.next()) {
        totalApplications    = rsA.getInt("total");
        acceptedApplications = rsA.getInt("accepted");
    }
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
body { font-family:"Segoe UI",sans-serif; background:#f4f6f9; margin:0; padding:0; }

.page-wrapper {
    max-width: 780px;
    margin: 80px auto 60px;
    padding: 0 16px;
}

.back-link {
    display: inline-flex; align-items: center; gap: 6px;
    font-size: 13px; color: #4a6fa5; text-decoration: none;
    margin-bottom: 14px; font-weight: 500;
}
.back-link:hover { color: #2d4f80; }

.card {
    background: #fff; border: 1px solid #e5e7eb;
    border-radius: 14px; padding: 28px 32px;
    margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

.profile-top {
    display: flex; align-items: flex-start; gap: 24px;
    padding-bottom: 24px; border-bottom: 1px solid #f0f2f5; margin-bottom: 24px;
}

.profile-photo {
    width: 88px; height: 88px; border-radius: 50%;
    object-fit: cover; border: 2px solid #e5e7eb; flex-shrink: 0;
}

.profile-initials {
    width: 88px; height: 88px; border-radius: 50%;
    background: #dcfce7; color: #166534;
    display: flex; align-items: center; justify-content: center;
    font-size: 28px; font-weight: 700; flex-shrink: 0;
}

.profile-name  { font-size: 22px; font-weight: 700; color: #1a2a3a; margin: 0 0 3px; }
.profile-meta  { font-size: 13px; color: #6b7280; line-height: 1.8; margin: 0; }

.rating-pill {
    display: inline-flex; align-items: center; gap: 8px;
    background: #fffbeb; border: 1px solid #fde68a;
    border-radius: 20px; padding: 5px 14px;
    margin-top: 8px; font-size: 13px; color: #92400e;
}
.star-filled { color: #f59e0b; }
.star-empty  { color: #d1d5db; }

.stats-strip {
    display: grid; grid-template-columns: repeat(3,1fr);
    gap: 12px; margin-bottom: 20px;
}
.stat-box {
    background: #f8fafc; border: 1px solid #e5e7eb;
    border-radius: 10px; padding: 14px; text-align: center;
}
.stat-box .stat-num { font-size: 24px; font-weight: 700; color: #3b5bdb; }
.stat-box .stat-lbl { font-size: 11px; color: #9ca3af; margin-top: 2px; }

.section-label {
    font-size: 11px; font-weight: 700; color: #9ca3af;
    text-transform: uppercase; letter-spacing: .06em; margin: 0 0 14px;
}

.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; }
.info-item {
    background: #f9fafb; border: 1px solid #e5e7eb;
    border-radius: 10px; padding: 12px 14px;
}
.info-label { font-size: 11px; color: #9ca3af; text-transform: uppercase; letter-spacing:.04em; margin-bottom: 4px; }
.info-value { font-size: 14px; color: #1a2a3a; font-weight: 500; }

.rating-breakdown { display: flex; flex-direction: column; gap: 10px; }
.rb-row { display: flex; align-items: center; gap: 10px; }
.rb-label { font-size: 12px; color: #6b7280; width: 180px; flex-shrink: 0; }
.rb-bar-wrap { flex: 1; background: #f3f4f6; border-radius: 20px; height: 8px; overflow: hidden; }
.rb-bar-fill { height: 100%; border-radius: 20px; background: #f59e0b; }
.rb-val { font-size: 12px; font-weight: 600; color: #92400e; width: 30px; text-align: right; }

.review-card {
    background: #f9fafb; border: 1px solid #e5e7eb;
    border-radius: 10px; padding: 14px 16px; margin-bottom: 10px;
}
.review-card:last-child { margin-bottom: 0; }
.review-stars { font-size: 13px; margin-bottom: 6px; }
.review-text { font-size: 13px; color: #374151; line-height: 1.6; }
.review-date { font-size: 11px; color: #9ca3af; margin-top: 6px; }

.admin-badge {
    display: inline-flex; align-items: center; gap: 5px;
    background: #f0fdf4; color: #166534;
    font-size: 11px; font-weight: 600; padding: 3px 10px;
    border-radius: 20px; border: 1px solid #bbf7d0;
    margin-bottom: 14px;
}

.tag { display:inline-block; background:#eff6ff; color:#1d4ed8;
       border:1px solid #bfdbfe; border-radius:20px;
       padding:3px 10px; font-size:12px; margin:3px; }
.tag-list { display:flex; flex-wrap:wrap; gap:4px; margin-bottom:16px; }

hr.divider { border:none; border-top:1px solid #f0f2f5; margin:20px 0; }
</style>
</head>
<body>

<!-- HEADER -->
<header style="display:flex;align-items:center;justify-content:space-between;
               padding:0 24px;background:#2d4f80;height:60px;
               position:fixed;top:0;left:0;width:100%;
               box-sizing:border-box;z-index:999;">
    <div style="display:flex;align-items:center;gap:12px;">
        <img src="skillmitralogo.jpg" alt="Logo" style="width:34px;height:34px;border-radius:50%;object-fit:cover;">
        <span style="color:#fff;font-size:19px;font-weight:700;">SkillMitra</span>
    </div>
    <div style="display:flex;align-items:center;gap:14px;">
        <span style="font-size:13px;color:rgba(255,255,255,0.8);">
            <i class="fa-solid fa-user-shield" style="margin-right:4px;"></i><%= adminUsername %>
        </span>
        <a href="admin_dash.jsp?section=jobseekers"
           style="background:rgba(255,255,255,0.12);color:#fff;padding:6px 14px;
                  border-radius:8px;text-decoration:none;font-size:13px;
                  border:1px solid rgba(255,255,255,0.25);">
            <i class="fa-solid fa-arrow-left" style="margin-right:4px;"></i>Job Seekers
        </a>
    </div>
</header>

<!-- PAGE CONTENT -->
<div class="page-wrapper">

    <!-- ✅ Back button at TOP -->
    <a href="admin_dash.jsp?section=jobseekers" class="back-link">
        <i class="fa-solid fa-arrow-left"></i> Back to Job Seekers
    </a>

    <!-- Admin badge -->
    <div class="admin-badge">
        <i class="fa-solid fa-user-shield"></i> Admin View — Job Seeker Profile
    </div>

    <!-- CARD 1: Profile top -->
    <div class="card">
        <div class="profile-top">
            <% if (imgPath != null && !imgPath.isEmpty()) { %>
                <img src="<%= imgPath %>" class="profile-photo" alt="<%= fname %>">
            <% } else { %>
                <div class="profile-initials"><%= initials %></div>
            <% } %>

            <div style="flex:1;">
                <p class="profile-name"><%= fname %> <%= lname %></p>
                <div class="profile-meta">
                    <% if (!email.isEmpty()) { %>
                        <i class="fa-solid fa-envelope" style="width:14px;color:#9ca3af;"></i> <%= email %><br>
                    <% } %>
                    <% if (phone != null && !phone.isEmpty()) { %>
                        <i class="fa-solid fa-phone" style="width:14px;color:#9ca3af;"></i> <%= phone %>
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
                        <span style="color:#b45309;">(<%= totalRatings %> review<%= totalRatings!=1?"s":"" %>)</span>
                    <% } else { %>
                        <span style="color:#9ca3af;">No reviews yet</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Stats strip -->
        <div class="stats-strip">
            <div class="stat-box">
                <div class="stat-num"><%= totalApplications %></div>
                <div class="stat-lbl">Total Applications</div>
            </div>
            <div class="stat-box">
                <div class="stat-num" style="color:#16a34a;"><%= acceptedApplications %></div>
                <div class="stat-lbl">Accepted</div>
            </div>
            <div class="stat-box">
                <div class="stat-num" style="color:#f59e0b;"><%= totalRatings %></div>
                <div class="stat-lbl">Total Reviews</div>
            </div>
        </div>

        <!-- Info grid -->
        <div class="section-label">Personal Information</div>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Education</div>
                <div class="info-value"><%= (education==null||education.isEmpty())?"Not added":education %></div>
            </div>
            <div class="info-item">
                <div class="info-label">Date of Birth</div>
                <div class="info-value"><%= (dob==null||dob.isEmpty())?"Not added":dob %></div>
            </div>
            <div class="info-item">
                <div class="info-label">District</div>
                <div class="info-value"><%= (district==null||district.isEmpty())?"—":district %></div>
            </div>
            <% if (area != null && !area.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Area</div>
                <div class="info-value"><%= area %></div>
            </div>
            <% } %>
            <div class="info-item">
                <div class="info-label">State</div>
                <div class="info-value"><%= (state==null||state.isEmpty())?"—":state %></div>
            </div>
            <% if (country != null && !country.isEmpty()) { %>
            <div class="info-item">
                <div class="info-label">Country</div>
                <div class="info-value"><%= country %></div>
            </div>
            <% } %>
        </div>

        <hr class="divider">

        <!-- Skills -->
        <div class="section-label">Skills</div>
        <%
        Connection conSkill = null;
        try {
            conSkill = DBConnection.getConnection();
            PreparedStatement psSkill = conSkill.prepareStatement(
                "SELECT DISTINCT s.skill_name FROM jobseeker_skills js " +
                "JOIN skill s ON js.skill_id=s.skill_id WHERE js.jid=?"
            );
            psSkill.setInt(1, jid);
            ResultSet rsSkill = psSkill.executeQuery();
        %>
        <div class="info-item" style="margin-bottom:12px;">
            <div class="info-label">Main Skill</div>
            <div class="info-value">
            <% boolean anySkill = false;
               while (rsSkill.next()) { anySkill=true; out.print(rsSkill.getString("skill_name")); }
               if (!anySkill) out.print("Not added");
            %>
            </div>
        </div>
        <%
            rsSkill.close(); psSkill.close();
            PreparedStatement psSub = conSkill.prepareStatement(
                "SELECT ss.subskill_name FROM jobseeker_skills js " +
                "JOIN subskill ss ON js.subskill_id=ss.subskill_id WHERE js.jid=?"
            );
            psSub.setInt(1, jid);
            ResultSet rsSub = psSub.executeQuery();
            boolean anySub = false;
        %>
        <div class="info-label" style="margin-bottom:8px;">Subskills</div>
        <div class="tag-list">
        <% while (rsSub.next()) { anySub=true; %>
            <span class="tag"><%= rsSub.getString("subskill_name") %></span>
        <% } if (!anySub) { %><span style="font-size:13px;color:#9ca3af;">Not added</span><% } %>
        </div>
        <%
            rsSub.close(); psSub.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conSkill!=null) try{conSkill.close();}catch(Exception ig){} }
        %>
    </div>

    <!-- CARD 2: Rating Breakdown -->
    <% if (totalRatings > 0) { %>
    <div class="card">
        <div class="section-label">Rating Breakdown (by Employers)</div>

        <div style="display:flex;align-items:center;gap:28px;margin-bottom:20px;">
            <div style="text-align:center;">
                <div style="font-size:48px;font-weight:800;color:#f59e0b;line-height:1;">
                    <%= avgRating %>
                </div>
                <div style="font-size:13px;color:#9ca3af;margin-top:4px;">out of 5</div>
                <div style="margin-top:6px;">
                    <% for (int i=1;i<=5;i++) {
                        if (i<=Math.floor(avgRating)) { %><span class="star-filled" style="font-size:18px;">★</span><%
                        } else { %><span class="star-empty" style="font-size:18px;">★</span><% }
                    } %>
                </div>
                <div style="font-size:12px;color:#6b7280;margin-top:4px;">
                    <%= totalRatings %> review<%= totalRatings!=1?"s":"" %>
                </div>
            </div>

            <div class="rating-breakdown" style="flex:1;">
                <div class="rb-row">
                    <span class="rb-label">Work Quality</span>
                    <div class="rb-bar-wrap"><div class="rb-bar-fill" style="width:<%= (avgWorkQuality/5.0*100) %>%;"></div></div>
                    <span class="rb-val"><%= avgWorkQuality %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Performance</span>
                    <div class="rb-bar-wrap"><div class="rb-bar-fill" style="width:<%= (avgPerformance/5.0*100) %>%;"></div></div>
                    <span class="rb-val"><%= avgPerformance %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Punctuality</span>
                    <div class="rb-bar-wrap"><div class="rb-bar-fill" style="width:<%= (avgPunctuality/5.0*100) %>%;"></div></div>
                    <span class="rb-val"><%= avgPunctuality %></span>
                </div>
                <div class="rb-row">
                    <span class="rb-label">Professional Behaviour</span>
                    <div class="rb-bar-wrap"><div class="rb-bar-fill" style="width:<%= (avgProfBehavior/5.0*100) %>%;"></div></div>
                    <span class="rb-val"><%= avgProfBehavior %></span>
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
                "       e.efirstname, e.elastname, e.ecompanyname " +
                "FROM ratings r " +
                "LEFT JOIN employer e ON r.employer_id = e.eid " +
                "WHERE r.jobseeker_id=? AND r.rating_by='Employer' " +
                "ORDER BY r.created_at DESC LIMIT 5"
            );
            psRev.setInt(1, jid);
            ResultSet rsRev = psRev.executeQuery();
            boolean anyRev = false;
            while (rsRev.next()) {
                anyRev = true;
                int rv = rsRev.getInt("rating_value");
                String rText  = rsRev.getString("review_text");
                String revDate = rsRev.getTimestamp("created_at") != null
                    ? new java.text.SimpleDateFormat("dd MMM yyyy").format(rsRev.getTimestamp("created_at")) : "";
                String eFname   = rsRev.getString("efirstname");
                String eLname   = rsRev.getString("elastname");
                String eCompany = rsRev.getString("ecompanyname");
        %>
            <div class="review-card">
                <div class="review-stars">
                    <% for (int i=1;i<=5;i++) {
                        if (i<=rv) { %><span class="star-filled">★</span><%
                        } else { %><span class="star-empty">★</span><% }
                    } %>
                    <span style="font-size:12px;font-weight:600;color:#92400e;margin-left:6px;"><%= rv %>/5</span>
                    <% if (eFname != null) { %>
                        <span style="font-size:12px;color:#6b7280;margin-left:8px;">
                            — <%= eFname %> <%= eLname!=null?eLname:"" %>
                            <% if (eCompany!=null && !eCompany.isEmpty()) { %>
                                (<%= eCompany %>)
                            <% } %>
                        </span>
                    <% } %>
                </div>
                <% if (rText!=null && !rText.trim().isEmpty()) { %>
                    <div class="review-text">"<%= rText %>"</div>
                <% } else { %>
                    <div class="review-text" style="color:#9ca3af;font-style:italic;">No written review.</div>
                <% } %>
                <div class="review-date"><%= revDate %></div>
            </div>
        <%
            }
            if (!anyRev) { %>
            <p style="font-size:13px;color:#9ca3af;text-align:center;padding:16px 0;">No reviews yet.</p>
        <% }
            rsRev.close(); psRev.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conRev!=null) try{conRev.close();}catch(Exception ig){} }
        %>
    </div>
    <% } %>

    <!-- CARD 3: Recent Applications -->
    <div class="card">
        <div class="section-label">Recent Applications</div>
        <%
        Connection conApps = null;
        try {
            conApps = DBConnection.getConnection();
            PreparedStatement psApps = conApps.prepareStatement(
                "SELECT a.application_id, j.title, j.city, a.status, a.applied_at, " +
                "CONCAT(e.efirstname,' ',e.elastname) AS emp_name " +
                "FROM applications a " +
                "JOIN jobs j ON a.job_id=j.job_id " +
                "JOIN employer e ON j.eid=e.eid " +
                "WHERE a.jobseeker_id=? ORDER BY a.applied_at DESC LIMIT 6"
            );
            psApps.setInt(1, jid);
            ResultSet rsApps = psApps.executeQuery();
            boolean anyApp = false;
            while (rsApps.next()) {
                anyApp = true;
                String appStatus = rsApps.getString("status");
                String sc = "Accepted".equalsIgnoreCase(appStatus)
                    ? "background:#dcfce7;color:#166534;"
                    : "Rejected".equalsIgnoreCase(appStatus)
                        ? "background:#fee2e2;color:#991b1b;"
                        : "background:#fef9c3;color:#854d0e;";
                String appDate = rsApps.getTimestamp("applied_at") != null
                    ? new java.text.SimpleDateFormat("dd MMM yyyy").format(rsApps.getTimestamp("applied_at")) : "";
        %>
            <div style="display:flex;justify-content:space-between;align-items:center;
                        padding:12px 0;border-bottom:1px solid #f3f4f6;">
                <div>
                    <div style="font-size:14px;font-weight:600;color:#1a2a3a;">
                        <%= rsApps.getString("title") %>
                    </div>
                    <div style="font-size:12px;color:#6b7280;margin-top:2px;">
                        <%= rsApps.getString("emp_name") %> &nbsp;|&nbsp;
                        <%= rsApps.getString("city")!=null?rsApps.getString("city"):"—" %>
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:12px;">
                    <span style="padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;<%= sc %>">
                        <%= appStatus %>
                    </span>
                    <span style="font-size:11px;color:#9ca3af;"><%= appDate %></span>
                </div>
            </div>
        <%
            }
            if (!anyApp) { %>
            <p style="font-size:13px;color:#9ca3af;text-align:center;padding:16px 0;">No applications yet.</p>
        <% }
            rsApps.close(); psApps.close();
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conApps!=null) try{conApps.close();}catch(Exception ig){} }
        %>
    </div>

</div><!-- end .page-wrapper -->
</body>
</html>
