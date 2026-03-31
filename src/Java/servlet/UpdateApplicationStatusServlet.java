package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateApplicationStatusServlet")
public class UpdateApplicationStatusServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        int applicationId = Integer.parseInt(request.getParameter("application_id"));
        String status = request.getParameter("status");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            // 🔹 1. Update application status
            PreparedStatement ps = con.prepareStatement(
                    "UPDATE applications SET status=? WHERE application_id=?"
            );
            ps.setString(1, status);
            ps.setInt(2, applicationId);
            ps.executeUpdate();

            // ======================================================
            // 🔥 NEW LOGIC: WORKERS REQUIRED AUTO CLOSE
            // ======================================================

            int jobId = 0;

            // 🔹 2. Get job_id
            PreparedStatement psJobId = con.prepareStatement(
                    "SELECT job_id FROM applications WHERE application_id=?"
            );
            psJobId.setInt(1, applicationId);
            ResultSet rsJobId = psJobId.executeQuery();

            if (rsJobId.next()) {
                jobId = rsJobId.getInt("job_id");
            }

            // 🔹 3. ONLY if Accepted → check closing condition
            if ("Accepted".equalsIgnoreCase(status)) {

                // count accepted
                PreparedStatement psCount = con.prepareStatement(
                        "SELECT COUNT(*) FROM applications WHERE job_id=? AND status='Accepted'"
                );
                psCount.setInt(1, jobId);
                ResultSet rsCount = psCount.executeQuery();

                int acceptedCount = 0;
                if (rsCount.next()) {
                    acceptedCount = rsCount.getInt(1);
                }

                // get required workers
                PreparedStatement psReq = con.prepareStatement(
                        "SELECT workers_required FROM jobs WHERE job_id=?"
                );
                psReq.setInt(1, jobId);
                ResultSet rsReq = psReq.executeQuery();

                int required = 0;
                if (rsReq.next()) {
                    required = rsReq.getInt("workers_required");
                }

                // 🔹 close job if full
                if (acceptedCount >= required) {
                    PreparedStatement psClose = con.prepareStatement(
                            "UPDATE jobs SET status='Closed' WHERE job_id=?"
                    );
                    psClose.setInt(1, jobId);
                    psClose.executeUpdate();
                }
            }

            // ======================================================

            con.close();

            response.sendRedirect("emp_dash.jsp?section=reviewApplications");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}