<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%

/* 🔒 Prevent browser caching */
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

/* 🔒 SESSION CHECK */
HttpSession currentSession = request.getSession(false);

if (currentSession == null || currentSession.getAttribute("eemail") == null) {
    response.sendRedirect("login.jsp");
    return;
}


String email = (String) session.getAttribute("eemail");
String action = request.getParameter("action");

String fname = "", lname = "", phone = "", company = "", website = "";
String state = "", country = "", zip = "", district = "", area = "";
String photo = "";

String errorMsg = "";

try {

    Class.forName("com.mysql.jdbc.Driver");

    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra",
            "root",
            ""
    );

    /* UPDATE PROFILE */
    if ("update".equals(action)) {

        String newFname = request.getParameter("fname");
        String newLname = request.getParameter("lname");
        String newPhone = request.getParameter("phone");
        String newZip = request.getParameter("zip");

        if (newFname == null || newFname.trim().equals("")) {
            errorMsg = "First name cannot be empty";
        }
        else if (newLname == null || newLname.trim().equals("")) {
            errorMsg = "Last name cannot be empty";
        }
        else if (newPhone == null || newPhone.trim().equals("")) {
            errorMsg = "Phone number cannot be empty";
        }
        else if (newZip == null || newZip.trim().equals("")) {
            errorMsg = "ZIP Code cannot be empty";
        }
        else {

            /* CHECK PHONE UNIQUE */
            PreparedStatement chk = con.prepareStatement(
                    "SELECT eid FROM employer WHERE ephone=? AND eemail<>?"
            );

            chk.setString(1, newPhone);
            chk.setString(2, email);

            ResultSet crs = chk.executeQuery();

            if (crs.next()) {
                errorMsg = "Phone number already exists";
            }
            else {

                PreparedStatement ups = con.prepareStatement(
                        "UPDATE employer SET "
                                + "efirstname=?, elastname=?, ephone=?, "
                                + "ecompanyname=?, ecompanywebsite=?, estate=?, "
                                + "ecountry=?, ezip=?, edistrict=?, earea=? "
                                + "WHERE eemail=?"
                );

                ups.setString(1, newFname);
                ups.setString(2, newLname);
                ups.setString(3, newPhone);
                ups.setString(4, request.getParameter("company"));
                ups.setString(5, request.getParameter("website"));
                ups.setString(6, request.getParameter("state"));
                ups.setString(7, request.getParameter("country"));
                ups.setString(8, newZip);
                ups.setString(9, request.getParameter("district"));
                ups.setString(10, request.getParameter("area"));
                ups.setString(11, email);

                ups.executeUpdate();

                session.setAttribute("efirstname", newFname);
                session.setAttribute("elastname", newLname);
                session.setAttribute("employerName", newFname + " " + newLname);

                response.sendRedirect("employer_profile.jsp");
                return;
            }
        }
    }

    /* FETCH PROFILE DATA */
    PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM employer WHERE eemail=?"
    );

    ps.setString(1, email);

    ResultSet rs = ps.executeQuery();

    if (rs.next()) {

        fname = rs.getString("efirstname");
        lname = rs.getString("elastname");
        phone = rs.getString("ephone");

        company = rs.getString("ecompanyname");
        website = rs.getString("ecompanywebsite");

        state = rs.getString("estate");
        country = rs.getString("ecountry");
        zip = rs.getString("ezip");

        district = rs.getString("edistrict");
        area = rs.getString("earea");

        photo = rs.getString("ephoto");
    }

    con.close();

} catch (Exception e) {
    out.println("DB ERROR: " + e);
}

String imgPath =
        (photo != null && !photo.trim().equals(""))
                ? request.getContextPath() + "/uploads/" + photo
                : request.getContextPath() + "/images/default-user.png";
%>

<!DOCTYPE html>
<html>

<head>

<title>Employer Profile | SkillMitra</title>

<style>

body{
    font-family: "Segoe UI", Arial, sans-serif;
    background:#f4f6f9;
}

/* PAGE HEADER */

.page-header{
    width:100%;
    padding:15px 40px 5px 40px;
}

/* BACK BUTTON */

.back-btn{

    display:inline-block;

    text-decoration:none;

    background:#4a6fa5;
    color:white;

    padding:8px 16px;

    border-radius:6px;

    font-size:14px;
    font-weight:500;

    transition:0.2s;

}

.back-btn:hover{
    background:#3a5a8c;
}

.back-btn:hover{

    background:#4a6fa5;
    color:white;

}
/* PROFILE CARD */

.profile-box{
    max-width:750px;
    margin:0 auto 40px auto;
    background:white;
    padding:35px;
    border-radius:10px;
    box-shadow:0 6px 25px rgba(0,0,0,0.08);
}

/* TITLE */

.profile-box h2{
    margin-bottom:25px;
    text-align:center;
}

/* PROFILE PHOTO */

.profile-photo{
    width:130px;
    height:130px;
    border-radius:50%;
    object-fit:cover;
    display:block;
    margin:0 auto 20px;
    border:4px solid #4a6fa5;
}

.profile-photo:hover{
    opacity:0.85;
    transform:scale(1.02);
    transition:0.2s;
}

/* GRID FORM LAYOUT */

.form-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:15px 20px;
}

/* FULL WIDTH FIELDS */

.full-width{
    grid-column:1 / 3;
}

/* LABELS */

label{
    font-weight:600;
    font-size:14px;
}

/* INPUTS */

