package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * SubmitRatingServlet — handles rating form POST for both Employer and Jobseeker.
 *
 * KEY DESIGN DECISIONS:
 *  - ratingBy comes from the hidden form field (most reliable source of truth)
 *  - Session is only used to VALIDATE the form field hasn't been tampered with
 *  - alreadyRated() includes rating_by so Employer + Jobseeker are independent rows
 *  - UNIQUE KEY (job_id, rating_by, employer_id, jobseeker_id) allows BOTH ratings
 *  - Redirects use the correct filenames: emp_dash.jsp / jobseeker_dash.jsp
 */
@WebServlet("/SubmitRatingServlet")
public class SubmitRatingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── Step 1: Get ratingBy from the FORM (hidden field is authoritative) ──
        // Using only session caused the bug where eid-check always won,
        // making jobseeker submissions impossible if session had stale data.
        String ratingBy = request.getParameter("rating_by");

        // Validate it is a known value
        if (!"Employer".equals(ratingBy) && !"Jobseeker".equals(ratingBy)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── Step 2: Cross-validate against session to prevent tampering ──────
        Integer eid = (Integer) session.getAttribute("eid");
        Integer jid = (Integer) session.getAttribute("jobseekerId");

        if ("Employer".equals(ratingBy) && eid == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        if ("Jobseeker".equals(ratingBy) && jid == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── Step 3: Parse form params ─────────────────────────────────────────
        int jobId, employerId, jobseekerId, ratingValue;
        try {
            jobId       = Integer.parseInt(request.getParameter("job_id"));
            employerId  = Integer.parseInt(request.getParameter("employer_id"));
            jobseekerId = Integer.parseInt(request.getParameter("jobseeker_id"));
            ratingValue = Integer.parseInt(request.getParameter("rating_value"));
        } catch (NumberFormatException e) {
            setFlash(session, ratingBy, "error", "Invalid form data. Please try again.");
            redirectBack(response, ratingBy);
            return;
        }

        // Clamp ratingValue to 1-5
        if (ratingValue < 1 || ratingValue > 5) {
            setFlash(session, ratingBy, "error", "Please select a star rating (1-5).");
            redirectBack(response, ratingBy);
            return;
        }

        String reviewText = request.getParameter("review_text");
        if (reviewText == null) reviewText = "";
        reviewText = reviewText.trim();

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // ── Step 4: Payment must be Confirmed ────────────────────────────
            if (!isPaymentConfirmed(con, jobId, employerId, jobseekerId)) {
                setFlash(session, ratingBy, "error",
                        "Rating is only allowed after payment is confirmed.");
                redirectBack(response, ratingBy);
                return;
            }

            // ── Step 5: Duplicate check per role ─────────────────────────────
            // CRITICAL: rating_by is part of the query so an Employer rating
            // does NOT block the Jobseeker from also rating the same job.
            if (alreadyRated(con, jobId, ratingBy, employerId, jobseekerId)) {
                setFlash(session, ratingBy, "error",
                        "You have already submitted a rating for this job.");
                redirectBack(response, ratingBy);
                return;
            }

            // ── Step 6: Insert ────────────────────────────────────────────────
            if ("Employer".equals(ratingBy)) {
                insertEmployerRating(con, request, jobId, employerId,
                                     jobseekerId, ratingValue, reviewText);
            } else {
                insertJobseekerRating(con, request, jobId, employerId,
                                      jobseekerId, ratingValue, reviewText);
            }

            setFlash(session, ratingBy, "success",
                     "Your rating has been submitted successfully! ⭐");

        } catch (SQLIntegrityConstraintViolationException e) {
            // UNIQUE KEY fired — race condition or double-submit
            setFlash(session, ratingBy, "error",
                     "You have already submitted a rating for this job.");
        } catch (Exception e) {
            e.printStackTrace();
            setFlash(session, ratingBy, "error",
                     "Something went wrong: " + e.getMessage());
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }

        redirectBack(response, ratingBy);
    }

    // ── Insert helpers ────────────────────────────────────────────────────────

    private void insertEmployerRating(Connection con, HttpServletRequest req,
                                       int jobId, int employerId, int jobseekerId,
                                       int ratingValue, String reviewText)
            throws SQLException {

        int workQuality  = parseOr(req.getParameter("work_quality"),         ratingValue);
        int performance  = parseOr(req.getParameter("performance"),           ratingValue);
        int punctuality  = parseOr(req.getParameter("punctuality"),           ratingValue);
        int profBehavior = parseOr(req.getParameter("professional_behavior"), ratingValue);

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO ratings " +
            "(job_id, employer_id, jobseeker_id, rating_by, rating_value, " +
            " work_quality, performance, punctuality, professional_behavior, review_text) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)"
        );
        ps.setInt(1, jobId);
        ps.setInt(2, employerId);
        ps.setInt(3, jobseekerId);
        ps.setString(4, "Employer");
        ps.setInt(5, ratingValue);
        ps.setInt(6, workQuality);
        ps.setInt(7, performance);
        ps.setInt(8, punctuality);
        ps.setInt(9, profBehavior);
        ps.setString(10, reviewText);
        ps.executeUpdate();
        ps.close();
    }

    private void insertJobseekerRating(Connection con, HttpServletRequest req,
                                        int jobId, int employerId, int jobseekerId,
                                        int ratingValue, String reviewText)
            throws SQLException {

        int empBehavior = parseOr(req.getParameter("employer_behavior"),     ratingValue);
        int timelyPay   = parseOr(req.getParameter("timely_payment"),         ratingValue);
        int workEnv     = parseOr(req.getParameter("work_environment"),       ratingValue);
        int fairness    = parseOr(req.getParameter("fairness_communication"), ratingValue);

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO ratings " +
            "(job_id, employer_id, jobseeker_id, rating_by, rating_value, " +
            " employer_behavior, timely_payment, work_environment, " +
            " fairness_communication, review_text) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)"
        );
        ps.setInt(1, jobId);
        ps.setInt(2, employerId);
        ps.setInt(3, jobseekerId);
        ps.setString(4, "Jobseeker");
        ps.setInt(5, ratingValue);
        ps.setInt(6, empBehavior);
        ps.setInt(7, timelyPay);
        ps.setInt(8, workEnv);
        ps.setInt(9, fairness);
        ps.setString(10, reviewText);
        ps.executeUpdate();
        ps.close();
    }

    // ── Payment confirmation check ────────────────────────────────────────────

    private boolean isPaymentConfirmed(Connection con, int jobId,
                                        int employerId, int jobseekerId)
            throws SQLException {

        // Via application path
        PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM payments p " +
            "JOIN applications a ON a.application_id = p.application_id " +
            "JOIN jobs j ON j.job_id = a.job_id " +
            "WHERE j.job_id = ? AND j.eid = ? " +
            "  AND a.jobseeker_id = ? AND p.status = 'Confirmed'"
        );
        ps.setInt(1, jobId); ps.setInt(2, employerId); ps.setInt(3, jobseekerId);
        ResultSet rs = ps.executeQuery(); rs.next();
        int count = rs.getInt(1);
        rs.close(); ps.close();
        if (count > 0) return true;

        // Via bid path
        PreparedStatement ps2 = con.prepareStatement(
            "SELECT COUNT(*) FROM payments p " +
            "JOIN bids b ON b.bid_id = p.application_id " +
            "JOIN jobs j ON j.job_id = b.job_id " +
            "WHERE j.job_id = ? AND j.eid = ? " +
            "  AND b.job_seeker_id = ? AND p.status = 'Confirmed'"
        );
        ps2.setInt(1, jobId); ps2.setInt(2, employerId); ps2.setInt(3, jobseekerId);
        ResultSet rs2 = ps2.executeQuery(); rs2.next();
        int count2 = rs2.getInt(1);
        rs2.close(); ps2.close();
        return count2 > 0;
    }

    // ── Per-role duplicate check ──────────────────────────────────────────────
    //
    // rating_by is IN the WHERE clause so:
    //   row (job=5, rating_by='Employer', ...) does NOT block
    //   row (job=5, rating_by='Jobseeker', ...)
    // Both can exist — this matches the UNIQUE KEY definition.

    private boolean alreadyRated(Connection con, int jobId, String ratingBy,
                                  int employerId, int jobseekerId)
            throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM ratings " +
            "WHERE job_id = ? AND rating_by = ? " +
            "  AND employer_id = ? AND jobseeker_id = ?"
        );
        ps.setInt(1, jobId);
        ps.setString(2, ratingBy);
        ps.setInt(3, employerId);
        ps.setInt(4, jobseekerId);
        ResultSet rs = ps.executeQuery(); rs.next();
        int count = rs.getInt(1);
        rs.close(); ps.close();
        return count > 0;
    }

    // ── Utility ───────────────────────────────────────────────────────────────

    private int parseOr(String val, int fallback) {
        if (val == null || val.trim().isEmpty()) return fallback;
        try { return Integer.parseInt(val.trim()); }
        catch (NumberFormatException e) { return fallback; }
    }

    private void setFlash(HttpSession session, String ratingBy,
                          String type, String msg) {
        if ("Employer".equals(ratingBy)) {
            session.setAttribute("ratingMsg_emp_" + type, msg);
        } else {
            session.setAttribute("ratingMsg_js_" + type, msg);
        }
    }

    private void redirectBack(HttpServletResponse response, String ratingBy)
            throws IOException {
        if ("Employer".equals(ratingBy)) {
            // FIXED: correct filename is emp_dash.jsp (not emp_dashboard.jsp)
            response.sendRedirect("emp_dash.jsp?section=reviews");
        } else {
            // FIXED: correct filename is jobseeker_dash.jsp (not jobseeker_dashboard.jsp)
            response.sendRedirect("jobseeker_dash.jsp?section=reviews");
        }
    }
}