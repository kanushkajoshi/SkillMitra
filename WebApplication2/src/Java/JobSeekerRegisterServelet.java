import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/JobSeekerRegisterServelet")
public class JobSeekerRegisterServelet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Read data from form
        String firstName = request.getParameter("first_name");
        String lastName  = request.getParameter("last_name");
        String email     = request.getParameter("email");
        String phone     = request.getParameter("phone");
        String password  = request.getParameter("password");
        String country   = request.getParameter("country");
        String state     = request.getParameter("state");
        String city      = request.getParameter("city");
        String dob       = request.getParameter("date_of_birth");

        // 2. Basic validation (Java-side)
        if (!phone.matches("^[6-9][0-9]{9}$")) {
            response.sendRedirect("jobseeker_register.jsp?error=phone");
            return;
        }

        if (!password.matches("^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$")) {
            response.sendRedirect("jobseeker_register.jsp?error=password");
            return;
        }

        try {
            // 3. Load MySQL driver
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
            );

            // 4. Insert into jobseeker table
            String sql = "INSERT INTO jobseeker " +
                    "(jfirstname, jlastname, jemail, jphone, jpwd, jcountry, jstate, jcity, jdob) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, password); // hashing later
            ps.setString(6, country);
            ps.setString(7, state);
            ps.setString(8, city);
            ps.setString(9, dob);

            ps.executeUpdate();
            con.close();

            // 5. Redirect after success
            response.sendRedirect("jobseeker_dash.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
