package servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.time.LocalDate;
import java.time.Period;

// DB IMPORTS
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import db.DBConnection;

@WebServlet("/EmployerRegisterServlet")
public class EmployerRegisterServlet extends HttpServlet {

    // ✅ NEW: AJAX EMAIL CHECK (ADDED ONLY THIS)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = request.getParameter("email");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM employer WHERE eemail=?"
            );
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                response.getWriter().write("exists");
            } else {
                response.getWriter().write("notexists");
            }

            rs.close();
            ps.close();
            con.close();

        } catch(Exception e){
            e.printStackTrace();
        }
    }

    // ================= EXISTING CODE (UNCHANGED) =================
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws IOException, ServletException {

        HttpSession session = request.getSession();

        String firstname = request.getParameter("efirstname");
        String lastname  = request.getParameter("elastname");
        String company   = request.getParameter("ecompanyname");

        String email     = request.getParameter("email");

        String phone     = request.getParameter("ephone");
        String password  = request.getParameter("epwd");

        String website   = request.getParameter("companywebsite");
        String zip       = request.getParameter("zip");
        String country   = request.getParameter("country");
        String state     = request.getParameter("state");
        String district  = request.getParameter("district");
        String area      = request.getParameter("area");

        String dob       = request.getParameter("edob");

        if(firstname == null || !firstname.matches("^[A-Za-z ]+$")){
            request.setAttribute("error", "First name must contain only alphabets.");
            request.getRequestDispatcher("employee_register.jsp").forward(request, response);
            return;
        }

        if(lastname == null || !lastname.matches("^[A-Za-z ]+$")){
            request.setAttribute("error", "Last name must contain only alphabets.");
            request.getRequestDispatcher("employee_register.jsp").forward(request, response);
            return;
        }

        try {
            LocalDate birthDate = LocalDate.parse(dob);
            int age = Period.between(birthDate, LocalDate.now()).getYears();

            if(age < 18){
                request.setAttribute("dobError", "You must be at least 18 years old.");
                request.getRequestDispatcher("employee_register.jsp").forward(request, response);
                return;
            }

        } catch(Exception e){
            request.setAttribute("dobError", "Invalid Date of Birth.");
            request.getRequestDispatcher("employee_register.jsp").forward(request, response);
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            ps = con.prepareStatement(
                "SELECT * FROM employer WHERE eemail=?"
            );

            ps.setString(1, email);

            rs = ps.executeQuery();

            if(rs.next()){
                request.setAttribute("emailError", "Email already registered.");
                request.setAttribute("oldEmail", email);

                request.getRequestDispatcher("employee_register.jsp")
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

        String otp = String.valueOf((int)(Math.random()*900000) + 100000);
        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000);

        session.setAttribute("otp", otp);
        session.setAttribute("otpExpiry", expiryTime);
        session.setAttribute("role", "employer");
        session.setAttribute("userEmail", email);
        
        session.setAttribute("efirstname", firstname);
        session.setAttribute("elastname", lastname);
        session.setAttribute("ecompanyname", company);
        session.setAttribute("eemail", email);
        session.setAttribute("ephone", phone);
        String hashed = org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt());
        session.setAttribute("epwd", hashed);

        session.setAttribute("ecompanywebsite", website);
        session.setAttribute("ezip", zip);
        session.setAttribute("ecountry", country);
        session.setAttribute("estate", state);
        session.setAttribute("edistrict", district);
        session.setAttribute("earea", area);

        session.setAttribute("edob", dob);

        Map<String,String[]> formData = new HashMap<>();
        request.getParameterMap().forEach((k,v)->formData.put(k,v));
        session.setAttribute("regData", formData);

        System.out.println("EMPLOYER OTP = " + otp);

        EmailUtility.sendOTP(email, otp);

        response.sendRedirect("verify_otp.jsp");
    }
}