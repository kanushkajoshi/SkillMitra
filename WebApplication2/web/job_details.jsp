<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%

/* 🔒 Prevent browser caching */
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

/* 🔒 SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("jobseekerId") == null) {
    response.sendRedirect("login.jsp");
    return;
}

int jobseekerId = (Integer) currentSession.getAttribute("jobseekerId");
int jobId = Integer.parseInt(request.getParameter("jobId"));
System.out.println("DEBUG jobseekerId = " + jobseekerId);
// Load name into session if not present
if(currentSession.getAttribute("jfirstname") == null) {
    Connection conName2 = DBConnection.getConnection();
    PreparedStatement psName2 = conName2.prepareStatement(
        "SELECT jfirstname, jlastname FROM jobseeker WHERE jid=?"
    );
    psName2.setInt(1, jobseekerId);
    ResultSet rsName2 = psName2.executeQuery();
    if(rsName2.next()) {
        currentSession.setAttribute("jfirstname", rsName2.getString("jfirstname"));
        currentSession.setAttribute("jlastname",  rsName2.getString("jlastname"));
    }
    rsName2.close(); psName2.close(); conName2.close();
}

Connection con = DBConnection.getConnection();

/* 🔹 Check if already placed bid */
String checkBid = "SELECT bid_status,bid_amount FROM bids WHERE job_id=? AND job_seeker_id=?";
PreparedStatement psCheck = con.prepareStatement(checkBid);
psCheck.setInt(1, jobId);
psCheck.setInt(2, jobseekerId);
ResultSet rsCheck = psCheck.executeQuery();

boolean alreadyBid = false;
String bidStatus = "";
int bidAmount = 0;

if(rsCheck.next()){
    alreadyBid = true;
    bidStatus = rsCheck.getString("bid_status");
    bidAmount = rsCheck.getInt("bid_amount");
}

/* 🔹 Fetch Job Details */
String query = "SELECT * FROM jobs WHERE job_id=?";
PreparedStatement ps = con.prepareStatement(query);
ps.setInt(1, jobId);
ResultSet rs = ps.executeQuery();

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Details | SkillMitra</title>
<link rel="stylesheet" href="job_details.css">
</head>

<body>

<div class="navbar">
  <div style="display:flex; align-items:center; gap:12px;">
    <img src="skillmitralogo.jpg" alt="Logo" style="width:35px; height:35px; border-radius:50%; object-fit:cover;">
    <div class="nav-left">SkillMitra</div>
  </div>
  <div class="profile-dropdown">
    <%
    String srPhoto = (String) currentSession.getAttribute("jphoto");
    String srImg = (srPhoto != null && !srPhoto.trim().isEmpty())
                   ? "uploads/" + srPhoto
                   : "images/default-user.png";
    %>
    <img src="<%= srImg %>" class="profile-icon" id="profileIcon"
         style="width:38px; height:38px; border-radius:50%; border:2px solid white; cursor:pointer;">
    <div class="profile-menu" id="profileMenu"
         style="display:none; position:absolute; right:0; top:55px;
                background:#fff; width:200px; border-radius:10px;
                box-shadow:0 8px 25px rgba(0,0,0,0.15); z-index:999;">
      <%
String displayName = "";
Connection conDisplayName = DBConnection.getConnection();
PreparedStatement psDisplayName = conDisplayName.prepareStatement(
    "SELECT jfirstname, jlastname FROM jobseeker WHERE jid=?"
);
psDisplayName.setInt(1, jobseekerId);
ResultSet rsDisplayName = psDisplayName.executeQuery();
if(rsDisplayName.next()){
    displayName = rsDisplayName.getString("jfirstname") + " " + rsDisplayName.getString("jlastname");
}
rsDisplayName.close(); psDisplayName.close(); conDisplayName.close();
%>
<div style="padding:12px 14px; font-weight:600; border-bottom:1px solid #eee; 
            color:#1a2a3a; font-size:15px; background:#f9fafb;">
    <%= displayName != null && !displayName.trim().isEmpty() ? displayName : "User" %>
</div>
      <a href="jobseeker_profile.jsp" style="display:block; padding:10px 14px; color:#333; text-decoration:none;">View Profile</a>
      <a href="LogoutServlet" style="display:block; padding:10px 14px; color:#333; text-decoration:none;">Logout</a>
    </div>
  </div>
</div>

<div class="back-bar">
    <a href="javascript:history.back()">← Back to Results</a>
</div>

