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
    /* ===== ADDED: skill & subskill variables ===== */
    int skillId = 0, subskillId = 0;
    String skillName = "", subskillName = "";


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
           
            zip = rs.getString("jzip");
            education = rs.getString("jeducation");
            dob = rs.getString("jdob");

            
            session.setAttribute("jfirstname", fname);
            session.setAttribute("jlastname", lname);
            session.setAttribute("jemail", email);
        }
        /* ===== ADDED: fetch skill & subskill using mapping table ===== */
        PreparedStatement psSkill = con.prepareStatement(
            "SELECT s.skill_id, s.skill_name, ss.subskill_id, ss.subskill_name " +
            "FROM jobseeker_skills js " +
            "JOIN skill s ON js.skill_id = s.skill_id " +
            "JOIN subskill ss ON js.subskill_id = ss.subskill_id " +
            "WHERE js.jid=?"
        );
        psSkill.setInt(1, jid);
        ResultSet rsSkill = psSkill.executeQuery();

        if (rsSkill.next()) {
            skillId = rsSkill.getInt("skill_id");
            subskillId = rsSkill.getInt("subskill_id");
            skillName = rsSkill.getString("skill_name");
            subskillName = rsSkill.getString("subskill_name");
        }

       
        // Handle update form submission
        
        if ("update".equals(action)) {
            PreparedStatement psUpdate = con.prepareStatement(
                "UPDATE jobseeker SET jfirstname=?, jlastname=?, jphone=?, " +
                "jcountry=?, jstate=?,  jzip=?, jeducation=?, jdob=? " +
                "WHERE jid=?"
            );

            psUpdate.setString(1, request.getParameter("fname"));
            psUpdate.setString(2, request.getParameter("lname"));
            psUpdate.setString(3, request.getParameter("phone"));
            psUpdate.setString(4, request.getParameter("country"));
            psUpdate.setString(5, request.getParameter("state"));
            
            psUpdate.setString(6, request.getParameter("zip"));
            psUpdate.setString(7, request.getParameter("education"));
            psUpdate.setString(8, request.getParameter("dob"));
            psUpdate.setInt(9, jid);

            psUpdate.executeUpdate();
            
             /* ===== ADDED: update skill & subskill mapping ===== */
            PreparedStatement psUpdateSkill = con.prepareStatement(
                "UPDATE jobseeker_skills SET skill_id=?, subskill_id=? WHERE jid=?"
            );
            psUpdateSkill.setInt(1, Integer.parseInt(request.getParameter("skill")));
            psUpdateSkill.setInt(2, Integer.parseInt(request.getParameter("subskill")));
            psUpdateSkill.setInt(3, jid);
            psUpdateSkill.executeUpdate();

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
    
    <!-- ===== ADDED: display skill & subskill ===== -->
    <div class="row"><span class="label">Skill:</span> <%=skillName%></div>
    <div class="row"><span class="label">Subskill:</span> <%=subskillName%></div>

    
    <div class="row"><span class="label">State:</span> <%=state%></div>
    <div class="row"><span class="label">Country:</span> <%=country%></div>
    <div class="row"><span class="label">ZIP:</span> <%=zip%></div>
</div>
<% } %>

<%-- EDIT PROFILE --%>
<% if ("edit".equals(action)) { %>
<div class="box">
    <h2>Edit Profile</h2>

    <form method="post" action="jobseeker_profile.jsp?action=update">
        First Name: <input name="fname" value="<%=fname%>" required>
        Last Name: <input name="lname" value="<%=lname%>" required>
        Phone: <input name="phone" value="<%=phone%>">
        Education: <input name="education" value="<%=education%>">
        DOB: <input type="date" name="dob" value="<%=dob%>">

        <!-- ===== ADDED: skill dropdown (same as register) ===== -->
        Skill:
        <select name="skill" required onchange="loadSubskills()">
            <option value="">-- Select Skill --</option>
            <%
                Connection c2 = DBConnection.getConnection();
                PreparedStatement p2 = c2.prepareStatement(
                    "SELECT skill_id, skill_name FROM skill"
                );
                ResultSet r2 = p2.executeQuery();
                while (r2.next()) {
            %>
            <option value="<%=r2.getInt("skill_id")%>"
                <%= (r2.getInt("skill_id") == skillId ? "selected" : "") %>>
                <%=r2.getString("skill_name")%>
            </option>
            <% } c2.close(); %>
        </select>

        <!-- ===== ADDED: subskill dropdown ===== -->
        Subskill:
        <select name="subskill" id="subskill" required>
            <option value="<%=subskillId%>"><%=subskillName%></option>
        </select>

        
        State: <input name="state" value="<%=state%>">
        Country: <input name="country" value="<%=country%>">
        ZIP: <input name="zip" value="<%=zip%>">

        <br><br>
        <button class="btn" type="submit">Update</button>
        <a href="jobseeker_profile.jsp" class="btn">Cancel</a>
    </form>
</div>
<% } %>

<script>
function loadSubskills() {
    const skillId = document.querySelector("select[name='skill']").value;
    const sub = document.getElementById("subskill");
    sub.innerHTML = '<option value="">-- Select Subskill --</option>';

    fetch("<%=request.getContextPath()%>/GetSubskillsServlet?skillId=" + skillId)
        .then(res => res.json())
        .then(data => {
            data.forEach(s => {
                let opt = document.createElement("option");
                opt.value = s.id;
                opt.textContent = s.name;
                sub.appendChild(opt);
            });
        });
}
</script>

</body>
</html>