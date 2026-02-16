package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateApplicationStatusServlet")
public class UpdateApplicationStatusServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        int applicationId = Integer.parseInt(request.getParameter("application_id"));
        String status = request.getParameter("status");

        try {
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            PreparedStatement ps = con.prepareStatement(
                    "UPDATE applications SET status=? WHERE application_id=?"
            );

            ps.setString(1, status);
            ps.setInt(2, applicationId);

            ps.executeUpdate();

            con.close();

            response.sendRedirect("emp_dash.jsp?section=reviewApplications");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
