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

    String email = request.getParameter("email");

    String otp = String.valueOf((int)(Math.random()*900000)+100000);
    

    session.setAttribute("otp", otp);
    long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 mins
    session.setAttribute("otpExpiry", expiryTime);

    // ✅ COPY PARAM MAP (VERY IMPORTANT)
    Map<String,String[]> formData = new HashMap<>();
    request.getParameterMap()
           .forEach((k,v)->formData.put(k,v));

    session.setAttribute("regData", formData);
    session.setAttribute("role","employer");
    session.setAttribute("otp", otp);
    session.setAttribute("city",
    request.getParameter("city"));

    System.out.println("EMPLOYER OTP = " + otp);

    EmailUtility.sendOTP(email, otp);

    response.sendRedirect("verify_otp.jsp");
}
}
