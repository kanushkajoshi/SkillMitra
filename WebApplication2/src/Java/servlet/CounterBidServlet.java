package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CounterBidServlet")
public class CounterBidServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        int bidId = Integer.parseInt(request.getParameter("bid_id"));
        int counterAmount = Integer.parseInt(request.getParameter("counter_amount"));

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            PreparedStatement ps = con.prepareStatement(
                "UPDATE bids SET counter_bid=?, bid_status='Countered' WHERE bid_id=?"
            );

            ps.setInt(1, counterAmount);
            ps.setInt(2, bidId);
            ps.executeUpdate();

            con.close();

            response.sendRedirect("emp_dash.jsp?section=reviewBids");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}