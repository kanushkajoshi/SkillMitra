package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
@WebServlet("/EditJobServlet")
public class EditJobServlet extends HttpServlet {

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

        PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM jobs WHERE job_id = ? AND eid = ?"
        );

        ps.setInt(1, jobId);
        ps.setInt(2, employerId);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            request.setAttribute("job_id", rs.getInt("job_id"));
            request.setAttribute("title", rs.getString("title"));
            request.setAttribute("description", rs.getString("description"));
            request.setAttribute("locality", rs.getString("locality"));
            request.setAttribute("city", rs.getString("city"));
            request.setAttribute("state", rs.getString("state"));
            request.setAttribute("country", rs.getString("country"));
            request.setAttribute("salary", rs.getString("salary"));
            request.setAttribute("min_salary", rs.getString("min_salary"));
            request.setAttribute("experience_level", rs.getString("experience_level"));
            request.setAttribute("job_type", rs.getString("job_type"));
            request.setAttribute("languages_preferred", rs.getString("languages_preferred"));
            request.setAttribute("zip", rs.getString("zip"));

            request.getRequestDispatcher("edit_job.jsp")
                   .forward(request, response);
        }

        con.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
}
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);

    if (session == null || session.getAttribute("eid") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int employerId = (int) session.getAttribute("eid");

    int jobId = Integer.parseInt(request.getParameter("job_id"));
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String locality = request.getParameter("locality");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String salary = request.getParameter("salary");
    String minSalary = request.getParameter("min_salary");
    String experience = request.getParameter("experience_level");
    String jobType = request.getParameter("job_type");
    String languages = request.getParameter("languages_preferred");
    String zip = request.getParameter("zip");

    try {
        Class.forName("com.mysql.jdbc.Driver");

        Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
        );

        PreparedStatement ps = con.prepareStatement(
                "UPDATE jobs SET title=?, description=?, locality=?, city=?, state=?, country=?, salary=?, min_salary=?, experience_level=?, job_type=?, languages_preferred=?, zip=? WHERE job_id=? AND eid=?"
        );

        ps.setString(1, title);
        ps.setString(2, description);
        ps.setString(3, locality);
        ps.setString(4, city);
        ps.setString(5, state);
        ps.setString(6, country);
        ps.setString(7, salary);
        ps.setString(8, minSalary);
        ps.setString(9, experience);
        ps.setString(10, jobType);
        ps.setString(11, languages);
        ps.setString(12, zip);
        ps.setInt(13, jobId);
        ps.setInt(14, employerId);

        ps.executeUpdate();

        con.close();

       response.sendRedirect(request.getContextPath() + "/emp_dash.jsp?section=manageJobs");


    } catch (Exception e) {
        e.printStackTrace();
    }
}


}
