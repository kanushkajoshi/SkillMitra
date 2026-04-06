package servlets;

import db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AdminDeleteServlet")
public class AdminDeleteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth guard ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String type = request.getParameter("type");
        String idStr = request.getParameter("id");

        if (type == null || idStr == null) {
            response.sendRedirect("admin_dash.jsp");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin_dash.jsp");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            if ("employer".equals(type)) {
                deleteEmployer(con, id);
                session.setAttribute("adminMsg_success",
                    "Employer account and all related data deleted successfully.");

            } else if ("jobseeker".equals(type)) {
                deleteJobseeker(con, id);
                session.setAttribute("adminMsg_success",
                    "Job seeker account and all related data deleted successfully.");

            } else if ("job".equals(type)) {
                deleteJob(con, id);
                session.setAttribute("adminMsg_success",
                    "Job post deleted successfully.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminMsg_error",
                "Error deleting record: " + e.getMessage());
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }

        // Redirect back to the right section
        String section = "employers";
        if ("jobseeker".equals(type)) section = "jobseekers";
        else if ("job".equals(type))  section = "jobs";

        response.sendRedirect("admin_dash.jsp#" + section);
    }

    // ── Delete employer and cascade ──
    private void deleteEmployer(Connection con, int eid) throws SQLException {
        // Delete in dependency order
        // 1. ratings referencing employer's jobs
        PreparedStatement ps;

        ps = con.prepareStatement(
            "DELETE FROM ratings WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 2. payments referencing applications of employer's jobs
        ps = con.prepareStatement(
            "DELETE FROM payments WHERE application_id IN " +
            "(SELECT application_id FROM applications WHERE job_id IN " +
            "(SELECT job_id FROM jobs WHERE eid=?))");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 3. bid_negotiations for employer's jobs
        ps = con.prepareStatement(
            "DELETE FROM bid_negotiations WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 4. bids
        ps = con.prepareStatement(
            "DELETE FROM bids WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 5. applications
        ps = con.prepareStatement(
            "DELETE FROM applications WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 6. job_skills
        ps = con.prepareStatement(
            "DELETE FROM job_skills WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 7. job_languages
        ps = con.prepareStatement(
            "DELETE FROM job_languages WHERE job_id IN (SELECT job_id FROM jobs WHERE eid=?)");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 8. jobs
        ps = con.prepareStatement("DELETE FROM jobs WHERE eid=?");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 9. notifications
        ps = con.prepareStatement("DELETE FROM notifications WHERE employer_id=?");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();

        // 10. employer
        ps = con.prepareStatement("DELETE FROM employer WHERE eid=?");
        ps.setInt(1, eid); ps.executeUpdate(); ps.close();
    }

    // ── Delete jobseeker and cascade ──
    private void deleteJobseeker(Connection con, int jid) throws SQLException {
        PreparedStatement ps;

        // ratings
        ps = con.prepareStatement("DELETE FROM ratings WHERE jobseeker_id=?");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // payments via applications
        ps = con.prepareStatement(
            "DELETE FROM payments WHERE application_id IN " +
            "(SELECT application_id FROM applications WHERE jobseeker_id=?)");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // bid_negotiations
        ps = con.prepareStatement(
            "DELETE FROM bid_negotiations WHERE bid_id IN " +
            "(SELECT bid_id FROM bids WHERE job_seeker_id=?)");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // bids payments
        ps = con.prepareStatement(
            "DELETE FROM payments WHERE application_id IN " +
            "(SELECT bid_id FROM bids WHERE job_seeker_id=?)");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // bids
        ps = con.prepareStatement("DELETE FROM bids WHERE job_seeker_id=?");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // applications
        ps = con.prepareStatement("DELETE FROM applications WHERE jobseeker_id=?");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // jobseeker_skills
        ps = con.prepareStatement("DELETE FROM jobseeker_skills WHERE jid=?");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();

        // jobseeker
        ps = con.prepareStatement("DELETE FROM jobseeker WHERE jid=?");
        ps.setInt(1, jid); ps.executeUpdate(); ps.close();
    }

    // ── Delete a single job and cascade ──
    private void deleteJob(Connection con, int jobId) throws SQLException {
        PreparedStatement ps;

        ps = con.prepareStatement("DELETE FROM ratings WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement(
            "DELETE FROM payments WHERE application_id IN " +
            "(SELECT application_id FROM applications WHERE job_id=?)");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM bid_negotiations WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement(
            "DELETE FROM payments WHERE application_id IN " +
            "(SELECT bid_id FROM bids WHERE job_id=?)");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM bids WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM applications WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM job_skills WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM job_languages WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("DELETE FROM jobs WHERE job_id=?");
        ps.setInt(1, jobId); ps.executeUpdate(); ps.close();
    }
}