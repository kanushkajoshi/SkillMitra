package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/PostJobServlet")
public class PostJobServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int eid = (Integer) session.getAttribute("eid");

        int skillId = Integer.parseInt(request.getParameter("skill_id"));
        int subskillId = Integer.parseInt(request.getParameter("jobSubskill"));

        String jobTitle = request.getParameter("job_title");
        String jobDescription = request.getParameter("job_description");
        String jobLocation = request.getParameter("job_location");
        String city = request.getParameter("job_city");
        String state = request.getParameter("job_state");
        String country = request.getParameter("job_country");
        String zip = request.getParameter("zip");
        String jobType = request.getParameter("job_type");
        String experience = request.getParameter("experience_level");
        String salary = request.getParameter("wage");
        String languages = request.getParameter("languages_preferred");

        String maxSalaryStr = request.getParameter("max_salary");
        Integer maxSalary = (maxSalaryStr == null || maxSalaryStr.isEmpty())
                ? null
                : Integer.parseInt(maxSalaryStr);

        Connection con = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
            );

            // 🔹 1. Insert into jobs (NO skill columns here)
            String jobSql =
                "INSERT INTO jobs " +
                "(eid, title, description, locality, city, state, country, salary, zip, min_salary, experience_level, job_type, languages_preferred) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement psJob =
                con.prepareStatement(jobSql, Statement.RETURN_GENERATED_KEYS);

            psJob.setInt(1, eid);
            psJob.setString(2, jobTitle);
            psJob.setString(3, jobDescription);
            psJob.setString(4, jobLocation);
            psJob.setString(5, city);
            psJob.setString(6, state);
            psJob.setString(7, country);
            psJob.setString(8, salary);
            psJob.setString(9, zip);

            if (maxSalary == null)
                psJob.setNull(10, Types.INTEGER);
            else
                psJob.setInt(10, maxSalary);

            psJob.setString(11, experience);
            psJob.setString(12, jobType);
            psJob.setString(13, languages);

            psJob.executeUpdate();

            // 🔹 2. Get generated job_id
            ResultSet rs = psJob.getGeneratedKeys();
            if (!rs.next()) {
                throw new RuntimeException("Failed to get job_id");
            }
            int jobId = rs.getInt(1);

            // 🔹 3. Insert into job_skills
            PreparedStatement psSkill = con.prepareStatement(
                "INSERT INTO job_skills (job_id, skill_id, subskill_id) VALUES (?, ?, ?)"
            );
            psSkill.setInt(1, jobId);
            psSkill.setInt(2, skillId);
            psSkill.setInt(3, subskillId);
            psSkill.executeUpdate();

            con.close();

            session.setAttribute("jobSuccess", "Job posted successfully!");
            response.sendRedirect(request.getContextPath() + "/emp_dash.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            e.printStackTrace(response.getWriter());
        }
    }
}
