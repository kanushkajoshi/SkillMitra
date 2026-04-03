<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* Only employers can view this page */
HttpSession currentSession = request.getSession(false);
if(currentSession == null || currentSession.getAttribute("eid") == null){
    response.sendRedirect("login.jsp");
    return;
}

String jidParam = request.getParameter("jid");
if(jidParam == null){
    response.sendRedirect("emp_dash.jsp");
    return;
}

int jid = Integer.parseInt(jidParam);

String fname="", lname="", email="", phone="";
String district="", area="", state="", country="";
String education="", dob="", photo="";
double avgRating = 0;
int totalRating = 0;

Connection con = null;
try {
    con = DBConnection.getConnection();

    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM jobseeker WHERE jid=?"
    );
    ps.setInt(1, jid);
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
        fname     = rs.getString("jfirstname");
        lname     = rs.getString("jlastname");
        email     = rs.getString("jemail");
        phone     = rs.getString("jphone");
        district  = rs.getString("jdistrict");
        area      = rs.getString("jarea");
        state     = rs.getString("jstate");
        country   = rs.getString("jcountry");
        education = rs.getString("jeducation");
        dob       = rs.getString("jdob");
        photo     = rs.getString("jphoto");
    }
    rs.close(); ps.close();

    PreparedStatement psR = con.prepareStatement(
        "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
        "FROM ratings WHERE jobseeker_id=? AND rating_by='Employer'"
    );
    psR.setInt(1, jid);
    ResultSet rsR = psR.executeQuery();
    if(rsR.next()){ avgRating = rsR.getDouble("avg_r"); totalRating = rsR.getInt("total"); }
    rsR.close(); psR.close();

} catch(Exception e){ e.printStackTrace(); }
finally { if(con != null) try{ con.close(); }catch(Exception ignored){} }

String imgPath = (photo != null && !photo.trim().isEmpty()) ? "uploads/" + photo : "images/default-user.png";
String initials = (fname.isEmpty() ? "?" : String.valueOf(fname.charAt(0)))
                + (lname.isEmpty() ? "" : String.valueOf(lname.charAt(0)));

/* Employer session data for header */
String empPhoto = (String) currentSession.getAttribute("ephoto");
String empImgPath = (empPhoto != null && !empPhoto.trim().isEmpty()) ? "uploads/" + empPhoto : "images/default-user.png";
String empFname = (String) currentSession.getAttribute("efirstname");
String empLname = (String) currentSession.getAttribute("elastname");
%>

