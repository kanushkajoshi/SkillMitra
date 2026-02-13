package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jobseekerId = (int) session.getAttribute("jobseekerId");
        String jobIdParam = request.getParameter("jobId");

        if (jobIdParam == null || jobIdParam.isEmpty()) {
            response.sendRedirect("jobseeker_dash.jsp?msg=error");
            return;
        }

        int jobId = Integer.parseInt(jobIdParam);

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            // 🔹 Check duplicate application
            String checkQuery = "SELECT * FROM applications WHERE job_id=? AND jobseeker_id=?";
            PreparedStatement ps1 = con.prepareStatement(checkQuery);
            ps1.setInt(1, jobId);
            ps1.setInt(2, jobseekerId);

            ResultSet rs = ps1.executeQuery();

            if (rs.next()) {
                response.sendRedirect("jobseeker_dash.jsp?msg=already");
                return;
            }

            // 🔹 Insert application
            String insertQuery = "INSERT INTO applications (job_id, jobseeker_id) VALUES (?, ?)";
            PreparedStatement ps2 = con.prepareStatement(insertQuery);
            ps2.setInt(1, jobId);
            ps2.setInt(2, jobseekerId);

            ps2.executeUpdate();

            response.sendRedirect("jobseeker_dash.jsp?msg=applied");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?msg=error");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {}
        }
    }
}
