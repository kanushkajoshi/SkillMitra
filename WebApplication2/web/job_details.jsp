<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
int jobId = Integer.parseInt(request.getParameter("jobId"));

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

/* Check if already placed bid */
PreparedStatement psCheck = con.prepareStatement(
    "SELECT bid_status, bid_amount FROM bids WHERE job_id=? AND job_seeker_id=?"
);
psCheck.setInt(1, jobId);
psCheck.setInt(2, jobseekerId);
ResultSet rsCheck = psCheck.executeQuery();

boolean alreadyBid = false;
String bidStatus = "";
int bidAmount = 0;
if(rsCheck.next()){
    alreadyBid  = true;
    bidStatus   = rsCheck.getString("bid_status");
    bidAmount   = rsCheck.getInt("bid_amount");
}

/* Fetch Job Details */
PreparedStatement ps = con.prepareStatement("SELECT * FROM jobs WHERE job_id=?");
ps.setInt(1, jobId);
ResultSet rs = ps.executeQuery();

/* Display name for header */
String displayName = "";
Connection conDN = DBConnection.getConnection();
PreparedStatement psDN = conDN.prepareStatement(
    "SELECT jfirstname, jlastname FROM jobseeker WHERE jid=?"
);
psDN.setInt(1, jobseekerId);
ResultSet rsDN = psDN.executeQuery();
if(rsDN.next())
    displayName = rsDN.getString("jfirstname") + " " + rsDN.getString("jlastname");
rsDN.close(); psDN.close(); conDN.close();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Details | SkillMitra</title>
<link rel="stylesheet" href="job_details.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* Quick Info stretched full width inside left col */
.quick-info-wide {
    background: #fff;
    border: 0.5px solid #e5e7eb;
    border-radius: 14px;
    padding: 22px 24px;
    margin-top: 16px;
}

.quick-info-wide h3 {
    font-size: 13px;
    font-weight: 700;
    color: #1a2a3a;
    margin: 0 0 16px;
    text-transform: uppercase;
    letter-spacing: 0.06em;
}

/* 3-column grid so 6 items fill the full width nicely */
.quick-info-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}

.quick-info-item {
    background: #f9fafb;
    border: 0.5px solid #e5e7eb;
    border-radius: 10px;
    padding: 12px 14px;
}

.qi-label {
    font-size: 11px;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    font-weight: 600;
    margin-bottom: 5px;
}

.qi-value {
    font-size: 14px;
    color: #1a2a3a;
    font-weight: 600;
}
</style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
  <div style="display:flex;align-items:center;gap:12px;">
    <img src="skillmitralogo.jpg" alt="Logo"
         style="width:35px;height:35px;border-radius:50%;object-fit:cover;">
    <div class="nav-left">SkillMitra</div>
  </div>
  <div class="profile-dropdown">
    <%
    String srPhoto = (String) currentSession.getAttribute("jphoto");
    String srImg = (srPhoto != null && !srPhoto.trim().isEmpty())
                   ? "uploads/" + srPhoto : "images/default-user.png";
    %>
    <img src="<%= srImg %>" class="profile-icon" id="profileIcon"
         style="width:38px;height:38px;border-radius:50%;border:2px solid white;cursor:pointer;">
    <div class="profile-menu" id="profileMenu"
         style="display:none;position:absolute;right:0;top:55px;
                background:#fff;width:200px;border-radius:10px;
                box-shadow:0 8px 25px rgba(0,0,0,0.15);z-index:999;">
      <div style="padding:12px 14px;font-weight:600;border-bottom:1px solid #eee;
                  color:#1a2a3a;font-size:15px;background:#f9fafb;">
          <%= displayName.trim().isEmpty() ? "User" : displayName %>
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
</div>

<div class="back-bar">
    <a href="javascript:history.back()">← Back to Results</a>
</div>

