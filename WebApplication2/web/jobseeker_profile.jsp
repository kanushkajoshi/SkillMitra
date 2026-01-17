<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
   
    // Session check
    
    if (session.getAttribute("jobseekerId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int jid = (Integer) session.getAttribute("jobseekerId");
    String action = request.getParameter("action"); 

  
    String fname="", lname="", email="", phone="", country="", state="", city="",
           zip="", education="", dob="";

    try {
        Connection con = DBConnection.getConnection();

     
        // Fetch current profile
        
        PreparedStatement psSelect = con.prepareStatement(
            "SELECT * FROM jobseeker WHERE jid=?"
        );
        psSelect.setInt(1, jid);
        ResultSet rs = psSelect.executeQuery();

        if (rs.next()) {
            fname = rs.getString("jfirstname");
            lname = rs.getString("jlastname");
            email = rs.getString("jemail");
            phone = rs.getString("jphone");
            country = rs.getString("jcountry");
            state = rs.getString("jstate");
            city = rs.getString("jcity");
            zip = rs.getString("jzip");
            education = rs.getString("jeducation");
            dob = rs.getString("jdob");

            
            session.setAttribute("jfirstname", fname);
            session.setAttribute("jlastname", lname);
            session.setAttribute("jemail", email);
        }

       
        // Handle update form submission
        
        if ("update".equals(action)) {
            PreparedStatement psUpdate = con.prepareStatement(
                "UPDATE jobseeker SET jfirstname=?, jlastname=?, jphone=?, " +
                "jcountry=?, jstate=?, jcity=?, jzip=?, jeducation=?, jdob=? " +
                "WHERE jid=?"
            );

            psUpdate.setString(1, request.getParameter("fname"));
            psUpdate.setString(2, request.getParameter("lname"));
            psUpdate.setString(3, request.getParameter("phone"));
            psUpdate.setString(4, request.getParameter("country"));
            psUpdate.setString(5, request.getParameter("state"));
            psUpdate.setString(6, request.getParameter("city"));
            psUpdate.setString(7, request.getParameter("zip"));
            psUpdate.setString(8, request.getParameter("education"));
            psUpdate.setString(9, request.getParameter("dob"));
            psUpdate.setInt(10, jid);

            psUpdate.executeUpdate();

            // Update session 
            session.setAttribute("jfirstname", request.getParameter("fname"));
            session.setAttribute("jlastname", request.getParameter("lname"));

            response.sendRedirect("jobseeker_profile.jsp"); 
            return;
        }

        con.close();
    } catch(Exception e) {
        out.println("ERROR: " + e);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Jobseeker Profile | SkillMitra</title>
    <style>
        body { font-family: Arial; background:#f5f5f5; }
        .box { width:60%; margin:40px auto; background:white;
               padding:25px; border-radius:8px;
               box-shadow:0 12px 30px rgba(0,0,0,0.12); }
        .row { margin:10px 0; }
        .label { font-weight:bold; }
        input { width:100%; padding:8px; margin-top:4px; }
        .btn { background:#4a6fa5; color:white;
               padding:8px 15px; border:none;
               border-radius:5px; text-decoration:none; cursor:pointer; }
    </style>
</head>
<body>

<a href="jobseeker_dash.jsp" 
   style="text-decoration:none; color:black; font-weight:bold; font-size:16px; display:block; margin-bottom:10px;">
    &#8592; Back to Dashboard
</a>

<%-- ----------------------------
      VIEW PROFILE
      ---------------------------- --%>
<% if (action == null) { %>
<div class="box">
    <div style="text-align:right">
        <a href="jobseeker_profile.jsp?action=edit" class="btn">Edit Profile</a>
    </div>

    <h2>Jobseeker Profile</h2>

    <div class="row"><span class="label">Name:</span> <%=fname%> <%=lname%></div>
    <div class="row"><span class="label">Email:</span> <%=email%></div>
    <div class="row"><span class="label">Phone:</span> <%=phone%></div>
    <div class="row"><span class="label">Education:</span> <%=education%></div>
    <div class="row"><span class="label">DOB:</span> <%=dob%></div>
    <div class="row"><span class="label">City:</span> <%=city%></div>
    <div class="row"><span class="label">State:</span> <%=state%></div>
    <div class="row"><span class="label">Country:</span> <%=country%></div>
    <div class="row"><span class="label">ZIP:</span> <%=zip%></div>
</div>
<% } %>

<%-- ----------------------------
      EDIT PROFILE
      ---------------------------- --%>
<% if ("edit".equals(action)) { %>
<div class="box">
    <h2>Edit Profile</h2>

    <form method="post" action="jobseeker_profile.jsp?action=update">
        First Name: <input name="fname" value="<%=fname%>" required>
        Last Name: <input name="lname" value="<%=lname%>" required>
        Phone: <input name="phone" value="<%=phone%>">
        Education: <input name="education" value="<%=education%>">
        DOB: <input type="date" name="dob" value="<%=dob%>">
        City: <input name="city" value="<%=city%>">
        State: <input name="state" value="<%=state%>">
        Country: <input name="country" value="<%=country%>">
        ZIP: <input name="zip" value="<%=zip%>">

        <br><br>
        <button class="btn" type="submit">Update</button>
        <a href="jobseeker_profile.jsp" class="btn">Cancel</a>
    </form>
</div>
<% } %>

</body>
</html>
