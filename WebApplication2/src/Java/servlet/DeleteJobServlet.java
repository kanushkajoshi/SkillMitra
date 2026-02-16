package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteJobServlet")
public class DeleteJobServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employerId = (int) session.getAttribute("eid");
        int jobId = Integer.parseInt(request.getParameter("job_id"));

        try {
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            // VERY IMPORTANT: delete only if job belongs to this employer
            PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM jobs WHERE job_id = ? AND eid = ?"
            );

            ps.setInt(1, jobId);
            ps.setInt(2, employerId);

            ps.executeUpdate();

            con.close();

            session.setAttribute("jobSuccess", "Job deleted successfully!");
            response.sendRedirect(request.getContextPath() + "/emp_dash.jsp?section=manageJobs");


        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
