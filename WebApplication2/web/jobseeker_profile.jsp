<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
/* Prevent browser caching */
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if(currentSession == null || currentSession.getAttribute("jobseekerId") == null){
    response.sendRedirect("login.jsp");
    return;
}

int jid = (Integer) currentSession.getAttribute("jobseekerId");
String action = request.getParameter("action");

/* VARIABLES */
String fname="", lname="", email="", phone="";
String country="", state="", district="", area="";
String zip="", education="", dob="", photo="";
int skillId = 0;
String skillName = "";

List selectedSubskills = new ArrayList();

try {
    Connection con = DBConnection.getConnection();

    /* FETCH PROFILE */
    PreparedStatement psSelect = con.prepareStatement(
        "SELECT * FROM jobseeker WHERE jid=?"
    );
    psSelect.setInt(1, jid);

    ResultSet rs = psSelect.executeQuery();

    if(rs.next()){
        fname = rs.getString("jfirstname");
        lname = rs.getString("jlastname");
        email = rs.getString("jemail");
        phone = rs.getString("jphone");
        country = rs.getString("jcountry");
        state = rs.getString("jstate");
        district = rs.getString("jdistrict");
        area = rs.getString("jarea");
        zip = rs.getString("jzip");
        education = rs.getString("jeducation");
        dob = rs.getString("jdob");
        photo = rs.getString("jphoto");
    }

    /* SKILL FETCH */
    PreparedStatement psSkill = con.prepareStatement(
        "SELECT skill_id, subskill_id FROM jobseeker_skills WHERE jid=?"
    );
    psSkill.setInt(1, jid);

    ResultSet rsSkill = psSkill.executeQuery();

    while(rsSkill.next()){
        skillId = rsSkill.getInt("skill_id");
        selectedSubskills.add(rsSkill.getInt("subskill_id"));
    }

    /* UPDATE */
    if("update".equals(action)){
        PreparedStatement psUpdate = con.prepareStatement(
            "UPDATE jobseeker SET " +
            "jfirstname=?, jlastname=?, jphone=?, " +
            "jcountry=?, jstate=?, jdistrict=?, jarea=?, " +
            "jzip=?, jeducation=?, jdob=? " +
            "WHERE jid=?"
        );

        psUpdate.setString(1, request.getParameter("fname"));
        psUpdate.setString(2, request.getParameter("lname"));
        psUpdate.setString(3, request.getParameter("phone"));
        psUpdate.setString(4, request.getParameter("country"));
        psUpdate.setString(5, request.getParameter("state"));
        psUpdate.setString(6, request.getParameter("district"));
        psUpdate.setString(7, request.getParameter("area"));
        psUpdate.setString(8, request.getParameter("zip"));
        psUpdate.setString(9, request.getParameter("education"));
        psUpdate.setString(10, request.getParameter("dob"));
        psUpdate.setInt(11, jid);

        psUpdate.executeUpdate();

        /* UPDATE SUBSKILLS */
        String skillParam = request.getParameter("skill");
        String[] subs = request.getParameterValues("subskills");

        PreparedStatement del = con.prepareStatement(
            "DELETE FROM jobseeker_skills WHERE jid=?"
        );
        del.setInt(1, jid);
        del.executeUpdate();

        if(skillParam != null && subs != null){
            PreparedStatement ins = con.prepareStatement(
                "INSERT INTO jobseeker_skills(jid,skill_id,subskill_id) VALUES(?,?,?)"
            );

            for(int i=0; i<subs.length; i++){
                ins.setInt(1, jid);
                ins.setInt(2, Integer.parseInt(skillParam));
                ins.setInt(3, Integer.parseInt(subs[i]));
                ins.executeUpdate();
            }
        }

        response.sendRedirect("jobseeker_profile.jsp");
        return;
    }

    con.close();

} catch(Exception e){
    out.println("ERROR: " + e);
}

