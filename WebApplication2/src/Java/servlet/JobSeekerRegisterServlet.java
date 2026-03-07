package servlet;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/JobSeekerRegisterServlet")
public class JobSeekerRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        HttpSession session = request.getSession();

        // ===== GET FORM DATA =====
        String firstname  = request.getParameter("jfirstname");
        String lastname   = request.getParameter("jlastname");
        String email      = request.getParameter("jemail");
        String phone      = request.getParameter("jphone");
        String password   = request.getParameter("jpwd");
        String education  = request.getParameter("jeducation");
        String country    = request.getParameter("jcountry");
        String state      = request.getParameter("jstate");
        String district   = request.getParameter("jdistrict");
        String area       = request.getParameter("jarea");
        String zip        = request.getParameter("jzip");
        String dob        = request.getParameter("jdob");

        // ===== SAVE DATA IN SESSION =====
        session.setAttribute("jfirstname", firstname);
        session.setAttribute("jlastname", lastname);
        session.setAttribute("jemail", email);
        session.setAttribute("jphone", phone);
        session.setAttribute("jpwd", password);
        session.setAttribute("jeducation", education);
        session.setAttribute("jcountry", country);
        session.setAttribute("jstate", state);
        session.setAttribute("jdistrict", district);
        session.setAttribute("jarea", area);
        session.setAttribute("jzip", zip);
        session.setAttribute("jdob", dob);

        // ===== SKILLS =====
        String skill = request.getParameter("skill");
        String[] subskills = request.getParameterValues("subskills");

        session.setAttribute("skill", skill);
        session.setAttribute("subskills", subskills);

        // ===== OTP GENERATION =====
        String otp = String.valueOf((int)(Math.random()*900000)+100000);

        session.setAttribute("otp", otp);

        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 minutes
        session.setAttribute("otpExpiry", expiryTime);

        session.setAttribute("role", "jobseeker");

        System.out.println("OTP = " + otp);

        // Save entire form data
        session.setAttribute("regData", request.getParameterMap());

        // ===== SEND EMAIL OTP =====
        EmailUtility.sendOTP(email, otp);

        // ===== REDIRECT TO OTP PAGE =====
        response.sendRedirect("verify_otp.jsp?email=" + email);
    }
}