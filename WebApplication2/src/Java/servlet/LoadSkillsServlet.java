import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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
 System.out.println(">>> LoadSkillsServlet HIT <<<");
        List<String> skills = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                 con.prepareStatement("SELECT skill_name FROM skill ORDER BY skill_name");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                skills.add(rs.getString("skill_name"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("skills", skills);

        // ✅ forward ONLY once
        request.getRequestDispatcher("/jobseeker_register.jsp")
               .forward(request, response);
    }
}

