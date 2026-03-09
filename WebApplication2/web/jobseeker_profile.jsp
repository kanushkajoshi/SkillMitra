<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%

/* 🔒 Prevent browser caching */
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

/* 🔒 SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if(currentSession == null || currentSession.getAttribute("jobseekerId") == null){
    response.sendRedirect("login.jsp");
    return;
}

int jid = (Integer) currentSession.getAttribute("jobseekerId");
String action = request.getParameter("action");

String fname="", lname="", email="", phone="";
String country="", state="", district="", area="";
String zip="", education="", dob="", photo="";

int skillId = 0;
String skillName = "";

List selectedSubskills = new ArrayList();

try {

Connection con = DBConnection.getConnection();

PreparedStatement psSelect =
con.prepareStatement("SELECT * FROM jobseeker WHERE jid=?");

psSelect.setInt(1,jid);

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

PreparedStatement psSkill =
con.prepareStatement(
"SELECT skill_id, subskill_id FROM jobseeker_skills WHERE jid=?"
);

psSkill.setInt(1,jid);

ResultSet rsSkill = psSkill.executeQuery();

while(rsSkill.next()){

skillId = rsSkill.getInt("skill_id");
selectedSubskills.add(rsSkill.getInt("subskill_id"));

}

/* UPDATE */

if("update".equals(action)){

PreparedStatement psUpdate =
con.prepareStatement(
"UPDATE jobseeker SET "+
"jfirstname=?, jlastname=?, jphone=?, "+
"jcountry=?, jstate=?, jdistrict=?, jarea=?, "+
"jzip=?, jeducation=?, jdob=? "+
"WHERE jid=?"
);

psUpdate.setString(1,request.getParameter("fname"));
psUpdate.setString(2,request.getParameter("lname"));
psUpdate.setString(3,request.getParameter("phone"));
psUpdate.setString(4,request.getParameter("country"));
psUpdate.setString(5,request.getParameter("state"));
psUpdate.setString(6,request.getParameter("district"));
psUpdate.setString(7,request.getParameter("area"));
psUpdate.setString(8,request.getParameter("zip"));
psUpdate.setString(9,request.getParameter("education"));
psUpdate.setString(10,request.getParameter("dob"));
psUpdate.setInt(11,jid);

psUpdate.executeUpdate();

/* UPDATE SUBSKILLS */

String skillParam = request.getParameter("skill");
String[] subs = request.getParameterValues("subskills");

PreparedStatement del =
con.prepareStatement("DELETE FROM jobseeker_skills WHERE jid=?");

del.setInt(1,jid);
del.executeUpdate();

if(skillParam!=null && subs!=null){

PreparedStatement ins =
con.prepareStatement(
"INSERT INTO jobseeker_skills(jid,skill_id,subskill_id) VALUES(?,?,?)"
);

for(int i=0;i<subs.length;i++){

ins.setInt(1,jid);
ins.setInt(2,Integer.parseInt(skillParam));
ins.setInt(3,Integer.parseInt(subs[i]));

ins.executeUpdate();

}

}

response.sendRedirect("jobseeker_profile.jsp");
return;

}

con.close();

}catch(Exception e){
out.println("ERROR: "+e);
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

.page-header{
padding:15px 40px;
}

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

.row{
margin-bottom:10px;
}

.label{
font-weight:bold;
}

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

.full-width{
grid-column:1 / 3;
}

input,select{
width:100%;
padding:10px;
border:1px solid #ccc;
border-radius:6px;
}
.dropdown-subskills{
position:relative;
}

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
max-height:200px;
overflow-y:auto;
width:100%;
z-index:10;
padding:10px;
}

.dropdown-content label{
display:block;
margin-bottom:5px;
}
</style>

</head>

<body>

<div class="page-header">
<a href="jobseeker_dash.jsp" class="back-btn">
← Back to Dashboard
</a>
</div>

