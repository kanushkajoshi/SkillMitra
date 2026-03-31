package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import db.DBConnection;

@WebServlet("/SearchSuggestionServlet")
public class SearchSuggestionServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        String q = req.getParameter("q");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("jobseekerId") == null) {
            res.getWriter().write("[]");
            return;
        }

        if (q == null || q.trim().isEmpty()) {
            res.getWriter().write("[]");
            return;
        }

        int jid = (Integer) session.getAttribute("jobseekerId");
        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try (Connection con = DBConnection.getConnection()) {

            // ── Subskills matching jobseeker's skills ──
            PreparedStatement ps1 = con.prepareStatement(
                "SELECT DISTINCT ss.subskill_name " +
                "FROM subskill ss " +
                "JOIN job_skills jk ON jk.subskill_id = ss.subskill_id " +
                "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
                "WHERE js.jid = ? AND LOWER(ss.subskill_name) LIKE LOWER(?) " +
                "LIMIT 5"
            );
            ps1.setInt(1, jid);
            ps1.setString(2, "%" + q + "%");
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                if (!first) json.append(",");
                json.append("\"")
                    .append(rs1.getString("subskill_name").replace("\"", "\\\""))
                    .append("\"");
                first = false;
            }
            rs1.close();
            ps1.close();

            // ── Job Titles ──
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT DISTINCT title FROM jobs " +
                "WHERE LOWER(title) LIKE LOWER(?) AND status='Active' " +
                "LIMIT 5"
            );
            ps2.setString(1, "%" + q + "%");
            ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                if (!first) json.append(",");
                json.append("\"")
                    .append(rs2.getString("title").replace("\"", "\\\""))
                    .append("\"");
                first = false;
            }
            rs2.close();
            ps2.close();

            // ── Localities / Areas ──
            PreparedStatement ps3 = con.prepareStatement(
                "SELECT DISTINCT locality FROM jobs " +
                "WHERE LOWER(locality) LIKE LOWER(?) AND status='Active' " +
                "LIMIT 5"
            );
            ps3.setString(1, "%" + q + "%");
            ResultSet rs3 = ps3.executeQuery();
            while (rs3.next()) {
                if (!first) json.append(",");
                json.append("\"")
                    .append(rs3.getString("locality").replace("\"", "\\\""))
                    .append("\"");
                first = false;
            }
            rs3.close();
            ps3.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("]");
        res.getWriter().write(json.toString());
    }
}