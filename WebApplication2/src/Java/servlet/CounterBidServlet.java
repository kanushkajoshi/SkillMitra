package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CounterBidServlet")
public class CounterBidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect("login.jsp"); return; }

        Integer eid = (Integer) session.getAttribute("eid");
        Integer jid = (Integer) session.getAttribute("jobseekerId");

        if (eid == null && jid == null) { response.sendRedirect("login.jsp"); return; }

        int bidId, counterAmount;
        try {
            bidId         = Integer.parseInt(request.getParameter("bid_id"));
            counterAmount = Integer.parseInt(request.getParameter("counter_amount"));
        } catch (NumberFormatException e) {
            response.sendRedirect(eid != null
                ? "emp_dash.jsp?section=reviewApplications"
                : "jobseeker_dash.jsp?section=applied");
            return;
        }
        String note = request.getParameter("note");
        if (note != null && note.trim().isEmpty()) note = null;
        String submittedBy = request.getParameter("submitted_by");

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            PreparedStatement psCheck = con.prepareStatement(
                "SELECT b.bid_id, b.job_id, b.job_seeker_id, b.bid_status, " +
                "       b.round_number, j.eid AS employer_id " +
                "FROM   bids b JOIN jobs j ON j.job_id = b.job_id " +
                "WHERE  b.bid_id = ?"
            );
            psCheck.setInt(1, bidId);
            ResultSet rs = psCheck.executeQuery();
            if (!rs.next()) {
                rs.close(); psCheck.close();
                response.sendRedirect(eid != null
                    ? "emp_dash.jsp?section=reviewApplications"
                    : "jobseeker_dash.jsp?section=applied");
                return;
            }
            int    jobId       = rs.getInt("job_id");
            int    jobSeekerId = rs.getInt("job_seeker_id");
            int    employerId  = rs.getInt("employer_id");
            int    roundNumber = rs.getInt("round_number");
            String bidStatus   = rs.getString("bid_status");
            rs.close(); psCheck.close();

            // ── Determine actor by matching session IDs against this specific bid.
            //    This is the KEY fix: we never guess — we check who actually owns the bid.
            String actor;
            int    actorId;
 
             if ("jobseeker".equals(submittedBy) && jid != null && jid.intValue() == jobSeekerId) {
                // Jobseeker form submitted and session matches
                actor   = "Jobseeker";
                actorId = jid;
            } else if ("employer".equals(submittedBy) && eid != null && eid.intValue() == employerId) {
                // Employer form submitted and session matches
                actor   = "Employer";
                actorId = eid;
            } else if (jid != null && eid == null) {
                // Fallback: only jobseeker session active
                actor   = "Jobseeker";
                actorId = jid;
            } else if (eid != null && jid == null) {
                // Fallback: only employer session active
                actor   = "Employer";
                actorId = eid;
            } else if (jid != null && jid.intValue() == jobSeekerId) {
                // Fallback: both tabs open, jid matches bid jobseeker
                actor   = "Jobseeker";
                actorId = jid;
            } else if (eid != null && eid.intValue() == employerId) {
                // Fallback: both tabs open, eid matches bid employer
                actor   = "Employer";
                actorId = eid;
            } else {
    // When both sessions active and nothing matched,
    // use submitted_by to decide where to redirect
    if ("jobseeker".equals(submittedBy)) {
        response.sendRedirect("jobseeker_dash.jsp?section=applied");
    } else if ("employer".equals(submittedBy)) {
        response.sendRedirect("emp_dash.jsp?section=reviewApplications");
    } else {
        response.sendRedirect(jid != null
            ? "jobseeker_dash.jsp?section=applied"
            : "emp_dash.jsp?section=reviewApplications");
    }
    return;
}
            // Block finalized bids
            if ("Accepted".equalsIgnoreCase(bidStatus) ||
                "Rejected".equalsIgnoreCase(bidStatus) ||
                "RejectedByJobseeker".equalsIgnoreCase(bidStatus)) {
                redirectHome(response, actor);
                return;
            }

            // Employer counters → "Countered" (jobseeker must respond)
            // Jobseeker counters → "JobseekerCountered" (employer must respond)
            String newBidStatus = "Employer".equals(actor) ? "Countered" : "JobseekerCountered";
            int    newRound     = roundNumber + 1;

            PreparedStatement psUpdate = con.prepareStatement(
                "UPDATE bids " +
                "SET    counter_bid    = ?, " +
                "       bid_status     = ?, " +
                "       current_amount = ?, " +
                "       last_actor     = ?, " +
                "       round_number   = ? " +
                "WHERE  bid_id = ?"
            );
            psUpdate.setInt(1, counterAmount);
            psUpdate.setString(2, newBidStatus);
            psUpdate.setInt(3, counterAmount);
            psUpdate.setString(4, actor);
            psUpdate.setInt(5, newRound);
            psUpdate.setInt(6, bidId);
            psUpdate.executeUpdate();
            psUpdate.close();

            // Write history with the correct actor stored
            insertHistory(con, bidId, jobId, actor, actorId, "Counter", counterAmount, note);

            // Notify the other party
            String jobTitle = getJobTitle(con, jobId);
            if ("Employer".equals(actor)) {
                insertNotification(con, null, jobSeekerId,
                    "Employer countered your bid on \"" + jobTitle +
                    "\" with \u20b9" + counterAmount + ". Please respond.");
            } else {
                insertNotification(con, employerId, null,
                    "Worker countered back on \"" + jobTitle +
                    "\" with \u20b9" + counterAmount + ". Please respond.");
            }

            redirectHome(response, actor);

        } catch (Exception e) {
    e.printStackTrace();
    if ("jobseeker".equals(submittedBy)) {
        response.sendRedirect("jobseeker_dash.jsp?section=applied");
    } else if ("employer".equals(submittedBy)) {
        response.sendRedirect("emp_dash.jsp?section=reviewApplications");
    } else {
        response.sendRedirect(jid != null
            ? "jobseeker_dash.jsp?section=applied"
            : "emp_dash.jsp?section=reviewApplications");
    }
} finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }

    private void redirectHome(HttpServletResponse response, String actor) throws IOException {
        if ("Employer".equals(actor)) {
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
        } else {
            response.sendRedirect("jobseeker_dash.jsp?section=applied");
        }
    }

    private void insertHistory(Connection con, int bidId, int jobId,
                               String actor, int actorId,
                               String action, Integer amount, String note) throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO bid_negotiations (bid_id, job_id, actor, actor_id, action, amount, note) " +
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
        String title = "this job";
        if (rs.next()) title = rs.getString("title");
        rs.close(); ps.close();
        return title;
    }
}