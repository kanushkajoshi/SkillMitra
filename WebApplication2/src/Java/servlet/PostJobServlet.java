package servlet;



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
        if (session == null || session.getAttribute("eid") == null) {
    response.sendRedirect("login.jsp");
    return;
}

int eid = (Integer) session.getAttribute("eid");


        String skillName = request.getParameter("jobSkill");
        String subskillName = request.getParameter("jobSubskill");

        // Job title = selected skill
        String jobTitle = skillName;

        String jobDescription = request.getParameter("job_description");
        String jobLocation = request.getParameter("job_location");
        String city = request.getParameter("job_city");
        String state = request.getParameter("job_state");
        String country = request.getParameter("job_country");
        String zip = request.getParameter("zip");
        String jobType = request.getParameter("job_type");
        

        String salary = request.getParameter("wage"); // treat as STRING

        String maxSalaryStr = request.getParameter("max_salary");
        Integer maxSalary = (maxSalaryStr == null || maxSalaryStr.isEmpty())
                ? null
                : Integer.parseInt(maxSalaryStr);

        

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", ""
            );

            String jobSql =
"INSERT INTO jobs " +
"(eid, title, description, locality, city, state, country, salary, zip, min_salary, experience_level, job_type, languages_preferred) " +
"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";




            PreparedStatement ps =
        con.prepareStatement(jobSql, Statement.RETURN_GENERATED_KEYS);

ps.setInt(1, eid);
ps.setString(2, jobTitle);
ps.setString(3, jobDescription);
ps.setString(4, jobLocation);
ps.setString(5, city);
ps.setString(6, state);
ps.setString(7, country);              // ✅ FIX: country added
ps.setString(8, salary);
ps.setString(9, zip);

if (maxSalary == null)
    ps.setNull(10, Types.INTEGER);
else
    ps.setInt(10, maxSalary);

ps.setString(11, request.getParameter("experience_level"));
ps.setString(12, jobType);
ps.setString(13, request.getParameter("languages_preferred"));


            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int jobId = 0;
            if (rs.next()) jobId = rs.getInt(1);

            

            con.close();

// ✅ success message in session
session.setAttribute("jobSuccess", "Job posted successfully!");

// ✅ redirect directly to employer dashboard
response.sendRedirect(request.getContextPath() + "/emp_dash.jsp");

        }
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.sendRedirect("error.jsp");
//        }
catch (Exception e) {
    e.printStackTrace();
    response.setContentType("text/plain");
    e.printStackTrace(response.getWriter());
}

    }
}
