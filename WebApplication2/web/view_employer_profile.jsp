<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* Jobseekers view this page */
HttpSession currentSession = request.getSession(false);
if(currentSession == null || currentSession.getAttribute("jobseekerId") == null){
    response.sendRedirect("login.jsp");
    return;
}

String eidParam = request.getParameter("eid");
if(eidParam == null){
    response.sendRedirect("job_search.jsp");
    return;
}
int eid = Integer.parseInt(eidParam);

String fname="", lname="", email="", phone="";
String district="", area="", state="", country="";
String company="", website="", photo="";
double avgRating = 0;
int totalRating = 0;

Connection con = null;
try {
    con = DBConnection.getConnection();

    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM employer WHERE eid=?"
    );
    ps.setInt(1, eid);
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
        fname    = rs.getString("efirstname");
        lname    = rs.getString("elastname");
        email    = rs.getString("eemail");
        phone    = rs.getString("ephone");
        district = rs.getString("edistrict");
        area     = rs.getString("earea");
        state    = rs.getString("estate");
        country  = rs.getString("ecountry");
        company  = rs.getString("ecompanyname");
        website  = rs.getString("ecompanywebsite");
        photo    = rs.getString("ephoto");
    }
    rs.close(); ps.close();

    PreparedStatement psR = con.prepareStatement(
        "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
        "FROM ratings WHERE employer_id=? AND rating_by='Jobseeker'"
    );
    psR.setInt(1, eid);
    ResultSet rsR = psR.executeQuery();
    if(rsR.next()){
        avgRating   = rsR.getDouble("avg_r");
        totalRating = rsR.getInt("total");
    }
    rsR.close(); psR.close();

} catch(Exception e){ e.printStackTrace(); }
finally { if(con!=null) try{ con.close(); }catch(Exception ig){} }

String imgPath  = (photo != null && !photo.trim().isEmpty()) ? "uploads/" + photo : "images/default-user.png";
String initials = (fname.isEmpty() ? "?" : String.valueOf(fname.charAt(0)))
                + (lname.isEmpty() ? ""  : String.valueOf(lname.charAt(0)));

/* Jobseeker session data for header */
int jobseekerId = (Integer) currentSession.getAttribute("jobseekerId");
String jsPhoto  = (String) currentSession.getAttribute("jphoto");
String jsImg    = (jsPhoto != null && !jsPhoto.trim().isEmpty())
                  ? "uploads/" + jsPhoto : "images/default-user.png";

String displayName = "";
Connection conDN = null;
try {
    conDN = DBConnection.getConnection();
    PreparedStatement psDN = conDN.prepareStatement(
        "SELECT jfirstname, jlastname FROM jobseeker WHERE jid=?"
    );
    psDN.setInt(1, jobseekerId);
    ResultSet rsDN = psDN.executeQuery();
    if(rsDN.next())
        displayName = rsDN.getString("jfirstname") + " " + rsDN.getString("jlastname");
    rsDN.close(); psDN.close();
} catch(Exception e){ e.printStackTrace(); }
finally { if(conDN!=null) try{ conDN.close(); }catch(Exception ig){} }
%>

