package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/post-job")
public class PostJobPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> skills = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                 con.prepareStatement("SELECT skill_id, skill_name FROM skill");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("skill_id"));
                m.put("name", rs.getString("skill_name"));
                skills.add(m);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("skills", skills);
        request.getRequestDispatcher("/post_job.jsp")
               .forward(request, response);
    }
}
