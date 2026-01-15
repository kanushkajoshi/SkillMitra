package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/GetSubskillsServlet")
public class GetSubskillsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String skillId = request.getParameter("skillId"); // ✅ ID, not name
        List<Map<String, Object>> subskills = new ArrayList<>();

        if (skillId != null && !skillId.isEmpty()) {
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT subskill_id, subskill_name FROM subskill WHERE skill_id = ?")) {

                System.out.println("DB URL = " + con.getMetaData().getURL());
                System.out.println("Received skillId = " + skillId);

                ps.setInt(1, Integer.parseInt(skillId));

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("subskill_id"));
                    m.put("name", rs.getString("subskill_name"));
                    subskills.add(m);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.getWriter().print(new Gson().toJson(subskills));
    }
}
