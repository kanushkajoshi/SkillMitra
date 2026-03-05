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

    if(session == null){
        response.sendRedirect("home.jsp");
        return;
    }

    String realOtp = (String) session.getAttribute("otp");
    String role    = (String) session.getAttribute("role");
    Long expiry    = (Long) session.getAttribute("otpExpiry");

    if(realOtp == null || role == null){
        response.sendRedirect("home.jsp");
        return;
    }

    // ✅ EXPIRY CHECK
    if(expiry == null || System.currentTimeMillis() > expiry){
        request.setAttribute("error","OTP expired. Please resend.");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request,response);
        return;
    }

    // ❌ WRONG OTP
    if(userOtp == null || !userOtp.equals(realOtp)){
        request.setAttribute("error","Wrong OTP!");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request,response);
        return;
    }

    try{
        Connection con = DBConnection.getConnection();

        // ================= EMPLOYER =================
        if("employer".equals(role)){

            PreparedStatement ps = con.prepareStatement(
            "INSERT INTO employer "+
            "(efirstname,elastname,eemail,epwd,ephone,"+
            "ecompanyname,ecompanywebsite,estate,ecountry,"+
            "ecity,edistrict,earea,ezip,email_verified) "+
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,1)",
            Statement.RETURN_GENERATED_KEYS);

            ps.setString(1,(String)session.getAttribute("firstname"));
            ps.setString(2,(String)session.getAttribute("lastname"));
            ps.setString(3,(String)session.getAttribute("email"));
            ps.setString(4,(String)session.getAttribute("password"));
            ps.setString(5,(String)session.getAttribute("phone"));
            ps.setString(6,(String)session.getAttribute("company"));
            ps.setString(7,(String)session.getAttribute("website"));
            ps.setString(8,(String)session.getAttribute("state"));
            ps.setString(9,(String)session.getAttribute("country"));
            ps.setString(10,(String)session.getAttribute("district"));
            ps.setString(11,(String)session.getAttribute("district"));
            ps.setString(12,(String)session.getAttribute("area"));
            ps.setString(13,(String)session.getAttribute("zip"));

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            rs.next();

            session.setAttribute("eid", rs.getInt(1));

            response.sendRedirect("emp_dash.jsp");
        }

        // ================= JOBSEEKER =================
        else{

            PreparedStatement ps = con.prepareStatement(
            "INSERT INTO jobseeker "+
            "(jfirstname,jlastname,jemail,jphone,jpwd,"+
            "jeducation,jcountry,jstate,jdistrict,"+
            "jarea,jzip,jdob,email_verified) "+
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,1)",
            Statement.RETURN_GENERATED_KEYS);

            ps.setString(1,(String)session.getAttribute("jfirstname"));
            ps.setString(2,(String)session.getAttribute("jlastname"));
            ps.setString(3,(String)session.getAttribute("jemail"));
            ps.setString(4,(String)session.getAttribute("jphone"));
            ps.setString(5,(String)session.getAttribute("jpwd"));
            ps.setString(6,(String)session.getAttribute("jeducation"));
            ps.setString(7,(String)session.getAttribute("jcountry"));
            ps.setString(8,(String)session.getAttribute("jstate"));
            ps.setString(9,(String)session.getAttribute("jdistrict"));
            ps.setString(10,(String)session.getAttribute("jarea"));
            ps.setString(11,(String)session.getAttribute("jzip"));

            String dob = (String)session.getAttribute("jdob");
            if(dob != null)
                ps.setDate(12, java.sql.Date.valueOf(dob));
            else
                ps.setNull(12, java.sql.Types.DATE);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            rs.next();

            int newJid = rs.getInt(1);
            session.setAttribute("jobseekerId", newJid);

            // 🔥🔥 ADD THIS BLOCK (SKILL INSERT) 🔥🔥
            String skill = (String) session.getAttribute("skill");
            String[] subskills = (String[]) session.getAttribute("subskills");

            if(skill != null && subskills != null){

                PreparedStatement psSkill = con.prepareStatement(
                "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");

                for(String sub : subskills){

                    psSkill.setInt(1, newJid);
                    psSkill.setInt(2, Integer.parseInt(skill));
                    psSkill.setInt(3, Integer.parseInt(sub));

                    psSkill.executeUpdate();
                }

                psSkill.close();
            }
            // 🔥🔥 END ADD

            response.sendRedirect("jobseeker_dash.jsp");
        }

        // CLEAN SESSION
        session.removeAttribute("otp");
        session.removeAttribute("otpExpiry");
        session.removeAttribute("role");

    }catch(Exception e){
        e.printStackTrace();
        request.setAttribute("error","Registration failed");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request,response);
    }
}
}