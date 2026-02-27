package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import db.DBConnection;

@WebServlet("/MatchedJobsServlet")
public class MatchedJobsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jobseekerId = (int) session.getAttribute("jobseekerId");

        List<Map<String, Object>> matchedJobs = new ArrayList<>();

        try {
            Connection con = DBConnection.getConnection();

            String sql =
                "SELECT DISTINCT j.job_id, j.title, j.description, j.city, j.salary, j.job_type, j.expiry_date " +
                "FROM jobs j " +
                "JOIN job_skills jk ON j.job_id = jk.job_id " +
                "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
                "AND js.subskill_id = jk.subskill_id " +
                "WHERE js.jid = ? " +
                "AND j.expiry_date >= CURDATE()";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, jobseekerId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Map<String, Object> job = new HashMap<>();

                job.put("job_id", rs.getInt("job_id"));
                job.put("title", rs.getString("title"));
                job.put("description", rs.getString("description"));
                job.put("city", rs.getString("city"));
                job.put("salary", rs.getInt("salary"));
                job.put("job_type", rs.getString("job_type"));
                job.put("expiry_date", rs.getDate("expiry_date"));

                matchedJobs.add(job);
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("matchedJobs", matchedJobs);
        request.getRequestDispatcher("jobseeker_dash.jsp")
               .forward(request, response);
    }
}