input, select{

    width:100%;
    padding:10px;
    border:1px solid #ccc;
    border-radius:6px;

    font-size:14px;

}

/* FOCUS EFFECT */

input:focus, select:focus{

    outline:none;
    border-color:#4a6fa5;
    box-shadow:0 0 4px rgba(74,111,165,0.25);

}

/* BUTTONS */

.btn{
    background:#4a6fa5;
    color:white;
    padding:10px 20px;
    border:none;
    border-radius:6px;
    cursor:pointer;
    font-size:14px;
    text-decoration:none;
}

.btn:hover{
    background:#3a5a8c;
}

.btn.cancel{
    background:#888;
}

/* BUTTON GROUP */

.btn-group{
    margin-top:20px;
    display:flex;
    gap:10px;
}

/* PROFILE DETAILS VIEW */

.row{
    margin-bottom:10px;
}

.label{
    font-weight:bold;
}

/* ERROR MESSAGE */

.error{
    color:red;
    font-weight:bold;
    margin-bottom:10px;
}

</style>

</head>

<body>

<% if (action == null) { %>
<div class="page-header">
    <a href="emp_dash.jsp" class="back-btn">
        ← Back to Dashboard
    </a>
</div>
<div class="profile-box">

<div style="text-align:right">
    <a href="employer_profile.jsp?action=edit" class="btn">
        Edit Profile
    </a>
</div>

<img src="<%=imgPath%>" class="profile-photo">

<h2>Employer Profile</h2>

<div class="row">
<span class="label">Name:</span> <%=fname%> <%=lname%>
</div>

<div class="row">
<span class="label">Email:</span> <%=email%>
</div>

<div class="row">
<span class="label">Phone:</span> <%=phone%>
</div>

<hr>

<div class="row">
<span class="label">Company Name:</span> <%=company%>
</div>

<div class="row">
<span class="label">Company Website:</span> <%=website%>
</div>

<hr>

<div class="row">
<span class="label">State:</span> <%=state%>
</div>

<div class="row">
<span class="label">Country:</span> <%=country%>
</div>

<div class="row">
<span class="label">ZIP Code:</span> <%=zip%>
</div>

<div class="row">
<span class="label">District:</span> <%=district%>
</div>

<div class="row">
<span class="label">Area:</span> <%=area%>
</div>

</div>

<% } %>

<% if ("edit".equals(action)) { %>

<div class="profile-box">

<h2>Edit Profile</h2>

<% if (!errorMsg.equals("")) { %>
<div class="error"><%=errorMsg%></div>
<% } %>

<div style="text-align:center">

<form method="post"
      action="EmployerPhotoUploadServlet"
      enctype="multipart/form-data"
      id="photoForm">

<label for="photoUpload">

<img src="<%=imgPath%>" 
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

<hr>

<form method="post" action="employer_profile.jsp?action=update">

<div class="form-grid">

<div>
<label>First Name*</label>
<input type="text" name="fname" value="<%=fname%>" required>
</div>

<div>
<label>Last Name*</label>
<input type="text" name="lname" value="<%=lname%>" required>
</div>

<div>
<label>Email*</label>
<input type="email" value="<%=email%>" disabled>
</div>

<div>
<label>Phone*</label>
<input type="text" name="phone" value="<%=phone%>" required>
</div>

<div>
<label>Company</label>
<input type="text" name="company" value="<%=company%>">
</div>

<div>
<label>Website</label>
<input type="text" name="website" value="<%=website%>">
</div>

<div>
<label>ZIP*</label>
<input type="text"
       id="zip"
       name="zip"
       value="<%=zip%>"
       maxlength="6"
       required
       onkeyup="fetchLocation()">
</div>

<div>
<label>State*</label>
<input type="text" name="state" value="<%=state%>" readonly>
</div>

<div>
<label>District(City)*</label>
<input type="text"
       id="district"
       name="district"
       value="<%=district%>"
       readonly>
</div>
<div>
<label>Area*</label>
<select id="area" name="area" required>
<option value="<%=area%>" selected><%=area%></option>
</select>
</div>
<div class="full-width">
<label>Country*</label>
<input type="text" name="country" value="<%=country%>" readonly>
</div>

</div>

<div class="btn-group">
<button class="btn">Update</button>
<a href="employer_profile.jsp" class="btn cancel">Cancel</a>
</div>

</form>

</div>

<% } %>

<script>
function fetchLocation(){

    let pincode = document.getElementById("zip").value;

    if(pincode.length == 6){

        fetch("https://api.postalpincode.in/pincode/" + pincode)
        .then(response => response.json())
        .then(data => {

            if(data[0].Status === "Success"){

                let po = data[0].PostOffice;

                document.getElementById("district").value = po[0].District;
                document.getElementsByName("state")[0].value = po[0].State;
                document.getElementsByName("country")[0].value = po[0].Country;

                let areaSelect = document.getElementById("area");

                areaSelect.innerHTML = "";

                po.forEach(p => {

                    let opt = document.createElement("option");

                    opt.value = p.Name;
                    opt.textContent = p.Name;

                    areaSelect.appendChild(opt);

                });

            }
            else{

                document.getElementById("district").value = "";
                document.getElementsByName("state")[0].value = "";
                document.getElementsByName("country")[0].value = "";

                document.getElementById("area").innerHTML =
                    "<option value=''>Select area</option>";

                alert("Invalid PIN Code");

            }

        });

    }

}

</script>

</body>
</html>