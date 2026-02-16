package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.Map;
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

    Map<String,String[]> data =
        (Map<String,String[]>) session.getAttribute("regData");

    // ===== SAFETY CHECK =====
    if(realOtp == null || role == null || data == null){
        response.sendRedirect(
            role!=null && role.equals("employer")
            ? "employer_register.jsp"
            : "jobseeker_register.jsp");
        return;
    }
    Long expiry =
    (Long) session.getAttribute("otpExpiry");

    if(expiry == null ||
       System.currentTimeMillis() > expiry){

        request.setAttribute("error",
            "OTP expired. Please resend.");

        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request,response);
        return;
    }

    // ===== WRONG OTP =====
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
            "edistrict,earea,ezip,email_verified) "+
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,1)",
            Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, get(data,"firstname"));
            ps.setString(2, get(data,"lastname"));
            ps.setString(3, get(data,"email"));
            ps.setString(4, get(data,"password"));
            ps.setString(5, get(data,"phone"));
            ps.setString(6, get(data,"companyname"));
            ps.setString(7, get(data,"companywebsite"));
            ps.setString(8, get(data,"state"));
            ps.setString(9, get(data,"country"));
            ps.setString(10,get(data,"district"));
            ps.setString(11,get(data,"area"));
            ps.setString(12,get(data,"zip"));

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

            ps.setString(1,get(data,"jfirstname"));
            ps.setString(2,get(data,"jlastname"));
            ps.setString(3,get(data,"jemail"));
            ps.setString(4,get(data,"jphone"));
            ps.setString(5,get(data,"jpwd"));
            ps.setString(6,get(data,"jeducation"));
            ps.setString(7,get(data,"jcountry"));
            ps.setString(8,get(data,"jstate"));
            ps.setString(9,get(data,"jdistrict"));
            ps.setString(10,get(data,"jarea"));
            ps.setString(11,get(data,"jzip"));

            String dob = get(data,"jdob");
            if(dob!=null)
                ps.setDate(12, java.sql.Date.valueOf(dob));
            else
                ps.setNull(12, java.sql.Types.DATE);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            rs.next();

            session.setAttribute("jobseekerId", rs.getInt(1));

            response.sendRedirect("jobseeker_dash.jsp");
        }

        // ===== CLEAN =====
        session.removeAttribute("otp");
        session.removeAttribute("regData");
        session.removeAttribute("role");

    }catch(Exception e){
        e.printStackTrace();
        request.setAttribute("error","Registration failed");
        request.getRequestDispatcher("verify_otp.jsp")
               .forward(request,response);
    }
}

// ===== SAFE GET METHOD =====
private String get(Map<String,String[]> data, String key){
    if(data.get(key)==null || data.get(key).length==0)
        return null;
    return data.get(key)[0];
}
}
