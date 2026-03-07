package servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EmployerRegisterServlet")
public class EmployerRegisterServlet extends HttpServlet {

protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
                      throws IOException, ServletException {

    HttpSession session = request.getSession();

    // Basic employer details
    String firstname = request.getParameter("efirstname");
    String lastname  = request.getParameter("elastname");
    String company   = request.getParameter("ecompanyname");
    String email     = request.getParameter("email");
    String phone     = request.getParameter("ephone");
    String password  = request.getParameter("epwd");

    // Additional employer details
    String website   = request.getParameter("companywebsite");
    String zip       = request.getParameter("zip");
    String country   = request.getParameter("country");
    String state     = request.getParameter("state");
    String district  = request.getParameter("district");
    String area      = request.getParameter("area");

    // Generate OTP
    String otp = String.valueOf((int)(Math.random()*900000) + 100000);

    long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000);

    session.setAttribute("otp", otp);
    session.setAttribute("otpExpiry", expiryTime);
    session.setAttribute("role", "employer");

    // Save employer data in session
    session.setAttribute("efirstname", firstname);
    session.setAttribute("elastname", lastname);
    session.setAttribute("ecompanyname", company);
    session.setAttribute("eemail", email);
    session.setAttribute("ephone", phone);
    session.setAttribute("epwd", password);

    // Save additional profile fields
    session.setAttribute("ecompanywebsite", website);
    session.setAttribute("ezip", zip);
    session.setAttribute("ecountry", country);
    session.setAttribute("estate", state);
    session.setAttribute("edistrict", district);
    session.setAttribute("earea", area);

    // Copy full form data (optional safety backup)
    Map<String,String[]> formData = new HashMap<>();
    request.getParameterMap().forEach((k,v)->formData.put(k,v));
    session.setAttribute("regData", formData);

    System.out.println("EMPLOYER OTP = " + otp);

    // Send OTP email
    EmailUtility.sendOTP(email, otp);

    response.sendRedirect("verify_otp.jsp");
}
}