<!DOCTYPE html>
<html>
<head>
<title><%= fname %> <%= lname %> | SkillMitra</title>
<link rel="stylesheet" href="emp_dash.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
body { font-family:"Segoe UI",sans-serif; background:#f4f6f9; margin:0; padding:0; }

.container {
    max-width:720px;
    margin:80px auto 60px;
    padding:0 16px;
}

.profile-card {
    background:#fff;
    border:0.5px solid #e5e7eb;
    border-radius:14px;
    padding:32px;
}

.profile-top {
    display:flex;
    align-items:center;
    gap:24px;
    margin-bottom:24px;
    padding-bottom:24px;
    border-bottom:0.5px solid #f0f2f5;
}

.profile-photo {
    width:90px; height:90px;
    border-radius:50%; object-fit:cover;
    border:2px solid #e5e7eb; flex-shrink:0;
}

.profile-initials {
    width:90px; height:90px;
    border-radius:50%;
    background:#dbeafe; color:#1d4ed8;
    display:flex; align-items:center;
    justify-content:center;
    font-size:26px; font-weight:600; flex-shrink:0;
}

.profile-name { font-size:22px; font-weight:600; color:#1a2a3a; margin:0 0 4px; }
.profile-meta { font-size:13px; color:#6b7280; line-height:1.7; }

.rating-row {
    display:inline-flex; align-items:center; gap:8px;
    background:#fffbeb; border:0.5px solid #fde68a;
    border-radius:20px; padding:4px 14px; margin-top:6px;
    font-size:13px; color:#92400e;
}

.star-filled { color:#f59e0b; }
.star-empty  { color:#d1d5db; }

.section-title {
    font-size:11px; font-weight:600; color:#9ca3af;
    text-transform:uppercase; letter-spacing:0.05em;
    margin:0 0 12px;
}

.info-grid {
    display:grid; grid-template-columns:1fr 1fr;
    gap:12px; margin-bottom:24px;
}

.info-item {
    background:#f9fafb;
    border:0.5px solid #e5e7eb;
    border-radius:10px; padding:12px 14px;
}

.info-label {
    font-size:11px; color:#9ca3af;
    text-transform:uppercase; letter-spacing:0.04em;
    margin-bottom:4px; font-weight:600;
}

.info-value { font-size:14px; color:#1a2a3a; font-weight:500; }

.divider { border:none; border-top:0.5px solid #e5e7eb; margin:20px 0; }

.website-link {
    color:#1d4ed8; text-decoration:none; font-size:13px;
    word-break:break-all;
}
.website-link:hover { text-decoration:underline; }

.back-btn {
    display:inline-flex; align-items:center; gap:6px;
    background:#fff; border:0.5px solid #e5e7eb;
    border-radius:8px; padding:8px 14px;
    font-size:13px; color:#374151; text-decoration:none;
    margin-bottom:16px; font-weight:500;
}
.back-btn:hover { background:#f9fafb; }
</style>
</head>
<body>

<!-- HEADER -->
<header style="display:flex;align-items:center;justify-content:space-between;
               padding:0 24px;background:#4a6fa5;height:60px;
               width:100%;box-sizing:border-box;position:fixed;top:0;left:0;z-index:999;">
    <div style="display:flex;align-items:center;gap:12px;">
        <img src="skillmitralogo.jpg" alt="Logo"
             style="width:35px;height:35px;border-radius:50%;object-fit:cover;">
        <div style="color:#fff;font-size:20px;font-weight:700;">SkillMitra</div>
    </div>
    <div style="display:flex;align-items:center;gap:20px;margin-left:auto;position:relative;">
        <img src="<%= jsImg %>" id="profileIcon"
             style="width:38px;height:38px;border-radius:50%;
                    border:2px solid white;cursor:pointer;object-fit:cover;">
        <div id="profileMenu"
             style="display:none;position:absolute;right:0;top:50px;
                    background:#fff;width:200px;border-radius:10px;
                    box-shadow:0 8px 25px rgba(0,0,0,0.15);z-index:999;">
            <div style="padding:12px 14px;font-weight:600;border-bottom:1px solid #eee;
                        color:#1a2a3a;font-size:15px;background:#f9fafb;border-radius:10px 10px 0 0;">
                <%= displayName %>
            </div>
            <a href="jobseeker_profile.jsp"
               style="display:block;padding:10px 14px;color:#333;text-decoration:none;">
               View Profile
            </a>
            <a href="LogoutServlet"
               style="display:block;padding:10px 14px;color:#333;text-decoration:none;">
               Logout
            </a>
        </div>
    </div>
</header>

<!-- CONTENT -->
<div class="container">

    <a href="javascript:history.back()" class="back-btn">
        <i class="fa-solid fa-arrow-left"></i> Back
    </a>

    <div class="profile-card">

        <!-- TOP: Photo + Name -->
        <div class="profile-top">
            <% if(photo != null && !photo.trim().isEmpty()){ %>
                <img src="<%= imgPath %>" class="profile-photo" alt="<%= fname %>">
            <% } else { %>
                <div class="profile-initials"><%= initials %></div>
            <% } %>

            <div>
                <p class="profile-name"><%= fname %> <%= lname %></p>
                <div class="profile-meta">
                    <strong style="color:#1a2a3a;"><%= company %></strong><br>
                    <% if(email != null && !email.isEmpty()){ %>
                        <i class="fa-solid fa-envelope" style="font-size:11px;margin-right:4px;"></i><%= email %><br>
                    <% } %>
                    <% if(phone != null && !phone.isEmpty()){ %>
                        <i class="fa-solid fa-phone" style="font-size:11px;margin-right:4px;"></i><%= phone %>
                    <% } %>
                </div>

                <div class="rating-row">
                    <span>
                        <% for(int i=1;i<=5;i++){
                            if(i<=Math.floor(avgRating)) out.print("<span class='star-filled'>★</span>");
                            else out.print("<span class='star-empty'>★</span>");
                        } %>
                    </span>
                    <% if(totalRating > 0){ %>
                        <strong><%= avgRating %>/5</strong>
                        <span style="color:#9ca3af;">(<%= totalRating %> review<%= totalRating!=1?"s":"" %>)</span>
                    <% } else { %>
                        <span style="color:#9ca3af;">No reviews yet</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Company Info -->
        <div class="section-title">Company Information</div>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Company Name</div>
                <div class="info-value"><%= (company==null||company.isEmpty())?"—":company %></div>
            </div>
            <div class="info-item">
                <div class="info-label">Website</div>
                <div class="info-value">
                    <% if(website!=null && !website.trim().isEmpty()){ %>
                        <a href="<%= website %>" target="_blank" class="website-link"><%= website %></a>
                    <% } else { %>—<% } %>
                </div>
            </div>
            <div class="info-item">
                <div class="info-label">District</div>
                <div class="info-value"><%= (district==null||district.isEmpty())?"—":district %></div>
            </div>
            <div class="info-item">
                <div class="info-label">Area</div>
                <div class="info-value"><%= (area==null||area.isEmpty())?"—":area %></div>
            </div>
            <div class="info-item">
                <div class="info-label">State</div>
                <div class="info-value"><%= (state==null||state.isEmpty())?"—":state %></div>
            </div>
            <div class="info-item">
                <div class="info-label">Country</div>
                <div class="info-value"><%= (country==null||country.isEmpty())?"—":country %></div>
            </div>
        </div>

    </div>
</div>

<script>
document.getElementById("profileIcon").addEventListener("click", function(e){
    e.stopPropagation();
    var m = document.getElementById("profileMenu");
    m.style.display = m.style.display === "block" ? "none" : "block";
});
document.addEventListener("click", function(){
    document.getElementById("profileMenu").style.display = "none";
});
</script>
</body>
</html>