/* ── RATING WIDGET DATA (jobseeker profile — rated by employers) ── */
double jsAvgRating  = 0;
int    jsTotalRating = 0;
try {
    Connection conRat = DBConnection.getConnection();
    PreparedStatement psRat = conRat.prepareStatement(
        "SELECT ROUND(AVG(rating_value),1) AS avg_r, COUNT(*) AS total " +
        "FROM ratings WHERE jobseeker_id=? AND rating_by='Employer'"
    );
    psRat.setInt(1, jid);
    ResultSet rsRat = psRat.executeQuery();
    if (rsRat.next()) {
        jsAvgRating   = rsRat.getDouble("avg_r");
        jsTotalRating = rsRat.getInt("total");
    }
    rsRat.close(); psRat.close();
    conRat.close();
} catch (Exception e) {
    // silently ignore — don't break profile page if ratings table missing
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Jobseeker Profile | SkillMitra</title>

<style>
body{
    font-family:"Segoe UI";
    background:#f4f6f9;
}
.page-header{ padding:15px 40px; }

.back-btn{
    background:#4a6fa5;
    color:white;
    padding:8px 16px;
    border-radius:6px;
    text-decoration:none;
}

.profile-box{
    max-width:750px;
    margin:0 auto 40px auto;
    background:white;
    padding:35px;
    border-radius:10px;
    box-shadow:0 6px 25px rgba(0,0,0,0.08);
}

.profile-photo{
    width:130px;
    height:130px;
    border-radius:50%;
    object-fit:cover;
    border:4px solid #4a6fa5;
    display:block;
    margin:0 auto 20px;
}

.row{ margin-bottom:10px; }
.label{ font-weight:bold; }

.btn{
    background:#4a6fa5;
    color:white;
    padding:10px 20px;
    border:none;
    border-radius:6px;
    cursor:pointer;
    text-decoration:none;
}

.form-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:15px 20px;
}

.full-width{ grid-column:1 / 3; }

input,select{
    width:100%;
    padding:10px;
    border:1px solid #ccc;
    border-radius:6px;
    box-sizing:border-box;
}

.dropdown-subskills{ position:relative; }

.dropdown-btn{
    width:100%;
    padding:10px;
    border:1px solid #ccc;
    border-radius:6px;
    background:white;
    cursor:pointer;
    text-align:left;
}

.dropdown-content{
    display:none;
    position:absolute;
    background:white;
    border:1px solid #ccc;
    border-radius:6px;
    max-height:220px;
    overflow-y:auto;
    width:100%;
    z-index:10;
    padding:10px;
    box-shadow:0 4px 12px rgba(0,0,0,0.1);
}

.dropdown-content label{
    display:block;
    margin-bottom:5px;
    cursor:pointer;
}

/* ── OK button inside dropdown ── */
.dropdown-ok-wrap{
    text-align:right;
    margin-top:8px;
    padding-top:8px;
    border-top:1px solid #eee;
    position:sticky;
    bottom:0;
    background:white;
}

.dropdown-ok-btn{
    background:#4a6fa5;
    color:white;
    padding:5px 18px;
    border:none;
    border-radius:5px;
    cursor:pointer;
    font-size:13px;
}

.dropdown-ok-btn:hover{
    background:#3a5f95;
}

/* ── RATING WIDGET ── */
.rating-widget {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    background: #fffbeb;
    border: 1px solid #fde68a;
    border-radius: 12px;
    padding: 10px 18px;
    margin-top: 14px;
    margin-bottom: 6px;
}

.rating-widget .stars {
    font-size: 22px;
    line-height: 1;
    letter-spacing: 2px;
}

