package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EditJobServlet")
public class EditJobServlet extends HttpServlet {

    // =========================================
    // 🔹 LOAD EDIT FORM
    // =========================================
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employerId = (int) session.getAttribute("eid");
        int jobId = Integer.parseInt(request.getParameter("job_id"));

        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "")) {

            Class.forName("com.mysql.jdbc.Driver");

            // 🔹 Fetch job
            PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM jobs WHERE job_id=? AND eid=?");
            ps.setInt(1, jobId);
            ps.setInt(2, employerId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                // ---------------- BASIC FIELDS ----------------
                request.setAttribute("job_id", rs.getInt("job_id"));
                request.setAttribute("title", rs.getString("title"));
                request.setAttribute("description", rs.getString("description"));
                request.setAttribute("locality", rs.getString("locality"));
                request.setAttribute("city", rs.getString("city"));
                request.setAttribute("state", rs.getString("state"));
                request.setAttribute("country", rs.getString("country"));
                request.setAttribute("zip", rs.getString("zip"));
                request.setAttribute("salary", rs.getString("salary"));
                request.setAttribute("min_salary", rs.getString("min_salary"));
                request.setAttribute("job_type", rs.getString("job_type"));
                request.setAttribute("experience_required", rs.getString("experience_required"));
                request.setAttribute("languages_preferred", rs.getString("languages_preferred"));
                request.setAttribute("workers_required", rs.getInt("workers_required"));
                request.setAttribute("working_hours", rs.getString("working_hours"));
                request.setAttribute("gender_preference", rs.getString("gender_preference"));
                request.setAttribute("expiry_date", rs.getDate("expiry_date"));

                // ---------------- FETCH SKILL ID ----------------
                PreparedStatement psSkillId = con.prepareStatement(
                        "SELECT skill_id FROM job_skills WHERE job_id=? LIMIT 1");
                psSkillId.setInt(1, jobId);

                ResultSet rsSkillId = psSkillId.executeQuery();

                int skillId = 0;
                if (rsSkillId.next()) {
                    skillId = rsSkillId.getInt("skill_id");
                }

                request.setAttribute("skill_id", skillId);

                // ---------------- FETCH SELECTED SUBSKILLS ----------------
                PreparedStatement psSelected = con.prepareStatement(
                        "SELECT subskill_id FROM job_skills WHERE job_id=?");
                psSelected.setInt(1, jobId);

                ResultSet rsSelected = psSelected.executeQuery();

                List<Integer> selectedSubskills = new ArrayList<>();
                while (rsSelected.next()) {
                    selectedSubskills.add(rsSelected.getInt("subskill_id"));
                }

                request.setAttribute("selectedSubskills", selectedSubskills);

                // ---------------- FETCH ONLY SUBSKILLS OF THIS SKILL ----------------
                PreparedStatement psAllSub = con.prepareStatement(
                        "SELECT subskill_id, subskill_name FROM subskill WHERE skill_id=?");
                psAllSub.setInt(1, skillId);

                ResultSet rsAllSub = psAllSub.executeQuery();

                List<Map<String, Object>> allSubskills = new ArrayList<>();

                while (rsAllSub.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rsAllSub.getInt("subskill_id"));
                    map.put("name", rsAllSub.getString("subskill_name"));
                    allSubskills.add(map);
                }

                request.setAttribute("allSubskills", allSubskills);

                request.getRequestDispatcher("edit_job.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // =========================================
    // 🔹 UPDATE JOB
    // =========================================
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int employerId = (int) session.getAttribute("eid");
        int jobId = Integer.parseInt(request.getParameter("job_id"));

        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "")) {

            Class.forName("com.mysql.jdbc.Driver");

            con.setAutoCommit(false);

            // ================= UPDATE JOB =================
            String sql = "UPDATE jobs SET " +
                    "title=?, description=?, locality=?, city=?, state=?, country=?, zip=?, " +
                    "salary=?, min_salary=?, job_type=?, experience_required=?, languages_preferred=?, " +
                    "workers_required=?, working_hours=?, gender_preference=?, expiry_date=? " +
                    "WHERE job_id=? AND eid=?";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, request.getParameter("title"));
            ps.setString(2, request.getParameter("description"));
            ps.setString(3, request.getParameter("locality"));
            ps.setString(4, request.getParameter("city"));
            ps.setString(5, request.getParameter("state"));
            ps.setString(6, request.getParameter("country"));
            ps.setString(7, request.getParameter("zip"));
            ps.setString(8, request.getParameter("salary"));

            String minSalary = request.getParameter("min_salary");
            if (minSalary != null && !minSalary.trim().isEmpty())
                ps.setInt(9, Integer.parseInt(minSalary));
            else
                ps.setNull(9, Types.INTEGER);

            ps.setString(10, request.getParameter("job_type"));
            ps.setString(11, request.getParameter("experience_required"));

            String[] langs = request.getParameterValues("languages_preferred");
            String languageString = (langs != null) ? String.join(",", langs) : null;
            ps.setString(12, languageString);

            String workersStr = request.getParameter("workers_required");
            if (workersStr != null && !workersStr.trim().isEmpty())
                ps.setInt(13, Integer.parseInt(workersStr));
            else
                ps.setNull(13, Types.INTEGER);

            ps.setString(14, request.getParameter("working_hours"));
            ps.setString(15, request.getParameter("gender_preference"));

            String expiryDate = request.getParameter("expiry_date");
            if (expiryDate != null && !expiryDate.trim().isEmpty())
                ps.setDate(16, java.sql.Date.valueOf(expiryDate));
            else
                ps.setNull(16, Types.DATE);

            ps.setInt(17, jobId);
            ps.setInt(18, employerId);

            ps.executeUpdate();

            // ================= UPDATE JOB_SKILLS =================

            // 🔹 FIRST get skill_id safely from hidden field
            int skillId = 0;
            String skillIdStr = request.getParameter("skill_id");

            if (skillIdStr != null && !skillIdStr.trim().isEmpty()) {
                skillId = Integer.parseInt(skillIdStr);
            }

            // 🔹 Delete old mappings
            PreparedStatement psDelete = con.prepareStatement(
                    "DELETE FROM job_skills WHERE job_id=?");
            psDelete.setInt(1, jobId);
            psDelete.executeUpdate();

            // 🔹 Insert new mappings
            String[] subskills = request.getParameterValues("selectedSubskills");

            if (subskills != null && skillId != 0) {

                for (String subId : subskills) {

                    PreparedStatement psInsert = con.prepareStatement(
                            "INSERT INTO job_skills (job_id, skill_id, subskill_id) VALUES (?, ?, ?)");

                    psInsert.setInt(1, jobId);
                    psInsert.setInt(2, skillId);
                    psInsert.setInt(3, Integer.parseInt(subId));

                    psInsert.executeUpdate();
                }
            }

            con.commit();

            response.sendRedirect(request.getContextPath() +
                    "/emp_dash.jsp?section=manageJobs");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