<!DOCTYPE html>
<html>
<head>
<title><%= fname %> <%= lname %> | SkillMitra</title>
<link rel="stylesheet" href="emp_dash.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
body { font-family: "Segoe UI", sans-serif; background: #f4f6f9; margin: 0; padding: 0; }

.container {
    max-width: 720px;
    margin: 32px auto 60px;
    padding: 0 16px;
    margin-top: 80px;
    
    
    
}

.profile-card {
    background: #fff;
    border: 0.5px solid #e5e7eb;
    border-radius: 14px;
    padding: 32px;
}

.profile-top {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 24px;
    padding-bottom: 24px;
    border-bottom: 0.5px solid #f0f2f5;
}

.profile-photo {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #e5e7eb;
    flex-shrink: 0;
}

.profile-initials {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    background: #dbeafe;
    color: #1d4ed8;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 26px;
    font-weight: 600;
    flex-shrink: 0;
}

.profile-name {
    font-size: 22px;
    font-weight: 600;
    color: #1a2a3a;
    margin: 0 0 4px;
}

.profile-meta {
    font-size: 13px;
    color: #6b7280;
    line-height: 1.7;
}

.rating-row {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: #fffbeb;
    border: 0.5px solid #fde68a;
    border-radius: 20px;
    padding: 4px 14px;
    margin-top: 6px;
    font-size: 13px;
    color: #92400e;
}

.stars { letter-spacing: 1px; }
.star-filled { color: #f59e0b; }
.star-empty  { color: #d1d5db; }

.section-title {
    font-size: 11px;
    font-weight: 600;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin: 0 0 12px;
}

.info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 24px;
}

.info-item {
    background: #f9fafb;
    border: 0.5px solid #e5e7eb;
    border-radius: 10px;
    padding: 12px 14px;
}

.info-label {
    font-size: 11px;
    color:
</style>
</head>
<body>
<!-- ═══ HEADER ═══ -->
<header style="display:flex; align-items:center; justify-content:space-between; 
               padding:0 24px; position:relative; background:#4a6fa5; height:60px;
               width:100%; box-sizing:border-box; margin:0;  position:fixed;
    top:0;
    left:0;">

    <div style="display:flex; align-items:center; gap:12px;">
        <img src="skillmitralogo.jpg" alt="Logo" 
             style="width:35px; height:35px; border-radius:50%; object-fit:cover;">
        <div class="logo" style="color:#fff; font-size:20px; font-weight:700;">SkillMitra</div>
    </div>

    <div style="display:flex; align-items:center; gap:20px; margin-left:auto;">
        <div class="profile-dropdown">
            <img src="<%= empImgPath %>" class="profile-icon" id="profileIcon">
            <div class="profile-menu" id="profileMenu">
                <div class="profile-name" 
                     style="background:none; color:#000; font-weight:600; border-bottom:none;">
                    <%= empFname != null ? empFname : "" %>
                    <%= empLname != null ? empLname : "" %>
                </div>
                <a href="employer_profile.jsp">My Profile</a>
                <a href="emp_dash.jsp">Dashboard</a>
                <a href="LogoutServlet">Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- ═══ PROFILE CONTENT ═══ -->
<div class="container">
<div class="profile-card">

    <!-- TOP: Photo + Name + Meta -->
    <div class="profile-top">
        <% if(photo != null && !photo.trim().isEmpty()){ %>
            <img src="<%= imgPath %>" class="profile-photo" alt="<%= fname %>">
        <% } else { %>
            <div class="profile-initials"><%= initials %></div>
        <% } %>

        <div>
            <p class="profile-name"><%= fname %> <%= lname %></p>
            <div class="profile-meta">
                <% if(email != null && !email.isEmpty()){ %><%= email %><br><% } %>
                <% if(phone != null && !phone.isEmpty()){ %>📞 <%= phone %><% } %>
            </div>

            <div class="rating-row">
                <span class="stars">
                    <% for(int i=1;i<=5;i++){
                        if(i <= Math.floor(avgRating)) out.print("<span class='star-filled'>★</span>");
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

    <!-- Personal Info -->
    <div class="section-title">Personal Information</div>
    <div class="info-grid">
        <div class="info-item">
            <div class="info-label">Education</div>
            <div class="info-value"><%= (education==null||education.isEmpty()) ? "Not added" : education %></div>
        </div>
        <div class="info-item">
            <div class="info-label">Date of Birth</div>
            <div class="info-value"><%= (dob==null||dob.isEmpty()) ? "Not added" : dob %></div>
        </div>
        <div class="info-item">
            <div class="info-label">District</div>
            <div class="info-value"><%= (district==null||district.isEmpty()) ? "—" : district %></div>
        </div>
        <div class="info-item">
            <div class="info-label">Area</div>
            <div class="info-value"><%= (area==null||area.isEmpty()) ? "—" : area %></div>
        </div>
        <div class="info-item">
            <div class="info-label">State</div>
            <div class="info-value"><%= (state==null||state.isEmpty()) ? "—" : state %></div>
        </div>
        <div class="info-item">
            <div class="info-label">Country</div>
            <div class="info-value"><%= (country==null||country.isEmpty()) ? "—" : country %></div>
        </div>
    </div>

    <hr class="divider">

    <!-- Skills -->
    <div class="section-title">Skills</div>
    <%
    Connection conSkill = null;
    try {
        conSkill = DBConnection.getConnection();

        PreparedStatement psSkill = conSkill.prepareStatement(
            "SELECT DISTINCT s.skill_name FROM jobseeker_skills js " +
            "JOIN skill s ON js.skill_id = s.skill_id WHERE js.jid=?"
        );
        psSkill.setInt(1, jid);
        ResultSet rsSkill = psSkill.executeQuery();
    %>
    <div class="info-item" style="margin-bottom:12px;">
        <div class="info-label">Main Skill</div>
        <div class="info-value">
        <% boolean anySkill = false;
           while(rsSkill.next()){ anySkill=true; out.print(rsSkill.getString("skill_name")); }
           if(!anySkill) out.print("Not added");
        %>
        </div>
    </div>
    <%
        rsSkill.close(); psSkill.close();

        PreparedStatement psSub = conSkill.prepareStatement(
            "SELECT ss.subskill_name FROM jobseeker_skills js " +
            "JOIN subskill ss ON js.subskill_id = ss.subskill_id WHERE js.jid=?"
        );
        psSub.setInt(1, jid);
        ResultSet rsSub = psSub.executeQuery();
        boolean anySub = false;
    %>
    <div class="info-label" style="margin-bottom:8px;">Subskills</div>
    <div class="tag-list">
    <% while(rsSub.next()){ anySub=true; %>
        <span class="tag"><%= rsSub.getString("subskill_name") %></span>
    <% }
       if(!anySub){ %><span style="font-size:13px;color:#9ca3af;">Not added</span><% } %>
    </div>
    <%
        rsSub.close(); psSub.close();
    } catch(Exception e){ e.printStackTrace(); }
    finally { if(conSkill!=null) try{ conSkill.close(); }catch(Exception ignored){} }
    %>

</div>
</div>

<script>
const profileIcon = document.getElementById("profileIcon");
const profileMenu = document.getElementById("profileMenu");
profileIcon.addEventListener("click", () => {
    profileMenu.style.display = profileMenu.style.display === "block" ? "none" : "block";
});

// Close dropdown when clicking outside
document.addEventListener("click", function(e){
    if(!profileIcon.contains(e.target) && !profileMenu.contains(e.target)){
        profileMenu.style.display = "none";
    }
});
</script>

</body>
</html>