<% if(action == null){ %>

<div class="profile-box">

<div style="text-align:right">
<a href="jobseeker_profile.jsp?action=edit" class="btn">
Edit Profile
</a>
</div>

<%

String imgPath = "images/default-user.png";

if(photo!=null && !photo.equals("")){
imgPath = "uploads/" + photo;
}

%>

<img src="<%=imgPath%>" class="profile-photo">

<h2 style="text-align:center">Jobseeker Profile</h2>

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

PreparedStatement psMainSkill =
conSkill.prepareStatement(
"SELECT s.skill_name " +
"FROM jobseeker_skills js " +
"JOIN skill s ON js.skill_id = s.skill_id " +
"WHERE js.jid=? LIMIT 1"
);

psMainSkill.setInt(1,jid);

ResultSet rsMainSkill = psMainSkill.executeQuery();

if(rsMainSkill.next()){
    out.print(rsMainSkill.getString("skill_name"));
}else{
    out.print("Not Added");
}

conSkill.close();
%>

</div>

<div class="row">
<span class="label">Subskills:</span>

<%

Connection con3 = DBConnection.getConnection();

PreparedStatement psSub =
con3.prepareStatement(
"SELECT ss.subskill_name "+
"FROM jobseeker_skills js "+
"JOIN subskill ss ON js.subskill_id = ss.subskill_id "+
"WHERE js.jid=?"
);

psSub.setInt(1,jid);

ResultSet rsSub = psSub.executeQuery();

boolean first=true;

while(rsSub.next()){

if(!first){
out.print(", ");
}

out.print(rsSub.getString("subskill_name"));

first=false;

}

con3.close();

%>
<hr>
</div>
<div class="row"><span class="label">District:</span> <%=district%></div>
<div class="row"><span class="label">Area:</span> <%=area%></div>
<div class="row"><span class="label">State:</span> <%=state%></div>
<div class="row"><span class="label">Country:</span> <%=country%></div>
<div class="row"><span class="label">ZIP:</span> <%=zip%></div>

</div>

<% } %>

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
<form method="post" action="jobseeker_profile.jsp">
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

<div>
<label>Skill</label>

<select name="skill" id="skill" onchange="loadSubskills()">

<option value="">Select Skill</option>

<%
Connection c2 = DBConnection.getConnection();

PreparedStatement p2 =
c2.prepareStatement("SELECT skill_id,skill_name FROM skill");

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


<div>

<label>Subskills</label>

<div class="dropdown-subskills">

<button type="button" onclick="toggleSubskills()" class="dropdown-btn">
Select Subskills
</button>

<div id="subskill-container" class="dropdown-content">

<%

Connection con2 = DBConnection.getConnection();

PreparedStatement psub =
con2.prepareStatement(
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

</div>

</div>

</div>
<div>
<label>ZIP</label>
<input name="zip" id="zip" value="<%=zip%>" onkeyup="fetchLocation()">
</div>

<div>
<label>District</label>
<input name="district" id="district" value="<%=district%>" readonly>
</div>

<div>
<label>Area</label>

<select name="area" id="area">
<option value="<%=area%>"><%=area%></option>
</select>

</div>

<div>
<label>State</label>
<input name="state" id="state" value="<%=state%>" readonly>
</div>

<div class="full-width">
<label>Country</label>
<input name="country" id="country" value="<%=country%>" readonly>
</div>

</div>

<br>

<button class="btn">Update</button>
<a href="jobseeker_profile.jsp" class="btn">Cancel</a>

</form>

</div>

<% } %>

<script>

function loadSubskills(){

const skillId =
document.querySelector("select[name='skill']").value;

const box =
document.getElementById("subskill-container");

box.innerHTML="Loading...";

fetch("<%=request.getContextPath()%>/GetSubskillsServlet?skillId="+skillId)

.then(res=>res.json())

.then(data=>{

box.innerHTML="";

data.forEach(s=>{

const label = document.createElement("label");

label.style.display="block";

label.innerHTML =
'<input type="checkbox" name="subskills" value="'+s.id+'"> '+s.name;

box.appendChild(label);

});

});

}


function toggleSubskills(){

const box = document.getElementById("subskill-container");

if(box.style.display === "block")
box.style.display = "none";
else
box.style.display = "block";

}
</script>

</body>
</html>