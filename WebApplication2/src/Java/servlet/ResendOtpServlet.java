/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlet;
import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
@WebServlet("/ResendOtpServlet")
public class ResendOtpServlet extends HttpServlet {

protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
                      throws IOException {

    HttpSession session = request.getSession(false);

    if(session == null){
        response.sendRedirect("jobseeker_register.jsp");
        return;
    }

    // ✅ CAST MAP CORRECTLY
    Map<String,String[]> data =
        (Map<String,String[]>) session.getAttribute("regData");

    if(data == null){
        response.sendRedirect("jobseeker_register.jsp");
        return;
    }

    // ✅ GET EMAIL SAFELY
    String email = data.get("jemail")[0];

    // GENERATE OTP
    String otp =
        String.valueOf((int)(Math.random()*900000)+100000);

    session.setAttribute("otp", otp);

    System.out.println("NEW OTP = " + otp);

    EmailUtility.sendOTP(email, otp);

    response.sendRedirect("verify_otp.jsp?email="+email);
}
}