<%
if (rs.next()) {
    String jobType   = rs.getString("job_type");
    String location  = rs.getString("locality") + ", " + rs.getString("city");
    String fullLoc   = rs.getString("locality") + ", " + rs.getString("city") + ", "
                     + rs.getString("state") + ", " + rs.getString("country")
                     + " - " + rs.getString("zip");
    String salary    = rs.getString("salary");
    String minSalary = rs.getString("min_salary");
    String desc      = rs.getString("description");
    String expLvl    = rs.getString("experience_level");
    String expReq    = rs.getString("experience_required");
    String workers   = rs.getString("workers_required");
    String hours     = rs.getString("working_hours");
    String gender    = rs.getString("gender_preference");
    String languages = rs.getString("languages_preferred");
    String title     = rs.getString("title");
    int    postingEid = rs.getInt("eid");

    /* Declare ALL employer variables BEFORE try block */
    String empName    = "";
    String empCompany = "";
    String empPhoto2  = "";

    Connection conEmp2 = null;
    try {
        conEmp2 = DBConnection.getConnection();
        PreparedStatement psEmp2 = conEmp2.prepareStatement(
            "SELECT efirstname, elastname, ecompanyname, ephoto FROM employer WHERE eid=?"
        );
        psEmp2.setInt(1, postingEid);
        ResultSet rsEmp2 = psEmp2.executeQuery();
        if(rsEmp2.next()){
            empName    = rsEmp2.getString("efirstname") + " " + rsEmp2.getString("elastname");
            empCompany = rsEmp2.getString("ecompanyname");
            empPhoto2  = rsEmp2.getString("ephoto");
        }
        rsEmp2.close(); psEmp2.close();
    } catch(Exception ex){ ex.printStackTrace(); }
    finally { if(conEmp2!=null) try{conEmp2.close();}catch(Exception ig){} }

    String empImgPath2 = (empPhoto2 != null && !empPhoto2.trim().isEmpty())
        ? "uploads/" + empPhoto2 : "images/default-user.png";
    String empInitials2 = empName.trim().isEmpty() ? "?" :
        String.valueOf(empName.charAt(0)) +
        (empName.contains(" ") ? String.valueOf(empName.charAt(empName.indexOf(" ")+1)) : "");
%>

<div class="page-wrapper">

    <!-- ════════════ LEFT COLUMN ════════════ -->
    <div class="left-col">

        <!-- Job Header Card -->
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
                <span class="salary-max">
                    ₹<%= minSalary != null ? minSalary : "N/A" %> max
                </span>
            </div>
        </div>

        <!-- Job Details Card -->
        <div class="details-card">
            <h3>Job Details</h3>
            <div class="details-grid">
                <div class="detail-item" style="grid-column:span 2;">
                    <label>Description</label>
                    <p style="font-weight:400;color:#374151;line-height:1.7;">
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

        <!-- ✅ Quick Info — now in LEFT col, full width, 3-column grid -->
        <div class="quick-info-wide">
            <h3>Quick Info</h3>
            <div class="quick-info-grid">
                <div class="quick-info-item">
                    <div class="qi-label">Job Type</div>
                    <div class="qi-value"><%= jobType != null ? jobType : "—" %></div>
                </div>
                <div class="quick-info-item">
                    <div class="qi-label">Experience</div>
                    <div class="qi-value"><%= expReq != null ? expReq : "—" %></div>
                </div>
                <div class="quick-info-item">
                    <div class="qi-label">Working Hours</div>
                    <div class="qi-value"><%= hours != null ? hours : "—" %></div>
                </div>
                <div class="quick-info-item">
                    <div class="qi-label">Workers Needed</div>
                    <div class="qi-value"><%= workers != null ? workers : "—" %></div>
                </div>
                <div class="quick-info-item">
                    <div class="qi-label">Gender</div>
                    <div class="qi-value"><%= gender != null ? gender : "—" %></div>
                </div>
                <div class="quick-info-item">
                    <div class="qi-label">Languages</div>
                    <div class="qi-value"><%= languages != null ? languages : "—" %></div>
                </div>
            </div>
        </div>

    </div>
    <!-- end left-col -->

    <!-- ════════════ RIGHT COLUMN ════════════ -->
    <div class="right-col">

        <!-- Posted By Card -->
        <div class="info-card" style="margin-bottom:14px;">
            <h3 style="margin-bottom:14px;">Posted By</h3>
            <div style="display:flex;align-items:center;gap:14px;margin-bottom:14px;">
                <% if(empPhoto2 != null && !empPhoto2.trim().isEmpty()){ %>
                    <img src="<%= empImgPath2 %>"
                         style="width:52px;height:52px;border-radius:50%;object-fit:cover;
                                border:2px solid #e5e7eb;flex-shrink:0;">
                <% } else { %>
                    <div style="width:52px;height:52px;border-radius:50%;background:#dbeafe;
                                color:#1d4ed8;display:flex;align-items:center;
                                justify-content:center;font-size:18px;font-weight:600;flex-shrink:0;">
                        <%= empInitials2 %>
                    </div>
                <% } %>
                <div>
                    <p style="font-weight:600;font-size:14px;color:#1a2a3a;margin:0 0 2px;">
                        <%= empName %>
                    </p>
                    <p style="font-size:12px;color:#6b7280;margin:0;">
                        <%= empCompany %>
                    </p>
                </div>
            </div>
            <a href="view_employer_profile.jsp?eid=<%= postingEid %>"
               style="display:block;text-align:center;background:#eff6ff;color:#1d4ed8;
                      padding:8px;border-radius:8px;font-size:13px;font-weight:600;
                      border:1px solid #bfdbfe;text-decoration:none;">
                <i class="fa-solid fa-eye" style="margin-right:4px;"></i>View Employer Profile
            </a>
        </div>

        <!-- Apply & Bid Card -->
        <div class="action-card">
            <h3>Apply for this Job</h3>
            <p style="font-size:13px;color:#6b7280;margin-bottom:14px;line-height:1.6;">
                You have two ways to apply. Choose one that suits you.
            </p>

            <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;
                        padding:12px 14px;margin-bottom:12px;">
                <p style="font-size:12px;font-weight:700;color:#166534;
                          text-transform:uppercase;letter-spacing:0.05em;margin-bottom:4px;">
                    Option 1 — Direct Apply
                </p>
                <p style="font-size:13px;color:#374151;margin-bottom:12px;">
                    Accept the posted salary of <strong>₹<%= salary %></strong> and apply directly.
                </p>
                <form action="ApplyJobServlet" method="post">
                    <input type="hidden" name="jobId" value="<%= jobId %>">
                    <button type="submit" class="apply-btn">Apply Now — ₹<%= salary %></button>
                </form>
            </div>

            <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;
                        padding:12px 14px;margin-bottom:4px;">
                <p style="font-size:12px;font-weight:700;color:#1d4ed8;
                          text-transform:uppercase;letter-spacing:0.05em;margin-bottom:4px;">
                    Option 2 — Place a Bid
                </p>
                <p style="font-size:13px;color:#374151;margin-bottom:12px;">
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
                    <input type="number" name="bidAmount" required class="bid-input"
                           placeholder="Enter your bid amount">
                    <button type="submit" class="bid-btn">Place Bid</button>
                </form>
                <% } %>
            </div>
        </div>
        <!-- Quick Info removed from right col -->

    </div>
    <!-- end right-col -->

</div>

<% } else { %>
<div style="text-align:center;padding:60px;color:#999;">Job not found.</div>
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
rsCheck.close(); psCheck.close();
rs.close(); ps.close();
con.close();
%>
