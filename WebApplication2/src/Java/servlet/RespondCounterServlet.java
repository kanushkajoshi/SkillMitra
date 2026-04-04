package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * RespondCounterServlet
 *
 * Called when the JOBSEEKER responds to an employer's counter-offer.
 *
 * action = "accept"  → Jobseeker says "OK, now employer must formally accept"
 *                      Status → "JobseekerAccepted"  (waiting for employer final confirm)
 * action = "reject"  → Jobseeker walks away
 *                      Status → "RejectedByJobseeker"
 *
 * NOTE: Accepting here does NOT finalise the job.
 *       The employer must still hit Accept for the job to be assigned.
 *       This is enforced by keeping status = "JobseekerAccepted" until
 *       the employer confirms via RespondBidByEmployerServlet.
 *
 * Jobseeker COUNTER is handled by CounterBidServlet (actor=Jobseeker).
 */
@WebServlet("/RespondCounterServlet")
public class RespondCounterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect("login.jsp"); return; }

        Integer jid = (Integer) session.getAttribute("jobseekerId");
        if (jid == null) { response.sendRedirect("login.jsp"); return; }

        int    bidId;
        String action;
        try {
            bidId  = Integer.parseInt(request.getParameter("bid_id"));
            action = request.getParameter("action");   // "accept" | "reject"
        } catch (Exception e) {
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
            return;
        }

        if (!"accept".equalsIgnoreCase(action) && !"reject".equalsIgnoreCase(action)) {
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // ── 1. Load bid ─────────────────────────────────────────────────
            PreparedStatement psGet = con.prepareStatement(
                "SELECT b.bid_id, b.job_id, b.job_seeker_id, " +
                "       b.bid_status, b.current_amount, b.counter_bid, " +
                "       j.eid AS employer_id " +
                "FROM   bids b " +
                "JOIN   jobs j ON j.job_id = b.job_id " +
                "WHERE  b.bid_id = ?"
            );
            psGet.setInt(1, bidId);
            ResultSet rs = psGet.executeQuery();

            if (!rs.next()) {
                rs.close(); psGet.close();
                response.sendRedirect("jobseeker_dash.jsp?section=applied"); return; }

            int jobId        = rs.getInt("job_id");
            int jobSeekerId  = rs.getInt("job_seeker_id");
            int employerId   = rs.getInt("employer_id");
            String bidStatus = rs.getString("bid_status");
            int currentAmt   = rs.getInt("current_amount");
            rs.close(); psGet.close();

            // Security: this must belong to the logged-in jobseeker
            if (jobSeekerId != jid) {
                response.sendRedirect("jobseeker_dash.jsp?section=applied"); return; }

            // Must be in a state where jobseeker is expected to act
            if (!"Countered".equalsIgnoreCase(bidStatus)) {
                response.sendRedirect("jobseeker_dash.jsp?section=applied"); return; }

            // ── 2. Determine transitions ────────────────────────────────────
            String newBidStatus;
            String historyAction;
            String notifMsg;
            String jobTitle = getJobTitle(con, jobId);

            if ("accept".equalsIgnoreCase(action)) {
                // Jobseeker says yes → ball is in employer's court for final confirm
                newBidStatus  = "JobseekerAccepted";
                historyAction = "Accept";
                notifMsg = "✅ Worker accepted your counter of ₹" + currentAmt +
                           " on \"" + jobTitle + "\". Please give your final decision.";
            } else {
                // Jobseeker walks away
                newBidStatus  = "RejectedByJobseeker";
                historyAction = "Reject";
                notifMsg = "Worker declined your counter on \"" + jobTitle + "\".";
            }

            // ── 3. Update bids ──────────────────────────────────────────────
            PreparedStatement psUpd = con.prepareStatement(
                "UPDATE bids SET bid_status = ?, last_actor = 'Jobseeker' WHERE bid_id = ?"
            );
            psUpd.setString(1, newBidStatus);
            psUpd.setInt(2, bidId);
            psUpd.executeUpdate();
            psUpd.close();

            // ── 4. Update applications if jobseeker rejected ────────────────
            if ("RejectedByJobseeker".equals(newBidStatus)) {
                PreparedStatement psApp = con.prepareStatement(
                    "UPDATE applications SET status = 'Rejected' " +
                    "WHERE job_id = ? AND jobseeker_id = ?"
                );
                psApp.setString(1, "Rejected");  // placeholder – corrected below
                psApp.close();

                // Correct update:
                PreparedStatement psApp2 = con.prepareStatement(
                    "UPDATE applications SET status = 'Rejected' " +
                    "WHERE job_id = ? AND jobseeker_id = ?"
                );
                psApp2.setInt(1, jobId);
                psApp2.setInt(2, jobSeekerId);
                psApp2.executeUpdate();
                psApp2.close();
            }

            // ── 5. History ──────────────────────────────────────────────────
            insertHistory(con, bidId, jobId, "Jobseeker", jid, historyAction, null, null);

            // ── 6. Notify employer ──────────────────────────────────────────
            insertNotification(con, employerId, null, notifMsg);

            response.sendRedirect("jobseeker_dash.jsp?section=applied");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private void insertHistory(Connection con, int bidId, int jobId,
                               String actor, int actorId,
                               String action, Integer amount, String note)
            throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO bid_negotiations " +
            "(bid_id, job_id, actor, actor_id, action, amount, note) " +
            "VALUES (?,?,?,?,?,?,?)"
        );
        ps.setInt(1, bidId);
        ps.setInt(2, jobId);
        ps.setString(3, actor);
        ps.setInt(4, actorId);
        ps.setString(5, action);
        if (amount == null) ps.setNull(6, java.sql.Types.INTEGER);
        else                ps.setInt(6, amount);
        if (note == null)   ps.setNull(7, java.sql.Types.VARCHAR);
        else                ps.setString(7, note);
        ps.executeUpdate();
        ps.close();
    }

    private void insertNotification(Connection con, Integer empId, Integer jsId,
                                    String message) throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO notifications (employer_id, jobseeker_id, message) VALUES (?,?,?)"
        );
        if (empId == null) ps.setNull(1, java.sql.Types.INTEGER);
        else               ps.setInt(1, empId);
        if (jsId  == null) ps.setNull(2, java.sql.Types.INTEGER);
        else               ps.setInt(2, jsId);
        ps.setString(3, message);
        ps.executeUpdate();
        ps.close();
    }

    private String getJobTitle(Connection con, int jobId) throws SQLException {
        PreparedStatement ps = con.prepareStatement("SELECT title FROM jobs WHERE job_id=?");
        ps.setInt(1, jobId);
        ResultSet rs = ps.executeQuery();
        String t = "this job";
        if (rs.next()) t = rs.getString("title");
        rs.close(); ps.close();
        return t;
    }
}