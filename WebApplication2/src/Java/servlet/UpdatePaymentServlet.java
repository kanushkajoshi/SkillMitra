package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;

@WebServlet("/UpdatePaymentServlet")
public class UpdatePaymentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String applicationId = request.getParameter("applicationId");
        String action = request.getParameter("action");
        String type = request.getParameter("type");

        if (applicationId == null || action == null) {
            response.sendRedirect("jobseeker_dash.jsp?section=payments");
            return;
        }

        int appId = Integer.parseInt(applicationId);

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // ───────── REQUEST PAYMENT ─────────
            if ("request".equals(action)) {

                ps = con.prepareStatement(
                        "INSERT INTO payments(application_id, status) VALUES (?, 'Requested') "
                        + "ON DUPLICATE KEY UPDATE status='Requested'"
                );

                ps.setInt(1, appId);
                ps.executeUpdate();
                ps.close();

                // Find employer info
                if ("application".equals(type)) {

                    ps = con.prepareStatement(
                            "SELECT j.eid, j.title, js.jfirstname, js.jlastname "
                            + "FROM applications a "
                            + "JOIN jobs j ON j.job_id = a.job_id "
                            + "JOIN jobseeker js ON js.jid = a.jobseeker_id "
                            + "WHERE a.application_id = ?"
                    );

                } else {

                    ps = con.prepareStatement(
                            "SELECT j.eid, j.title, js.jfirstname, js.jlastname "
                            + "FROM bids b "
                            + "JOIN jobs j ON j.job_id = b.job_id "
                            + "JOIN jobseeker js ON js.jid = b.job_seeker_id "
                            + "WHERE b.bid_id = ?"
                    );
                }

                ps.setInt(1, appId);
                rs = ps.executeQuery();

                if (rs.next()) {

                    int eid = rs.getInt("eid");
                    String jobTitle = rs.getString("title");
                    String workerName = rs.getString("jfirstname") + " " + rs.getString("jlastname");

                    rs.close();
                    ps.close();

                    // Insert notification
                    ps = con.prepareStatement(
                            "INSERT INTO notifications(employer_id, message) VALUES (?, ?)"
                    );

                    ps.setInt(1, eid);
                    ps.setString(2,
                            "💰 " + workerName + " has requested payment for job: \"" + jobTitle + "\""
                    );

                    ps.executeUpdate();
                }

                response.sendRedirect("jobseeker_dash.jsp?section=payments");
                return;
            }

            // ───────── CONFIRM PAYMENT RECEIVED ─────────
            else if ("confirm".equals(action)) {

    ps = con.prepareStatement(
        "INSERT INTO payments(application_id, status) VALUES (?, 'Confirmed') "
      + "ON DUPLICATE KEY UPDATE status='Confirmed'"
    );

    ps.setInt(1, appId);
    ps.executeUpdate();

    response.sendRedirect("jobseeker_dash.jsp?section=payments");
    return;
}

            // ───────── EMPLOYER MARKS PAID ─────────
            else if ("paid".equals(action)) {

                ps = con.prepareStatement(
                        "UPDATE payments SET status='Paid' WHERE application_id=?"
                );

                ps.setInt(1, appId);
                ps.executeUpdate();

                response.sendRedirect("emp_dash.jsp?section=payments");
                return;
            }

            // ───────── DEFAULT SAFETY REDIRECT ─────────
            response.sendRedirect("jobseeker_dash.jsp?section=payments");

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?section=payments");

        } finally {

            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception ignored) {
            }

            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ignored) {
            }

            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception ignored) {
            }
        }
    }
}