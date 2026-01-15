package servlet;

import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/JobSeekerRegisterServlet")
public class JobSeekerRegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1️⃣ Read form data
        String firstName    = request.getParameter("jfirstname");
        String lastName     = request.getParameter("jlastname");
        String email        = request.getParameter("jemail");
        String phone        = request.getParameter("jphone");
        String password     = request.getParameter("jpwd");
        String education    = request.getParameter("jeducation");
        String country      = request.getParameter("jcountry");
        String state        = request.getParameter("jstate");
        String city         = request.getParameter("jcity");
        String skillName    = request.getParameter("skill");
        String subskillName = request.getParameter("subskill");
        String dob          = request.getParameter("jdob");

        java.sql.Date sqlDob = java.sql.Date.valueOf(dob);

        // 2️⃣ Server-side validation
        if (!phone.matches("^[6-9][0-9]{9}$")) {
            request.setAttribute("phoneError", "Invalid phone number");
            request.getRequestDispatcher("/jobseeker_register.jsp")
                   .forward(request, response);
            return;
        }

        if (!password.matches("^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$")) {
            request.setAttribute("passwordError", "Password must contain letters and numbers (min 6 chars)");
            request.getRequestDispatcher("/jobseeker_register.jsp")
                   .forward(request, response);
            return;
        }

        Connection con = null;

        try {
            // 3️⃣ DB Connection
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra",
                    "root",
                    ""
            );

            // 4️⃣ Check duplicate email
            PreparedStatement checkEmail =
                    con.prepareStatement("SELECT 1 FROM jobseeker WHERE jemail = ?");
            checkEmail.setString(1, email);

            ResultSet rsEmail = checkEmail.executeQuery();
            if (rsEmail.next()) {
                request.setAttribute("emailError", "Email already registered");
                request.getRequestDispatcher("/jobseeker_register.jsp")
                       .forward(request, response);
                return;
            }

            // 5️⃣ Insert Jobseeker
            String insertJobseeker =
                    "INSERT INTO jobseeker " +
                    "(jfirstname, jlastname, jemail, jphone, jpwd, jeducation, jcountry, jstate, jcity, jdob) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps =
                    con.prepareStatement(insertJobseeker, Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, password);
            ps.setString(6, education);
            ps.setString(7, country);
            ps.setString(8, state);
            ps.setString(9, city);
            ps.setDate(10, sqlDob);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (!rs.next()) {
                throw new RuntimeException("Failed to get Jobseeker ID");
            }
            int jobseekerId = rs.getInt(1);

            // 6️⃣ Fetch skill_id
            PreparedStatement psSkill =
                    con.prepareStatement("SELECT skill_id FROM skill WHERE skill_name = ?");
            psSkill.setString(1, skillName);

            ResultSet rsSkill = psSkill.executeQuery();
            if (!rsSkill.next()) {
                throw new RuntimeException("Skill not found: " + skillName);
            }
            int skillId = rsSkill.getInt("skill_id");

            // 7️⃣ Fetch subskill_id
            PreparedStatement psSub =
                    con.prepareStatement(
                            "SELECT subskill_id FROM subskill WHERE subskill_name = ? AND skill_id = ?");
            psSub.setString(1, subskillName);
            psSub.setInt(2, skillId);

            ResultSet rsSub = psSub.executeQuery();
            if (!rsSub.next()) {
                throw new RuntimeException("Subskill not found: " + subskillName);
            }
            int subskillId = rsSub.getInt("subskill_id");

            // 8️⃣ Insert into jobseeker_skills (LINK TABLE)
            PreparedStatement psLink =
    con.prepareStatement(
        "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");


            psLink.setInt(1, jobseekerId);
            psLink.setInt(2, skillId);
            psLink.setInt(3, subskillId);
            int result=psLink.executeUpdate();
            
            // 9️⃣ Close connection
            con.close();

            System.out.println("REGISTER SESSION jobseekerId = " + jobseekerId);
            if (result > 0) {
            HttpSession session = request.getSession();
            session.setAttribute("jobseekerId", jobseekerId);
session.setAttribute("jobseekerName", firstName);
session.setAttribute("jobseekerEmail", email);

            response.sendRedirect("jobseeker_dash.jsp");
        } else {
            response.sendRedirect("jobseeker_register.jsp?error=failed");
        }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/error.jsp");
        }
    }
}
