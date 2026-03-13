package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateBidStatusServlet")
public class UpdateBidStatusServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        int bidId = Integer.parseInt(request.getParameter("bid_id"));
        String status = request.getParameter("status");

        try {

            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            // 1️⃣ Update bid status
            PreparedStatement ps = con.prepareStatement(
                    "UPDATE bids SET bid_status=? WHERE bid_id=?"
            );

            ps.setString(1, status);
            ps.setInt(2, bidId);
            ps.executeUpdate();

            // 2️⃣ Get job_id and job_seeker_id from bid
            PreparedStatement ps2 = con.prepareStatement(
                    "SELECT job_id, job_seeker_id FROM bids WHERE bid_id=?"
            );

            ps2.setInt(1, bidId);
            ResultSet rs = ps2.executeQuery();

            if (rs.next()) {

                int jobId = rs.getInt("job_id");
                int jobSeekerId = rs.getInt("job_seeker_id");

                // 3️⃣ Update application status
                PreparedStatement ps3 = con.prepareStatement(
                        "UPDATE applications SET status=? WHERE job_id=? AND jobseeker_id=?"
                );

                ps3.setString(1, status);
                ps3.setInt(2, jobId);
                ps3.setInt(3, jobSeekerId);
                ps3.executeUpdate();

                ps3.close();
            }

            rs.close();
            ps.close();
            ps2.close();
            con.close();

            response.sendRedirect("emp_dash.jsp?section=reviewBids");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}