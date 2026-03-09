package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateJobseekerProfileServlet")
public class UpdateJobseekerProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jid = (Integer) session.getAttribute("jobseekerId");

        String[] skills = request.getParameterValues("skills");
        String[] subskills = request.getParameterValues("subskills");

        try {

            Connection con = DBConnection.getConnection();

            // STEP 1: delete old skills
            PreparedStatement deleteSkills = con.prepareStatement(
                    "DELETE FROM jobseeker_skills WHERE jid=?");
            deleteSkills.setInt(1, jid);
            deleteSkills.executeUpdate();

            // STEP 2: insert new skills
            PreparedStatement insertSkill = con.prepareStatement(
                    "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");

            if (skills != null) {
                for (int i = 0; i < skills.length; i++) {

                    insertSkill.setInt(1, jid);
                    insertSkill.setInt(2, Integer.parseInt(skills[i]));
                    insertSkill.setInt(3, Integer.parseInt(subskills[i]));

                    insertSkill.executeUpdate();
                }
            }

            con.close();

            // STEP 3: redirect dashboard
            response.sendRedirect("jobseeker_dash.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}