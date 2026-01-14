package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/GetSubskillsServlet")
public class GetSubskillsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String skillName = request.getParameter("skill");
        List<String> subskills = new ArrayList<>();

        if (skillName != null && !skillName.trim().isEmpty()) {
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT ss.subskill_name " +
                     "FROM subskill ss " +
                     "JOIN skill s ON ss.skill_id = s.skill_id " +
                     "WHERE LOWER(s.skill_name) = LOWER(?)")) {

                ps.setString(1, skillName.trim());

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    subskills.add(rs.getString("subskill_name"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.getWriter().print(new Gson().toJson(subskills));
    }
}