.rating-widget .star-filled  { color: #f59e0b; }
.rating-widget .star-half    { color: #f59e0b; opacity: .55; }
.rating-widget .star-empty   { color: #d1d5db; }

.rating-widget .rat-val {
    font-size: 20px;
    font-weight: 800;
    color: #92400e;
}

.rating-widget .rat-meta {
    font-size: 13px;
    color: #9ca3af;
    margin-left: 4px;
}
</style>
</head>

<body>

<div class="page-header">
    <a href="jobseeker_dash.jsp" class="back-btn"> ← Back to Dashboard </a>
</div>

<% if(action == null){ %>

<div class="profile-box">

    <div style="text-align:right">
        <a href="jobseeker_profile.jsp?action=edit" class="btn"> Edit Profile </a>
    </div>

    <%
    String imgPath = "images/default-user.png";
    if(photo!=null && !photo.equals("")){
        imgPath = "uploads/" + photo;
    }
    %>

    <img src="<%=imgPath%>" class="profile-photo">

    <h2 style="text-align:center">Jobseeker Profile</h2>

    <%-- ── RATING WIDGET (view mode only) ──────────────────────────────── --%>
    <div style="text-align:center; margin-bottom:16px;">
        <div class="rating-widget">
            <div class="stars">
<%
if (jsTotalRating > 0) {
    for (int i = 1; i <= 5; i++) {
        if (i <= Math.floor(jsAvgRating)) {
            out.print("<span class='star-filled'>★</span>");
        } else if ((i - jsAvgRating) > 0 && (i - jsAvgRating) < 1) {
            out.print("<span class='star-half'>★</span>");
        } else {
            out.print("<span class='star-empty'>★</span>");
        }
    }
} else {
    out.print("<span class='star-empty'>★★★★★</span>");
}
%>
            </div>
            <div>
<% if (jsTotalRating > 0) { %>
                <span class="rat-val"><%= jsAvgRating %></span>
                <span style="font-size:13px;color:#78716c;">/5</span>
                <span class="rat-meta">(<%= jsTotalRating %> review<%= jsTotalRating != 1 ? "s" : "" %>)</span>
<% } else { %>
                <span class="rat-meta">No reviews yet</span>
<% } %>
            </div>
        </div>
    </div>
    <%-- ── END RATING WIDGET ──────────────────────────────────────────── --%>

    <div class="row"><span class="label">Name:</span> <%=fname%> <%=lname%></div>
    <div class="row"><span class="label">Email:</span> <%=email%></div>
    <div class="row"><span class="label">Phone:</span> <%=phone%></div>

    <hr>

    <div class="row">
        <span class="label">Education:</span>
        <%= (education==null || education.equals("")) ? "Not Added" : education %>
    </div>

    <div class="row">
        <span class="label">DOB:</span>
        <%= (dob==null || dob.equals("")) ? "Not Added" : dob %>
    </div>

    <hr>

    <div class="row">
        <span class="label">Skill:</span>

        <%
        Connection conSkill = DBConnection.getConnection();

        PreparedStatement psMainSkill = conSkill.prepareStatement(
            "SELECT s.skill_name " +
            "FROM jobseeker_skills js " +
            "JOIN skill s ON js.skill_id = s.skill_id " +
            "WHERE js.jid=? LIMIT 1"
        );

        psMainSkill.setInt(1, jid);

        ResultSet rsMainSkill = psMainSkill.executeQuery();

        if(rsMainSkill.next()){
            out.print(rsMainSkill.getString("skill_name"));
        } else {
            out.print("Not Added");
        }

        conSkill.close();
        %>
    </div>

    <div class="row">
        <span class="label">Subskills:</span>

        <%
        Connection con3 = DBConnection.getConnection();

        PreparedStatement psSub = con3.prepareStatement(
            "SELECT ss.subskill_name " +
            "FROM jobseeker_skills js " +
            "JOIN subskill ss ON js.subskill_id = ss.subskill_id " +
            "WHERE js.jid=?"
        );

        psSub.setInt(1, jid);

        ResultSet rsSub = psSub.executeQuery();

        boolean first = true;

        while(rsSub.next()){
            if(!first){
                out.print(", ");
            }
            out.print(rsSub.getString("subskill_name"));
            first = false;
        }

        con3.close();
        %>
    </div>

    <hr>

    <div class="row"><span class="label">District:</span> <%=district%></div>
    <div class="row"><span class="label">Area:</span> <%=area%></div>
    <div class="row"><span class="label">State:</span> <%=state%></div>
    <div class="row"><span class="label">Country:</span> <%=country%></div>
    <div class="row"><span class="label">ZIP:</span> <%=zip%></div>

</div>

<% } %>

<!-- EDIT MODE -->
<% if("edit".equals(action)){ %>

<div class="profile-box">

    <h2>Edit Profile</h2>

    <%
    String imgPath = "images/default-user.png";
    if(photo!=null && !photo.equals("")){
        imgPath = "uploads/" + photo;
    }
    %>

    <div style="text-align:center">

        <form method="post"
              action="JobseekerPhotoUploadServlet"
              enctype="multipart/form-data"
              id="photoForm">

            <label for="photoUpload">
                <img src="<%=request.getContextPath()%>/<%=imgPath%>"
                     class="profile-photo"
                     style="cursor:pointer"
                     title="Click to change photo">
            </label>

            <input type="file"
                   id="photoUpload"
                   name="photo"
                   accept="image/*"
                   style="display:none"
                   onchange="document.getElementById('photoForm').submit()">
        </form>

        <p style="font-size:13px;color:#777;margin-top:-10px;">
            Click photo to change
        </p>
    </div>

    <form method="post" action="UpdateJobseekerProfileServlet">

        <input type="hidden" name="action" value="update">

        <div class="form-grid">

            <div>
                <label>First Name</label>
                <input name="fname" value="<%=fname%>" required>
            </div>

            <div>
                <label>Last Name</label>
                <input name="lname" value="<%=lname%>" required>
            </div>

            <div>
                <label>Email</label>
                <input value="<%=email%>" readonly>
            </div>

            <div>
                <label>Phone</label>
                <input name="phone" value="<%=phone%>">
            </div>

            <!-- SKILL -->
            <div>
                <label>Skill</label>

                <select name="skill" id="skill" onchange="loadSubskills()">
                    <option value="">Select Skill</option>

                    <%
                    Connection c2 = DBConnection.getConnection();
                    PreparedStatement p2 = c2.prepareStatement(
                        "SELECT skill_id,skill_name FROM skill"
                    );
                    ResultSet r2 = p2.executeQuery();

                    while(r2.next()){
                    %>
                        <option value="<%=r2.getInt("skill_id")%>"
                            <%= r2.getInt("skill_id")==skillId ? "selected":"" %>>
                            <%=r2.getString("skill_name")%>
                        </option>
                    <%
                    }
                    c2.close();
                    %>
                </select>
            </div>

            <!-- SUBSKILLS -->
            <div>
                <label>Subskills</label>

                <div class="dropdown-subskills" id="subskill-wrapper">

                    <button type="button"
                            onclick="toggleSubskills()"
                            class="dropdown-btn"
                            id="subskill-toggle-btn">
                        Select Subskills ▾
                    </button>

                    <div id="subskill-container" class="dropdown-content">

                        <%
                        Connection con2 = DBConnection.getConnection();

                        PreparedStatement psub = con2.prepareStatement(
                            "SELECT subskill_id, subskill_name FROM subskill WHERE skill_id=?"
                        );

                        psub.setInt(1, skillId);

                        ResultSet rsub = psub.executeQuery();

                        while(rsub.next()){
                            int sid = rsub.getInt("subskill_id");
                            boolean checked = selectedSubskills.contains(sid);
                        %>

                        <label>
                            <input type="checkbox"
                                   name="subskills"
                                   value="<%=sid%>"
                                   <%= checked ? "checked":"" %>>
                            <%= rsub.getString("subskill_name") %>
                        </label>

                        <%
                        }
                        con2.close();
                        %>

                        <!-- ✅ FIX: OK button to close dropdown (server-rendered subskills) -->
                        <div class="dropdown-ok-wrap">
                            <button type="button"
                                    class="dropdown-ok-btn"
                                    onclick="closeSubskills()">
                                OK
                            </button>
                        </div>

                    </div>
                </div>
            </div>

            <div>
                <label>Education</label>
                <input name="education" value="<%=education%>">
            </div>

            <div>
                <label>Date of Birth</label>
                <input type="date" name="dob" value="<%=dob%>">
            </div>

            <div>
                <label>ZIP</label>
                <input name="zip"
                       id="zip"
                       value="<%=zip%>"
                       onkeyup="fetchLocation()">
            </div>

            <div>
                <label>District</label>
                <input name="district"
                       id="district"
                       value="<%=district%>"
                       readonly>
            </div>

            <div>
                <label>Area</label>
                <select name="area" id="area">
                    <option value="<%=area%>"><%=area%></option>
                </select>
            </div>

            <div>
                <label>State</label>
                <input name="state"
                       id="state"
                       value="<%=state%>"
                       readonly>
            </div>

            <div class="full-width">
                <label>Country</label>
                <input name="country"
                       id="country"
                       value="<%=country%>"
                       readonly>
            </div>

        </div>

        <br>

        <button class="btn">Update</button>
        <a href="jobseeker_profile.jsp" class="btn" style="margin-left:10px;">Cancel</a>

    </form>
</div>

<% } %>

<!-- JS -->
<script>

/* ── Toggle open/close ── */
function toggleSubskills(){
    const box = document.getElementById("subskill-container");
    box.style.display = (box.style.display === "block") ? "none" : "block";
}

/* ── Close only (used by OK button) ── */
function closeSubskills(){
    document.getElementById("subskill-container").style.display = "none";

    /* Update button label to show count of selected */
    const checked = document.querySelectorAll("#subskill-container input[type='checkbox']:checked");
    const btn = document.getElementById("subskill-toggle-btn");
    if(checked.length > 0){
        btn.textContent = checked.length + " subskill(s) selected ▾";
    } else {
        btn.textContent = "Select Subskills ▾";
    }
}

/* ── Load subskills dynamically when skill changes ── */
function loadSubskills(){
    const skillId = document.querySelector("select[name='skill']").value;
    const box = document.getElementById("subskill-container");

    box.innerHTML = "<p style='padding:6px;color:#888;font-size:13px;'>Loading...</p>";
    box.style.display = "block";

    fetch("<%=request.getContextPath()%>/GetSubskillsServlet?skillId=" + skillId)
        .then(res => res.json())
        .then(data => {
            box.innerHTML = "";

            if(data.length === 0){
                box.innerHTML = "<p style='padding:6px;color:#888;font-size:13px;'>No subskills found.</p>";
            } else {
                data.forEach(s => {
                    const label = document.createElement("label");
                    label.style.display = "block";
                    label.style.marginBottom = "5px";
                    label.style.cursor = "pointer";
                    label.innerHTML =
                        '<input type="checkbox" name="subskills" value="' + s.id + '"> ' + s.name;
                    box.appendChild(label);
                });
            }

            /* ✅ FIX: Re-add OK button after dynamic load */
            const okWrap = document.createElement("div");
            okWrap.className = "dropdown-ok-wrap";
            okWrap.innerHTML =
                '<button type="button" class="dropdown-ok-btn" onclick="closeSubskills()">OK</button>';
            box.appendChild(okWrap);
        })
        .catch(err => {
            box.innerHTML = "<p style='padding:6px;color:red;font-size:13px;'>Error loading subskills.</p>";
        });
}

/* ── FIX: Close dropdown when clicking outside ── */
document.addEventListener("click", function(e){
    const wrapper = document.getElementById("subskill-wrapper");
    if(wrapper && !wrapper.contains(e.target)){
        document.getElementById("subskill-container").style.display = "none";
    }
});

/* ── ZIP / Pincode auto-fill ── */
function fetchLocation(){
    let pincode = document.getElementById("zip").value;

    if(pincode.length === 6){
        fetch("https://api.postalpincode.in/pincode/" + pincode)
            .then(res => res.json())
            .then(data => {

                if(data[0].Status === "Success"){

                    let po = data[0].PostOffice;

                    document.getElementById("district").value = po[0].District;
                    document.getElementById("state").value    = po[0].State;
                    document.getElementById("country").value  = po[0].Country;

                    let areaSelect = document.getElementById("area");
                    areaSelect.innerHTML = "";

                    po.forEach(p => {
                        let opt = document.createElement("option");
                        opt.value       = p.Name;
                        opt.textContent = p.Name;
                        areaSelect.appendChild(opt);
                    });

                } else {
                    alert("Invalid Pincode");
                }
            });
    }
}

</script>

</body>
</html>
