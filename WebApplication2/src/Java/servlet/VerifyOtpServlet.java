package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/VerifyOtpServlet")
public class VerifyOtpServlet extends HttpServlet {

protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
                      throws IOException, ServletException {

    String userOtp = request.getParameter("otp");

    HttpSession session = request.getSession(false);

    if (session == null) {
        response.sendRedirect("home.jsp");
        return;
    }

    String realOtp = (String) session.getAttribute("otp");
    String role    = (String) session.getAttribute("role");
    Long expiry    = (Long) session.getAttribute("otpExpiry");

    if (realOtp == null || role == null) {
        response.sendRedirect("home.jsp");
        return;
    }

    // OTP Expiry Check
    if (expiry == null || System.currentTimeMillis() > expiry) {
        request.setAttribute("error", "OTP expired. Please resend.");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request, response);
        return;
    }

    // Wrong OTP
    if (userOtp == null || !userOtp.equals(realOtp)) {
        request.setAttribute("error", "Wrong OTP!");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request, response);
        return;
    }

    try {

        Connection con = DBConnection.getConnection();

        /////////////////////////////////////////////////////
        ////////////// JOBSEEKER REGISTRATION ///////////////
        /////////////////////////////////////////////////////

        if ("jobseeker".equals(role)) {

            String email = (String) session.getAttribute("jemail");

            PreparedStatement check = con.prepareStatement(
                    "SELECT jid FROM jobseeker WHERE jemail=?"
            );

            check.setString(1, email);

            ResultSet rsCheck = check.executeQuery();

            if (rsCheck.next()) {
                int existingId = rsCheck.getInt("jid");
                session.setAttribute("jobseekerId", existingId);

                response.sendRedirect("jobseeker_dash.jsp");
                return;
            }

           PreparedStatement ps = con.prepareStatement(
"INSERT INTO jobseeker " +
"(jfirstname, jlastname, jemail, jphone, jpwd, " +
"jcountry, jstate, jdistrict, jarea, jzip, " +
"jeducation, jdob, email_verified) " +
"VALUES (?,?,?,?,?,?,?,?,?,?,?,?,1)",
Statement.RETURN_GENERATED_KEYS
);

String firstname = (String) session.getAttribute("jfirstname");
String lastname  = (String) session.getAttribute("jlastname");
String phone     = (String) session.getAttribute("jphone");
String password  = (String) session.getAttribute("jpwd");
String country   = (String) session.getAttribute("jcountry");
String state     = (String) session.getAttribute("jstate");
String district  = (String) session.getAttribute("jdistrict");
String area      = (String) session.getAttribute("jarea");
String zip       = (String) session.getAttribute("jzip");
String education = (String) session.getAttribute("jeducation");
String dob       = (String) session.getAttribute("jdob");

ps.setString(1, firstname);
ps.setString(2, lastname);
ps.setString(3, email);
ps.setString(4, phone);
ps.setString(5, password);
ps.setString(6, country);
ps.setString(7, state);
ps.setString(8, district);
ps.setString(9, area);
ps.setString(10, zip);
ps.setString(11, education);

if (dob != null && !dob.trim().isEmpty()) {
    ps.setDate(12, java.sql.Date.valueOf(dob));
} else {
    ps.setNull(12, java.sql.Types.DATE);
}

ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();

            int jid = 0;

            if (rs.next()) {
                jid = rs.getInt(1);
                session.setAttribute("jobseekerId", jid);
            }

            // Insert Skills
            String skill = (String) session.getAttribute("skill");
            String[] subskills = (String[]) session.getAttribute("subskills");

            if (skill != null && subskills != null && subskills.length > 0) {

                PreparedStatement psSkill = con.prepareStatement(
                    "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?,?,?)"
                );

                for (String sub : subskills) {

                    psSkill.setInt(1, jid);
                    psSkill.setInt(2, Integer.parseInt(skill));
                    psSkill.setInt(3, Integer.parseInt(sub));

                    psSkill.executeUpdate();
                }

                psSkill.close();
            }

            session.removeAttribute("otp");
            session.removeAttribute("otpExpiry");
            session.removeAttribute("role");

            response.sendRedirect("jobseeker_dash.jsp");
            return;
        }

        /////////////////////////////////////////////////////
        ////////////// EMPLOYER REGISTRATION ////////////////
        /////////////////////////////////////////////////////

        else if ("employer".equals(role)) {

            String email = (String) session.getAttribute("eemail");

            PreparedStatement check = con.prepareStatement(
                "SELECT eid FROM employer WHERE eemail=?"
            );

            check.setString(1, email);

            ResultSet rsCheck = check.executeQuery();

            if (rsCheck.next()) {
                int eid = rsCheck.getInt("eid");
                session.setAttribute("eid", eid);

                response.sendRedirect("emp_dash.jsp");
                return;
            }

            PreparedStatement ps = con.prepareStatement(
"INSERT INTO employer " +
"(efirstname, elastname, ecompanyname, eemail, ephone, epwd, " +
"ecompanywebsite, ezip, estate, ecountry, edistrict, earea, email_verified) " +
"VALUES (?,?,?,?,?,?,?,?,?,?,?,?,1)",
Statement.RETURN_GENERATED_KEYS
);

ps.setString(1, (String) session.getAttribute("efirstname"));
ps.setString(2, (String) session.getAttribute("elastname"));
ps.setString(3, (String) session.getAttribute("ecompanyname"));
ps.setString(4, email);
ps.setString(5, (String) session.getAttribute("ephone"));
ps.setString(6, (String) session.getAttribute("epwd"));

ps.setString(7, (String) session.getAttribute("ecompanywebsite"));
ps.setString(8, (String) session.getAttribute("ezip"));
ps.setString(9, (String) session.getAttribute("estate"));
ps.setString(10, (String) session.getAttribute("ecountry"));
ps.setString(11, (String) session.getAttribute("edistrict"));
ps.setString(12, (String) session.getAttribute("earea"));

ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();

            if (rs.next()) {
                session.setAttribute("eid", rs.getInt(1));
            }

            session.removeAttribute("otp");
            session.removeAttribute("otpExpiry");
            session.removeAttribute("role");

            response.sendRedirect("emp_dash.jsp");
            return;
        }

    } catch (Exception e) {

        e.printStackTrace();

        request.setAttribute("error", "Registration failed");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request, response);
    }
}

}