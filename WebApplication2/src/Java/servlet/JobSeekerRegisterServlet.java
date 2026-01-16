package servlet;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.Period;

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
        // ================= EMAIL FORMAT VALIDATION =================
String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.(com|org|net|in)$";

if (email == null || !email.matches(emailRegex)) {
    request.setAttribute("emailError", 
        "Invalid email address. Use a valid email like example@gmail.com");
    request.getRequestDispatcher("/jobseeker_register.jsp")
           .forward(request, response);
    return;
}
// ===========================================================

        String phone        = request.getParameter("jphone");
        String password     = request.getParameter("jpwd");
        String education    = request.getParameter("jeducation");
        String country      = request.getParameter("jcountry");
        String state        = request.getParameter("jstate");
        String city         = request.getParameter("jcity");
        String zip = request.getParameter("jzip");


        String dob          = request.getParameter("jdob");

        java.sql.Date sqlDob = java.sql.Date.valueOf(dob);
        // ================= AGE VALIDATION (16+ ONLY) =================
LocalDate dobDate = sqlDob.toLocalDate();
LocalDate today = LocalDate.now();

int age = Period.between(dobDate, today).getYears();

if (age < 16) {
    request.setAttribute("dobError", "You must be at least 16 years old to register.");
    request.getRequestDispatcher("/jobseeker_register.jsp")
           .forward(request, response);
    return;
}
// =============================================================


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
    "(jfirstname, jlastname, jemail, jphone, jpwd, jeducation, " +
    " jcountry, jstate, jcity, jzip, jdob) " +
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";


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
    ps.setString(10, zip);     // ✅ ADD THIS
ps.setDate(11, sqlDob);

    ps.executeUpdate();

    ResultSet rs = ps.getGeneratedKeys();
    if (!rs.next()) {
        throw new RuntimeException("Failed to get Jobseeker ID");
    }
    int jobseekerId = rs.getInt(1);

    // 🔥 NEW: read IDs directly from form
    int skillId = Integer.parseInt(request.getParameter("skill"));
    int subskillId = Integer.parseInt(request.getParameter("subskill"));

    // 6️⃣ Insert into jobseeker_skills (LINK TABLE)
    PreparedStatement psLink =
            con.prepareStatement(
                "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");

    psLink.setInt(1, jobseekerId);
    psLink.setInt(2, skillId);
    psLink.setInt(3, subskillId);

    int result = psLink.executeUpdate();

    con.close();

    // 7️⃣ Session + redirect
    if (result > 0) {
        HttpSession session = request.getSession(true);
        session.setAttribute("jobseekerId", jobseekerId);
        session.setAttribute("jobseekerName", firstName);
        session.setAttribute("jobseekerEmail", email);

        response.sendRedirect(request.getContextPath() + "/jobseeker_dash.jsp");

    } else {
        response.sendRedirect("jobseeker_register.jsp?error=failed");
    }
//        }catch (Exception e) {
//    e.printStackTrace();   // keep this
//    throw new ServletException(e); // better than silent redirect
}

 catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/error.jsp");
}

    }
}
