package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/post-job")
public class PostJobPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        // 🔐 Employer login check
        HttpSession session = request.getSession(false);
        System.out.println("EID in session = " + 
            (session != null ? session.getAttribute("eid") : "NO SESSION"));
        if (session == null || session.getAttribute("eid") == null) {
    response.sendRedirect(request.getContextPath() + "/employer_login.jsp");
    return;
}


        List<String> skills = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps =
                con.prepareStatement("SELECT skill_name FROM skill");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                skills.add(rs.getString("skill_name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("skills", skills);
        request.getRequestDispatcher("/post_job.jsp")
               .forward(request, response);
    }
}
