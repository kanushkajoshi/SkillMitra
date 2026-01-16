<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    /* SESSION CHECK */
    if (session.getAttribute("eemail") == null) 
    {
        response.sendRedirect("login.jsp");
        return;
    }

    /*  BASIC VARIABLES */
    String email = (String) session.getAttribute("eemail");
    String action = request.getParameter("action");

    String fname="", lname="", phone="", company="",
           website="", city="", state="", country="", zip="";
    String photo = "";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra", "root", "");

        /* UPDATE LOGIC */
        if ("update".equals(action)) {

            PreparedStatement ups = con.prepareStatement(
                "UPDATE employer SET  efirstname=?, elastname=?, ephone=?, " +
                "ecompanyname=?, ecompanywebsite=?, ecity=?, estate=?, ecountry=?, ezip=? " +
                "WHERE eemail=?");

            ups.setString(1, request.getParameter("fname"));
            ups.setString(2, request.getParameter("lname"));
            ups.setString(3, request.getParameter("phone"));
            ups.setString(4, request.getParameter("company"));
            ups.setString(5, request.getParameter("website"));
            ups.setString(6, request.getParameter("city"));
            ups.setString(7, request.getParameter("state"));
            ups.setString(8, request.getParameter("country"));
            ups.setString(9, request.getParameter("zip"));
            ups.setString(10, email);

            ups.executeUpdate();
            response.sendRedirect("employer_profile.jsp");
            return;
        }

        /* FETCH DATA */
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM employer WHERE eemail=?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            fname = rs.getString("efirstname");
            lname = rs.getString("elastname");
            phone = rs.getString("ephone");
            company = rs.getString("ecompanyname");
            website = rs.getString("ecompanywebsite");
            city = rs.getString("ecity");
            state = rs.getString("estate");
            country = rs.getString("ecountry");
            zip = rs.getString("ezip");
            photo = rs.getString("ephoto");

        }

        con.close();
    } catch (Exception e) {
        out.println("DB ERROR: " + e);
    }
    String imgPath = (photo != null && !photo.trim().equals(""))
        ? request.getContextPath() + "/uploads/" + photo
        : request.getContextPath() + "/images/default-user.png";
%>




<!DOCTYPE html>
<html>
<head>
    <title>Employer Profile | SkillMitra</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
        }
        .profile-box {
            
            width: 60%;
            margin: 40px auto;
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0px 0px 10px #ccc;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        .row {
            margin: 10px 0;
        }
        .label {
            font-weight: bold;
            color: #555;
        }
        .profile-photo {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid #4a6fa5;
    display: block;
    margin: 0 auto 15px;
}

.photo-upload {
    text-align: center;
    margin-bottom: 20px;
}

input[type="file"] {
    border: 1px solid #ccc;
    padding: 6px;
    width: 100%;
}

.profile-box, .box {
    box-shadow: 0 12px 30px rgba(0,0,0,0.12);
}

        /*for view+edit*/
        body{font-family:Arial;background:#f5f5f5;}
        .box{width:60%;margin:40px auto;background:white;
             padding:25px;border-radius:8px;}
        .row{margin:10px 0;}
        .label{font-weight:bold;}
        input{width:100%;padding:8px;}
        .btn{background:#4a6fa5;color:white;
             padding:8px 15px;border-radius:5px;
             text-decoration:none;border:none;}
    </style>
</head>

<body>

    <!--  VIEW PROFILE  -->
    <% if (action == null) { %>

    <div class="profile-box">
        <div style="text-align:left;margin-bottom:10px;">
    <a href="emp_dash.jsp" style="
    position:absolute;
    left:20px;
    top:20px;
    text-decoration:none;
    font-size:18px;
    color:#4a6fa5;">
    ← Back
</a>

</div>


        <div style="text-align:right">
            <a href="employer_profile.jsp?action=edit" class="btn">Edit Profile</a>
        </div>
        <img src="<%= imgPath %>" 
     style="width:120px;height:120px;
            border-radius:50%;
            display:block;
            margin:0 auto 15px;
            border:3px solid #4a6fa5;">


        <h2>Employer Profile</h2>

        <div class="row"><span class="label">Name:</span> <%= fname %> <%= lname %></div>
        <div class="row"><span class="label">Email:</span> <%= email %></div>
        <div class="row"><span class="label">Phone:</span> <%= phone %></div>

        <hr>

        <div class="row"><span class="label">Company Name:</span> <%= company %></div>
        <div class="row"><span class="label">Company Website:</span> <%= website %></div>

        <hr>

        <div class="row"><span class="label">City:</span> <%= city %></div>
        <div class="row"><span class="label">State:</span> <%= state %></div>
        <div class="row"><span class="label">Country:</span> <%= country %></div>
        <div class="row"><span class="label">ZIP Code:</span> <%= zip %></div>
    </div>
    <% } %>

    <!-- EDIT PROFILE  -->
    <% if ("edit".equals(action)) { %>

    <div class="box">
    <h2>Edit Profile</h2>


    <form method="post" action="EmployerPhotoUploadServlet" enctype="multipart/form-data">
   <div style="text-align:center;margin-bottom:15px;">
    <img src="<%= imgPath %>"
         style="width:120px;height:120px;
                border-radius:50%;
                border:3px solid #4a6fa5;
                margin-bottom:10px;">
    <input type="file" name="photo" accept="image/*">
</div>


    First Name:
    <input type="text" name="fname" value="<%=fname%>" required>

    Last Name:
    <input type="text" name="lname" value="<%=lname%>" required>

    Email:
    <input type="email" value="<%=email%>" disabled>

    Phone:
    <input type="text" name="phone" value="<%=phone%>">

    Company:
    <input type="text" name="company" value="<%=company%>">

    Website:
    <input type="text" name="website" value="<%=website%>">

    City:
    <input type="text" name="city" value="<%=city%>">

    State:
    <input type="text" name="state" value="<%=state%>">

    Country:
    <input type="text" name="country" value="<%=country%>">

    ZIP:
    <input type="text" name="zip" value="<%=zip%>">

    <br><br>
    <button class="btn">Update</button>
    <a href="employer_profile.jsp" class="btn">Cancel</a>

    </form>
    </div>

    <% } %>






</body>
</html>

