package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import db.DBConnection;

@WebServlet("/PostJobServlet")
public class PostJobServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("eid") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int eid = (Integer) session.getAttribute("eid");

        // 🔹 Skill & Subskills
        String skillIdStr = request.getParameter("skill_id");
        String subskillsString = request.getParameter("selectedSubskills");

        String[] subskills = null;
        if (subskillsString != null && !subskillsString.isEmpty()) {
            subskills = subskillsString.split(",");
        }

        // 🔹 Job Basic Info
        String jobTitle = request.getParameter("job_title");
        String jobDescription = request.getParameter("job_description");
        String locality = request.getParameter("job_location");
        String city = request.getParameter("job_city");
        String state = request.getParameter("job_state");
        String country = request.getParameter("job_country");
        String zip = request.getParameter("zip");

        String wage = request.getParameter("wage");
        String maxSalaryStr = request.getParameter("max_salary");
        String[] languages = request.getParameterValues("languages_preferred");

        String languageString = null;
        if (languages != null) {
            languageString = String.join(",", languages);
        }

        String jobType = request.getParameter("job_type");
        String experienceRequired = request.getParameter("experience_required");
        String workersRequiredStr = request.getParameter("workers_required");
        String workingHours = request.getParameter("working_hours");
        String genderPreference = request.getParameter("gender_preference");
        String expiryDate = request.getParameter("expiry_date");

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 🔥 INSERT INTO jobs
            String jobSql = "INSERT INTO jobs " +
                    "(eid, title, description, locality, city, state, country, zip, salary, min_salary, job_type, experience_required, languages_preferred, workers_required, working_hours, gender_preference, expiry_date) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement psJob = con.prepareStatement(jobSql, Statement.RETURN_GENERATED_KEYS);

            psJob.setInt(1, eid);
            psJob.setString(2, jobTitle);
            psJob.setString(3, jobDescription);
            psJob.setString(4, locality);
            psJob.setString(5, city);
            psJob.setString(6, state);
            psJob.setString(7, country);
            psJob.setString(8, zip);
            psJob.setString(9, wage);

            if (maxSalaryStr == null || maxSalaryStr.isEmpty())
                psJob.setNull(10, Types.INTEGER);
            else
                psJob.setInt(10, Integer.parseInt(maxSalaryStr));

            psJob.setString(11, jobType);
            psJob.setString(12, experienceRequired);
            psJob.setString(13, languageString);
            psJob.setInt(14, Integer.parseInt(workersRequiredStr));
            psJob.setString(15, workingHours);
            psJob.setString(16, genderPreference);
            psJob.setDate(17, Date.valueOf(expiryDate));

            psJob.executeUpdate();

            // 🔥 Get job_id
            ResultSet rs = psJob.getGeneratedKeys();
            rs.next();
            int jobId = rs.getInt(1);

            // 🔥 INSERT INTO job_skills
            if (subskills != null && skillIdStr != null) {

                int skillId = Integer.parseInt(skillIdStr);

                String skillInsertSql =
                        "INSERT INTO job_skills (job_id, skill_id, subskill_id) VALUES (?, ?, ?)";

                PreparedStatement psSkill = con.prepareStatement(skillInsertSql);

                for (String subId : subskills) {
                    psSkill.setInt(1, jobId);
                    psSkill.setInt(2, skillId);
                    psSkill.setInt(3, Integer.parseInt(subId));
                    psSkill.addBatch();
                }

                psSkill.executeBatch();
            }

            con.commit();
            con.close();

            response.sendRedirect("emp_dash.jsp?section=manageJobs");

        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (Exception ignored) {}
            e.printStackTrace();
            response.sendRedirect("emp_dash.jsp?section=manageJobs");
        }
    }
}