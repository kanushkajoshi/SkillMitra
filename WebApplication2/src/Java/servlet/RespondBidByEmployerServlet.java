package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * RespondBidByEmployerServlet
 *
 * Employer responds to a bid or counter-bid.
 * action = "accept"  → FINAL – job is assigned
 * action = "reject"  → FINAL – bid is closed
 *
 * Only the EMPLOYER can make a FINAL decision.
 */
@WebServlet("/RespondBidByEmployerServlet")
public class RespondBidByEmployerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect("login.jsp"); return; }

        Integer eid = (Integer) session.getAttribute("eid");
        if (eid == null) { response.sendRedirect("login.jsp"); return; }

        int    bidId;
        String action;
        try {
            bidId  = Integer.parseInt(request.getParameter("bid_id"));
            action = request.getParameter("action");   // "accept" | "reject"
        } catch (Exception e) {
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
            return;
        }

        if (!"accept".equalsIgnoreCase(action) && !"reject".equalsIgnoreCase(action)) {
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // ── 1. Load bid data ────────────────────────────────────────────
            PreparedStatement psGet = con.prepareStatement(
                "SELECT b.bid_id, b.job_id, b.job_seeker_id, " +
                "       b.bid_amount, b.counter_bid, b.bid_status, b.current_amount, " +
                "       j.eid AS employer_id, j.workers_required " +
                "FROM   bids b " +
                "JOIN   jobs j ON j.job_id = b.job_id " +
                "WHERE  b.bid_id = ?"
            );
            psGet.setInt(1, bidId);
            ResultSet rs = psGet.executeQuery();

            if (!rs.next()) { rs.close(); psGet.close();
                response.sendRedirect("emp_dash.jsp?section=reviewApplications"); return; }

            int jobId        = rs.getInt("job_id");
            int jobSeekerId  = rs.getInt("job_seeker_id");
            int employerId   = rs.getInt("employer_id");
            int workersReq   = rs.getInt("workers_required");
            int currentAmt   = rs.getInt("current_amount");
            if (currentAmt == 0) currentAmt = rs.getInt("bid_amount");  // fallback
            String bidStatus = rs.getString("bid_status");
            rs.close(); psGet.close();

            // Security check
            if (employerId != eid) {
                response.sendRedirect("emp_dash.jsp?section=reviewApplications"); return; }

            // Guard – can't respond to already-closed bids
            if ("Accepted".equalsIgnoreCase(bidStatus) ||
                "Rejected".equalsIgnoreCase(bidStatus)) {
                response.sendRedirect("emp_dash.jsp?section=reviewApplications"); return; }

            // ── 2. Determine final status strings ───────────────────────────
            String finalBidStatus;
            String finalAppStatus;
            String historyAction;
            String notifMsg;
            String jobTitle = getJobTitle(con, jobId);

            if ("accept".equalsIgnoreCase(action)) {
                finalBidStatus = "Accepted";
                finalAppStatus = "Accepted";
                historyAction  = "Accept";
                notifMsg = "🎉 Your bid of ₹" + currentAmt + " on \"" + jobTitle +
                           "\" has been ACCEPTED! Report to work.";
            } else {
                finalBidStatus = "Rejected";
                finalAppStatus = "Rejected";
                historyAction  = "Reject";
                notifMsg = "Your bid on \"" + jobTitle + "\" was not accepted this time.";
            }

            // ── 3. Update bids table ────────────────────────────────────────
            PreparedStatement psUpdateBid = con.prepareStatement(
                "UPDATE bids " +
                "SET    bid_status     = ?, " +
                "       last_actor     = 'Employer' " +
                "WHERE  bid_id = ?"
            );
            psUpdateBid.setString(1, finalBidStatus);
            psUpdateBid.setInt(2, bidId);
            psUpdateBid.executeUpdate();
            psUpdateBid.close();

            // ── 4. Update applications table ────────────────────────────────
            PreparedStatement psApp = con.prepareStatement(
                "UPDATE applications SET status = ? " +
                "WHERE  job_id = ? AND jobseeker_id = ?"
            );
            psApp.setString(1, finalAppStatus);
            psApp.setInt(2, jobId);
            psApp.setInt(3, jobSeekerId);
            psApp.executeUpdate();
            psApp.close();

            // ── 5. Write history ────────────────────────────────────────────
            insertHistory(con, bidId, jobId, "Employer", eid, historyAction, null, null);

            // ── 6. Notify jobseeker ─────────────────────────────────────────
            insertNotification(con, null, jobSeekerId, notifMsg);

            // ── 7. If accepted → check workers_required, close job if full ─
            if ("Accepted".equalsIgnoreCase(finalBidStatus)) {

                PreparedStatement psCount = con.prepareStatement(
                    "SELECT (SELECT COUNT(*) FROM applications a " +
                    "        WHERE a.job_id=? AND a.status='Accepted') + " +
                    "       (SELECT COUNT(*) FROM bids b " +
                    "        WHERE b.job_id=? AND b.bid_status='Accepted') AS total"
                );
                psCount.setInt(1, jobId);
                psCount.setInt(2, jobId);
                ResultSet rsCnt = psCount.executeQuery();
                int accepted = 0;
                if (rsCnt.next()) accepted = rsCnt.getInt("total");
                rsCnt.close(); psCount.close();

                if (accepted >= workersReq) {
                    PreparedStatement psClose = con.prepareStatement(
                        "UPDATE jobs SET status='Closed' WHERE job_id=?"
                    );
                    psClose.setInt(1, jobId);
                    psClose.executeUpdate();
                    psClose.close();
                }

                response.sendRedirect("emp_dash.jsp?section=acceptedApplications");
            } else {
                response.sendRedirect("emp_dash.jsp?section=rejectedApplications");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
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