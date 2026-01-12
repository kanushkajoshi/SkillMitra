

import java.io.IOException;
import java.sql.*;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
@WebServlet("/PostJobServlet")
public class PostJobServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employerId = (Integer) session.getAttribute("employerId");

        String jobTitle = request.getParameter("job_title");
        String jobDescription = request.getParameter("job_description");
        String jobLocation = request.getParameter("job_location");
        String city = request.getParameter("job_city");
        String state = request.getParameter("job_state");
        String country = request.getParameter("job_country");
        String zip = request.getParameter("zip");
        String jobType = request.getParameter("job_type");

        int wage = Integer.parseInt(request.getParameter("wage"));
        String maxSalaryStr = request.getParameter("max_salary");
        Integer maxSalary = (maxSalaryStr == null || maxSalaryStr.isEmpty())
                ? null
                : Integer.parseInt(maxSalaryStr);

        String[] skills = request.getParameterValues("skills");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", ""
            );

            String jobSql =
                "INSERT INTO jobs (employer_id, job_title, job_description, job_location, " +
                "job_city, job_state, job_country, zip, max_salary, wage, job_type) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(jobSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, employerId);
            ps.setString(2, jobTitle);
            ps.setString(3, jobDescription);
            ps.setString(4, jobLocation);
            ps.setString(5, city);
            ps.setString(6, state);
            ps.setString(7, country);
            ps.setString(8, zip);

            if (maxSalary == null)
                ps.setNull(9, Types.INTEGER);
            else
                ps.setInt(9, maxSalary);

            ps.setInt(10, wage);
            ps.setString(11, jobType);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int jobId = 0;
            if (rs.next()) jobId = rs.getInt(1);

            PreparedStatement skillPs =
                con.prepareStatement("INSERT INTO job_skills (job_id, skill) VALUES (?, ?)");

            if (skills != null) {
                for (String skill : skills) {
                    skillPs.setInt(1, jobId);
                    skillPs.setString(2, skill);
                    skillPs.addBatch();
                }
                skillPs.executeBatch();
            }

            con.close();
            response.sendRedirect("EmployerJobsServlet");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