<%
if (rs.next()) {
    String jobType     = rs.getString("job_type");
    String location    = rs.getString("locality") + ", " + rs.getString("city");
    String fullLoc     = rs.getString("locality") + ", " + rs.getString("city") + ", "
                       + rs.getString("state") + ", " + rs.getString("country")
                       + " - " + rs.getString("zip");
    String salary      = rs.getString("salary");
    String minSalary   = rs.getString("min_salary");
    String desc        = rs.getString("description");
    String expLvl      = rs.getString("experience_level");
    String expReq      = rs.getString("experience_required");
    String workers     = rs.getString("workers_required");
    String hours       = rs.getString("working_hours");
    String gender      = rs.getString("gender_preference");
    String languages   = rs.getString("languages_preferred");
    String title       = rs.getString("title");
%>

<div class="page-wrapper">

    <!-- LEFT COLUMN -->
    <div class="left-col">

        <!-- Header Card -->
        <div class="job-header-card">
            <div class="job-title"><%= title %></div>
            <div class="job-meta">
                <span class="meta-tag">
                    <svg width="14" height="14" fill="none" stroke="#6b7280" stroke-width="2"
                         viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/>
                         <circle cx="12" cy="10" r="3"/></svg>
                    <%= location %>
                </span>
                <span class="meta-tag">
                    <svg width="14" height="14" fill="none" stroke="#6b7280" stroke-width="2"
                         viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/>
                         <path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>
                    <%= jobType != null ? jobType : "Not specified" %>
                </span>
                <span class="meta-tag">
                    <svg width="14" height="14" fill="none" stroke="#6b7280" stroke-width="2"
                         viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/>
                         <path d="M12 6v6l4 2"/></svg>
                    <%= hours != null ? hours : "Not specified" %>
                </span>
            </div>
            <div class="salary-range">
                <span class="salary-min">₹<%= salary %></span>
                <span class="salary-divider">—</span>
                <span class="salary-max">₹<%= minSalary != null ? minSalary : "N/A" %> max</span>
            </div>
        </div>

        <!-- Details Card -->
        <div class="details-card">
            <h3>Job Details</h3>
            <div class="details-grid">

                <div class="detail-item" style="grid-column: span 2;">
                    <label>Description</label>
                    <p style="font-weight:400; color:#374151; line-height:1.7;">
                        <%= desc != null ? desc : "No description provided." %>
                    </p>
                </div>

                <div class="detail-item">
                    <label>Experience Required</label>
                    <p><%= expReq != null ? expReq : "Not specified" %></p>
                </div>

                <div class="detail-item">
                    <label>Experience Level</label>
                    <p><%= expLvl != null ? expLvl : "Not specified" %></p>
                </div>

                <div class="detail-item">
                    <label>Workers Required</label>
                    <p><%= workers != null ? workers : "Not specified" %></p>
                </div>

                <div class="detail-item">
                    <label>Gender Preference</label>
                    <p><%= gender != null ? gender : "Not specified" %></p>
                </div>

                <div class="detail-item">
                    <label>Languages Preferred</label>
                    <p><%= languages != null ? languages : "Not specified" %></p>
                </div>

                <div class="detail-item">
                    <label>Full Location</label>
                    <p><%= fullLoc %></p>
                </div>

            </div>
        </div>

    </div>

    <!-- RIGHT COLUMN -->
    <div class="right-col">

        <!-- Apply & Bid Card -->
        <div class="action-card">
            <h3>Apply for this Job</h3>

            <p style="font-size:13px; color:#6b7280; margin-bottom:14px; line-height:1.6;">
                You have two ways to apply. Choose one that suits you.
            </p>

            <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:8px;
                        padding:12px 14px; margin-bottom:12px;">
                <p style="font-size:12px; font-weight:700; color:#166534; 
                          text-transform:uppercase; letter-spacing:0.05em; margin-bottom:4px;">
                    Option 1 — Direct Apply
                </p>
                <p style="font-size:13px; color:#374151; margin-bottom:12px;">
                    Accept the posted salary of <strong>₹<%= salary %></strong> and apply directly.
                </p>
                <form action="ApplyJobServlet" method="post">
                    <input type="hidden" name="jobId" value="<%= jobId %>">
                    <button type="submit" class="apply-btn">Apply Now — ₹<%= salary %></button>
                </form>
            </div>

            <div style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:8px;
                        padding:12px 14px; margin-bottom:4px;">
                <p style="font-size:12px; font-weight:700; color:#1d4ed8;
                          text-transform:uppercase; letter-spacing:0.05em; margin-bottom:4px;">
                    Option 2 — Place a Bid
                </p>
                <p style="font-size:13px; color:#374151; margin-bottom:12px;">
                    Negotiate your own salary. Enter your expected amount and the employer will review it.
                </p>

            <% if(alreadyBid){ %>
            <div class="already-bid">
                Bid placed: ₹<%= bidAmount %> &nbsp;|&nbsp; <%= bidStatus %>
            </div>
            <% } else { %>
            <form action="PlaceBidServlet" method="post">
                <input type="hidden" name="jobId" value="<%= jobId %>">
                <label class="bid-label">Place Your Bid (₹)</label>
                <input type="number" name="bidAmount" required class="bid-input" placeholder="Enter your bid amount">
                <button type="submit" class="bid-btn">Place Bid</button>
            </form>
            <% } %>
        </div>

        <!-- Quick Info Card -->
        <div class="info-card">
            <h3>Quick Info</h3>
            <div class="info-row">
                <span>Job Type</span>
                <span><%= jobType != null ? jobType : "—" %></span>
            </div>
            <div class="info-row">
                <span>Experience</span>
                <span><%= expReq != null ? expReq : "—" %></span>
            </div>
            <div class="info-row">
                <span>Working Hours</span>
                <span><%= hours != null ? hours : "—" %></span>
            </div>
            <div class="info-row">
                <span>Workers Needed</span>
                <span><%= workers != null ? workers : "—" %></span>
            </div>
            <div class="info-row">
                <span>Gender</span>
                <span><%= gender != null ? gender : "—" %></span>
            </div>
            <div class="info-row">
                <span>Languages</span>
                <span><%= languages != null ? languages : "—" %></span>
            </div>
        </div>

    </div>

</div>

<% } else { %>
<div style="text-align:center; padding:60px; color:#999;">Job not found.</div>
<% } %>

<script>
document.getElementById("profileIcon").addEventListener("click", function(e){
    e.stopPropagation();
    var menu = document.getElementById("profileMenu");
    menu.style.display = menu.style.display === "block" ? "none" : "block";
});
document.addEventListener("click", function(){
    document.getElementById("profileMenu").style.display = "none";
});
</script>

</body>
</html>

<%

rsCheck.close();
psCheck.close();
rs.close();
ps.close();
con.close();

%>