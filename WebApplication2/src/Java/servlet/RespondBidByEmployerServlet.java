package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RespondBidByEmployerServlet")
public class RespondBidByEmployerServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bidId = Integer.parseInt(request.getParameter("bid_id"));
        String action = request.getParameter("action"); // accept or reject

        String newStatus = null;
        if("accept".equalsIgnoreCase(action)){
            newStatus = "Accepted";   // ✅ FIXED HERE
        } else if("reject".equalsIgnoreCase(action)){
            newStatus = "Rejected";
        } else {
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
            return;
        }

        Connection con = null;

        try{
            con = DBConnection.getConnection();

            // 🔹 1. Get job_id and jobseeker_id
            int jobId = 0;
            int jobSeekerId = 0;
            PreparedStatement psGet = con.prepareStatement(
                "SELECT job_id, job_seeker_id FROM bids WHERE bid_id=?"
            );
            psGet.setInt(1, bidId);
            ResultSet rs = psGet.executeQuery();
            if(rs.next()){
                jobId = rs.getInt("job_id");
                jobSeekerId = rs.getInt("job_seeker_id");
            }
            rs.close();
            psGet.close();

            // 🔹 2. Update bids table with employer decision
            PreparedStatement psUpdateBid = con.prepareStatement(
                "UPDATE bids SET bid_status=? WHERE bid_id=?"
            );
            psUpdateBid.setString(1, newStatus);
            psUpdateBid.setInt(2, bidId);
            psUpdateBid.executeUpdate();
            psUpdateBid.close();

            // 🔹 3. Update applications table accordingly
            String appStatus = null;
            if("Accepted".equals(newStatus)){   // ✅ FIXED HERE
                appStatus = "Accepted";
            } else if("RejectedByEmployer".equals(newStatus)){
                appStatus = "Rejected";
            }

            PreparedStatement psUpdateApp = con.prepareStatement(
                "UPDATE applications SET status=? WHERE job_id=? AND jobseeker_id=?"
            );
            psUpdateApp.setString(1, appStatus);
            psUpdateApp.setInt(2, jobId);
            psUpdateApp.setInt(3, jobSeekerId);
            psUpdateApp.executeUpdate();
            psUpdateApp.close();

            // 🔹 4. If accepted → check workers_required and close job if limit reached
            if("Accepted".equals(newStatus)){   // ✅ FIXED HERE
                PreparedStatement psCount = con.prepareStatement(
                    "SELECT COUNT(*) FROM applications WHERE job_id=? AND status='Accepted'"
                );
                psCount.setInt(1, jobId);
                ResultSet rsCount = psCount.executeQuery();
                int acceptedCount = 0;
                if(rsCount.next()) acceptedCount = rsCount.getInt(1);
                rsCount.close();
                psCount.close();

                PreparedStatement psReq = con.prepareStatement(
                    "SELECT workers_required FROM jobs WHERE job_id=?"
                );
                psReq.setInt(1, jobId);
                ResultSet rsReq = psReq.executeQuery();
                int required = 0;
                if(rsReq.next()) required = rsReq.getInt("workers_required");
                rsReq.close();
                psReq.close();

                if(acceptedCount >= required){
                    PreparedStatement psClose = con.prepareStatement(
                        "UPDATE jobs SET status='Closed' WHERE job_id=?"
                    );
                    psClose.setInt(1, jobId);
                    psClose.executeUpdate();
                    psClose.close();
                }
            }

            // Redirect to correct section after accept/reject
            if("Accepted".equalsIgnoreCase(newStatus)){   // ✅ FIXED HERE
                response.sendRedirect("emp_dash.jsp?section=acceptedApplications");
            } else if("RejectedByEmployer".equalsIgnoreCase(newStatus)){
                response.sendRedirect("emp_dash.jsp?section=rejectedApplications");
            } else {
                response.sendRedirect("emp_dash.jsp?section=reviewApplications");
            }

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("emp_dash.jsp?section=reviewApplications");
        } finally {
            try{ if(con!=null) con.close(); } catch(Exception e){}
        }
    }
}