package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jobseekerId = (Integer) session.getAttribute("jobseekerId");
        int jobId = Integer.parseInt(request.getParameter("jobId"));

        try (Connection con = DBConnection.getConnection()) {

            // 🔹 Duplicate check
            String checkSql = "SELECT application_id FROM applications WHERE job_id=? AND jobseeker_id=?";
            PreparedStatement checkPs = con.prepareStatement(checkSql);
            checkPs.setInt(1, jobId);
            checkPs.setInt(2, jobseekerId);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                // 🔹 If already applied → back to dashboard's Applied section
                response.sendRedirect("jobseeker_dash.jsp?section=applied&msg=already");
                return;
            }

            // 🔹 Insert application
            String insertSql = "INSERT INTO applications (job_id, jobseeker_id, status) VALUES (?, ?, 'Pending')";
            PreparedStatement insertPs = con.prepareStatement(insertSql);
            insertPs.setInt(1, jobId);
            insertPs.setInt(2, jobseekerId);
            insertPs.executeUpdate();

            // 🔹 Redirect to dashboard's Applied section
            response.sendRedirect("jobseeker_dash.jsp?section=applied&msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?section=applied&msg=error");
        }
    }
}