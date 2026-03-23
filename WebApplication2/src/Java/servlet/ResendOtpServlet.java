package servlet;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ResendOtpServlet")
public class ResendOtpServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("jobseeker_register.jsp");
            return;
        }

        // 🔥 DIRECT EMAIL FETCH (FIXED)
        String email = (String) session.getAttribute("userEmail");

        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect("jobseeker_register.jsp");
            return;
        }

        // 🔥 GENERATE NEW OTP
        String otp = String.valueOf((int)(Math.random() * 900000) + 100000);

        // SAVE OTP + RESET EXPIRY
        session.setAttribute("otp", otp);
        session.setAttribute("otpExpiry",
                System.currentTimeMillis() + (5 * 60 * 1000));

        System.out.println("NEW OTP = " + otp);

        try {
            EmailUtility.sendOTP(email, otp);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("verify_otp.jsp?error=mailfail");
            return;
        }

        // 🔥 REDIRECT BACK
        response.sendRedirect("verify_otp.jsp?email=" + email);
    }
}