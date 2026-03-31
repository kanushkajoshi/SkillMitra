package servlet;

import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/JobSeekerLoginServlet")
public class JobSeekerLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {

            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
            );

            String sql =
                "SELECT jid,jfirstname,jlastname,email_verified "+
                "FROM jobseeker "+
                "WHERE jemail=? AND jpwd=?";

            PreparedStatement ps =
                con.prepareStatement(sql);

            ps.setString(1,email);
            ps.setString(2,password);

            ResultSet rs = ps.executeQuery();

            if(rs.next()) {

                boolean verified =
                    rs.getBoolean("email_verified");

                // 🚨 BLOCK IF NOT VERIFIED
                if(!verified){

                    response.sendRedirect(
                        "verify_otp.jsp?email="+email+
                        "&error=notverified"
                    );
                    return;
                }

                // ✅ LOGIN SUCCESS
                HttpSession session =
                    request.getSession();

                session.setAttribute(
                    "jobseekerId",
                    rs.getInt("jid")
                );

                session.setAttribute(
                    "jfirstname",
                    rs.getString("jfirstname")
                );

                session.setAttribute(
                    "jlastname",
                    rs.getString("jlastname")
                );

                session.setAttribute(
                    "jobseekerEmail",
                    email
                );

                response.sendRedirect(
                    "jobseeker_dash.jsp"
                );

            } else {

                // ❌ WRONG CREDENTIALS
                response.sendRedirect(
                    "login.jsp?error=invalid&role=jobseeker"
                );
            }

            con.close();

        } catch(Exception e){

            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
