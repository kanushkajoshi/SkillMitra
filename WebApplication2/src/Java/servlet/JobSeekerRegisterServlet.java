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


    // SAVE EACH FIELD
    session.setAttribute("jfirstname", request.getParameter("jfirstname"));
    session.setAttribute("jlastname", request.getParameter("jlastname"));
    session.setAttribute("jemail", request.getParameter("jemail"));
    session.setAttribute("jphone", request.getParameter("jphone"));
    session.setAttribute("jpwd", request.getParameter("jpwd"));
    session.setAttribute("jeducation", request.getParameter("jeducation"));
    session.setAttribute("jcountry", request.getParameter("jcountry"));
    session.setAttribute("jstate", request.getParameter("jstate"));
    session.setAttribute("jdistrict", request.getParameter("jdistrict"));
    session.setAttribute("jarea", request.getParameter("jarea"));
    session.setAttribute("jzip", request.getParameter("jzip"));
    session.setAttribute("jdob", request.getParameter("jdob"));

    // OTP
    String otp = String.valueOf((int)(Math.random()*900000)+100000);
    session.setAttribute("otp", otp);
    long expiryTime = System.currentTimeMillis() + 5*60*1000; // 5 minutes

    session.setAttribute("otpExpiry", expiryTime);
    session.setAttribute("role","jobseeker");
    System.out.println("OTP = " + otp);
    session.setAttribute("regData", request.getParameterMap());

    EmailUtility.sendOTP(
        request.getParameter("jemail"),
        otp
    );

    response.sendRedirect("verify_otp.jsp?email="+request.getParameter("jemail"));
}
}
