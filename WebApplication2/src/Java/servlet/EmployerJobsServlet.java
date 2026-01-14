package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


@WebServlet("/EmployerJobsServlet")
public class EmployerJobsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employerId = (Integer) session.getAttribute("employerId");

        List<Map<String, String>> jobs;
        jobs = new ArrayList<Map<String, String>>();


        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", ""
            );

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM jobs WHERE employer_id = ? ORDER BY created_at DESC"
            );
            ps.setInt(1, employerId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> job = new HashMap<>();
                job.put("job_id", rs.getString("job_id"));
                job.put("job_title", rs.getString("job_title"));
                job.put("job_location", rs.getString("job_location"));
                job.put("job_city", rs.getString("job_city"));
                job.put("wage", rs.getString("wage"));
                job.put("job_type", rs.getString("job_type"));
                job.put("created_at", rs.getString("created_at"));

                jobs.add(job);
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("jobs", jobs);
        request.getRequestDispatcher("emp_dash.jsp")
               .forward(request, response);
    }
}
