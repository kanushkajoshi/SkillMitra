<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Session check
    if (session.getAttribute("eemail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String email = (String) session.getAttribute("eemail");

    String fname = "", lname = "", phone = "", company = "",
           website = "", city = "", state = "", country = "", zip = "";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/skillmitra", "root", "");

        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM employer WHERE eemail = ?");
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
        }

        con.close();
    } catch (Exception e) {
        out.println("DB ERROR"+e);
    }
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
    </style>
</head>

<body>

<div class="profile-box">
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

</body>
</html>

