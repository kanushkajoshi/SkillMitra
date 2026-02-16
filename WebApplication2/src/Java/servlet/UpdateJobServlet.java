/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateJobServlet")
public class UpdateJobServlet extends HttpServlet {

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
        String salary = request.getParameter("salary");

        try {
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            PreparedStatement ps = con.prepareStatement(
                    "UPDATE jobs SET title=?, description=?, salary=? WHERE job_id=? AND eid=?"
            );

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, salary);
            ps.setInt(4, jobId);
            ps.setInt(5, employerId);

            ps.executeUpdate();

            con.close();

            session.setAttribute("jobSuccess", "Job updated successfully!");
            response.sendRedirect("emp_dash.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
