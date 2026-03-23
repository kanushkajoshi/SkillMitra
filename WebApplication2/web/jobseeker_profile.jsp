<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%

response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

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
String gender = "";   // ✅ NEW

int skillId = 0;
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

gender = rs.getString("jgender"); // ✅ NEW
}

/* SKILLS */
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
"jzip=?, jeducation=?, jdob=?, jgender=? "+   // ✅ UPDATED
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
psUpdate.setString(11,request.getParameter("gender")); // ✅ NEW
psUpdate.setInt(12,jid);

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
</head>

<body>

<div class="page-header">
<a href="jobseeker_dash.jsp" class="back-btn">← Back to Dashboard</a>
</div>

<% if(action == null){ %>

<div class="profile-box">

<div style="text-align:right">
<a href="jobseeker_profile.jsp?action=edit" class="btn">Edit Profile</a>
</div>

<h2 style="text-align:center">Jobseeker Profile</h2>

<div class="row"><span class="label">Name:</span> <%=fname%> <%=lname%></div>
<div class="row"><span class="label">Email:</span> <%=email%></div>
<div class="row"><span class="label">Phone:</span> <%=phone%></div>

<div class="row"><span class="label">Gender:</span> <%=gender%></div> <!-- ✅ NEW -->

<hr>

<div class="row"><span class="label">Education:</span> <%=education%></div>
<div class="row"><span class="label">DOB:</span> <%=dob%></div>

</div>

<% } %>

<% if("edit".equals(action)){ %>

<div class="profile-box">

<h2>Edit Profile</h2>

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

<!-- ✅ GENDER ADDED -->
<div>
<label>Gender</label>
<select name="gender">
<option value="">Select</option>
<option value="Male" <%= "Male".equals(gender)?"selected":"" %>>Male</option>
<option value="Female" <%= "Female".equals(gender)?"selected":"" %>>Female</option>
</select>
</div>

<div>
<label>Education</label>
<input name="education" value="<%=education%>">
</div>

<div>
<label>Date of Birth</label>
<input type="date" name="dob" value="<%=dob%>">
</div>

</div>

<br>

<button class="btn">Update</button>
<a href="jobseeker_profile.jsp" class="btn">Cancel</a>

</form>

</div>

<% } %>

</body>
</html>