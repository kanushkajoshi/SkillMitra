package servlet;
import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/jobseeker-register")
public class LoadSkillsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> skills = new ArrayList<>();
System.out.println("LoadSkillsServlet HIT, skills=" + skills.size());

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                 con.prepareStatement("SELECT skill_id, skill_name FROM skill ORDER BY skill_name");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> skill = new HashMap<>();
                skill.put("id", rs.getInt("skill_id"));
                skill.put("name", rs.getString("skill_name"));
                skills.add(skill);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("skills", skills);
        request.getRequestDispatcher("/jobseeker_register.jsp")
               .forward(request, response);
    }
}
