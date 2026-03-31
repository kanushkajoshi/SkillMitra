package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RespondCounterServlet")
public class RespondCounterServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 1. Get parameters from URL
        String action = request.getParameter("action");  // accept or reject
        int bidId = Integer.parseInt(request.getParameter("bid_id"));

        // 🔹 2. Determine new status
        String newStatus = null;
        if ("accept".equalsIgnoreCase(action)) {
            newStatus = "Accepted";
        } else if ("reject".equalsIgnoreCase(action)) {
            newStatus = "Rejected";
        } else {
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
            return;
        }

        Connection con = null;
        PreparedStatement psUpdate = null;
        ResultSet rsBid = null;

        try {
            con = DBConnection.getConnection();

            // 🔹 3. Get job_id and job_seeker_id of this bid
            int jobId = 0;
            int jobSeekerId = 0;

            PreparedStatement psGetBid = con.prepareStatement(
                    "SELECT job_id, job_seeker_id FROM bids WHERE bid_id=?"
            );
            psGetBid.setInt(1, bidId);
            rsBid = psGetBid.executeQuery();

            if (rsBid.next()) {
                jobId = rsBid.getInt("job_id");
                jobSeekerId = rsBid.getInt("job_seeker_id");
            }
            rsBid.close();
            psGetBid.close();

            // 🔹 4. Update bid status
            psUpdate = con.prepareStatement(
                    "UPDATE bids SET bid_status=? WHERE bid_id=?"
            );
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, bidId);
            psUpdate.executeUpdate();
            psUpdate.close();

            // 🔹 5. Update corresponding application status
            String appStatus = (newStatus.equalsIgnoreCase("Accepted")) ? "Bid Placed" : "Rejected";

            PreparedStatement psApp = con.prepareStatement(
                    "UPDATE applications SET status=? " +
                    "WHERE job_id=? AND jobseeker_id=?"
            );
            psApp.setString(1, appStatus);
            psApp.setInt(2, jobId);
            psApp.setInt(3, jobSeekerId);
            psApp.executeUpdate();
            psApp.close();

            // 🔹 6. If accepted → check workers_required and close job if full
            if ("Accepted".equalsIgnoreCase(newStatus)) {

                // 6a. Count accepted bids for this job
                PreparedStatement psCount = con.prepareStatement(
                        "SELECT COUNT(*) FROM bids WHERE job_id=? AND bid_status='Accepted'"
                );
                psCount.setInt(1, jobId);
                ResultSet rsCount = psCount.executeQuery();

                int acceptedCount = 0;
                if (rsCount.next()) {
                    acceptedCount = rsCount.getInt(1);
                }
                rsCount.close();
                psCount.close();

                // 6b. Get workers_required from jobs
                PreparedStatement psReq = con.prepareStatement(
                        "SELECT workers_required FROM jobs WHERE job_id=?"
                );
                psReq.setInt(1, jobId);
                ResultSet rsReq = psReq.executeQuery();

                int required = 0;
                if (rsReq.next()) {
                    required = rsReq.getInt("workers_required");
                }
                rsReq.close();
                psReq.close();

                // 6c. Close job if limit reached
                if (acceptedCount >= required) {
                    PreparedStatement psClose = con.prepareStatement(
                            "UPDATE jobs SET status='Closed' WHERE job_id=?"
                    );
                    psClose.setInt(1, jobId);
                    psClose.executeUpdate();
                    psClose.close();
                }
            }

            // 🔹 7. Redirect jobseeker to applied section
            response.sendRedirect("jobseeker_dash.jsp?section=applied");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
        } finally {
            try { if (rsBid != null) rsBid.close(); } catch (Exception e) {}
            try { if (psUpdate != null) psUpdate.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}