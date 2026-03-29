package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/PlaceBidServlet")
public class PlaceBidServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔒 Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jobseekerId = (Integer) session.getAttribute("jobseekerId");
        int jobId = Integer.parseInt(request.getParameter("jobId"));
        int bidAmount = Integer.parseInt(request.getParameter("bidAmount"));

        try (Connection con = DBConnection.getConnection()) {

            // 🔹 Check if bid already exists
            String checkBidSql = "SELECT bid_id FROM bids WHERE job_id=? AND job_seeker_id=?";
            PreparedStatement psCheckBid = con.prepareStatement(checkBidSql);
            psCheckBid.setInt(1, jobId);
            psCheckBid.setInt(2, jobseekerId);
            ResultSet rsCheckBid = psCheckBid.executeQuery();

            if (rsCheckBid.next()) {
                // 🔹 Update existing bid
                int bidId = rsCheckBid.getInt("bid_id");

                String updateBidSql = "UPDATE bids SET bid_amount=?, bid_status='Pending', updated_at=CURRENT_TIMESTAMP WHERE bid_id=?";
                PreparedStatement psUpdateBid = con.prepareStatement(updateBidSql);
                psUpdateBid.setInt(1, bidAmount);
                psUpdateBid.setInt(2, bidId);
                psUpdateBid.executeUpdate();

            } else {
                // 🔹 Insert new bid
                String insertBidSql = "INSERT INTO bids (job_id, job_seeker_id, bid_amount, bid_status) VALUES (?, ?, ?, 'Pending')";
                PreparedStatement psInsertBid = con.prepareStatement(insertBidSql);
                psInsertBid.setInt(1, jobId);
                psInsertBid.setInt(2, jobseekerId);
                psInsertBid.setInt(3, bidAmount);
                psInsertBid.executeUpdate();
            }

            // 🔹 ✅ IMPORTANT: Remove any application insert/update here
            // Review Applications section will only show normal applications (is_bid=0)

            // 🔹 Redirect to Applied section so user sees job
            response.sendRedirect("jobseeker_dash.jsp?section=applied&msg=bidPlaced");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jobseeker_dash.jsp?section=applied&msg=error");
        }
    }
}