package servlet;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.time.LocalDate;
import java.time.Period;

// 🔥 ADD THESE IMPORTS
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import db.DBConnection;

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

        // ===== NEW: GENDER =====
        String gender = request.getParameter("jgender");

        // ===================================================
        // 🔥 NAME VALIDATION
        // ===================================================
        if(firstname == null || !firstname.matches("^[A-Za-z ]+$")){
            request.setAttribute("error", "First name must contain only alphabets.");
            request.getRequestDispatcher("jobseeker_register.jsp")
                   .forward(request, response);
            return;
        }

        if(lastname == null || !lastname.matches("^[A-Za-z ]+$")){
            request.setAttribute("error", "Last name must contain only alphabets.");
            request.getRequestDispatcher("jobseeker_register.jsp")
                   .forward(request, response);
            return;
        }

        // ===================================================
        // 🔥 DOB VALIDATION (18+)
        // ===================================================
        try {
            LocalDate birthDate = LocalDate.parse(dob);
            LocalDate today = LocalDate.now();

            int age = Period.between(birthDate, today).getYears();

            if(age < 18){
                request.setAttribute("dobError", "You must be at least 18 years old to register.");
                request.getRequestDispatcher("jobseeker_register.jsp")
                       .forward(request, response);
                return;
            }

        } catch (Exception e) {
            request.setAttribute("dobError", "Invalid Date of Birth.");
            request.getRequestDispatcher("jobseeker_register.jsp")
                   .forward(request, response);
            return;
        }

        // ===================================================
        // 🔥 EMAIL EXISTS CHECK (ADDED HERE)
        // ===================================================
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            ps = con.prepareStatement(
                "SELECT * FROM jobseeker WHERE jemail=?"
            );
            ps.setString(1, email);

            rs = ps.executeQuery();

            if(rs.next()){
                request.setAttribute("emailError", "Email already registered.");
                request.getRequestDispatcher("jobseeker_register.jsp")
                       .forward(request, response);
                return;
            }

        } catch(Exception e){
            e.printStackTrace();
        } finally {
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
                if(con != null) con.close();
            } catch(Exception e){
                e.printStackTrace();
            }
        }

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

        // ===== SAVE GENDER =====
        session.setAttribute("jgender", gender);

        // ===== SKILLS =====
        String skill = request.getParameter("skill");
        String[] subskills = request.getParameterValues("subskills");

        session.setAttribute("skill", skill);
        session.setAttribute("subskills", subskills);

        // ===== OTP GENERATION =====
        String otp = String.valueOf((int)(Math.random()*900000)+100000);

        session.setAttribute("otp", otp);

        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000);
        session.setAttribute("otpExpiry", expiryTime);

        session.setAttribute("role", "jobseeker");

        System.out.println("OTP = " + otp);

        // Save entire form data
        session.setAttribute("regData", request.getParameterMap());

        // ===== SEND EMAIL OTP =====
        EmailUtility.sendOTP(email, otp);

        // ===== REDIRECT =====
        response.sendRedirect("verify_otp.jsp?email=" + email);
    }
}