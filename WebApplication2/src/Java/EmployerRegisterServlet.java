import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EmployerRegisterServlet")
public class EmployerRegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Read data from JSP form
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String companyName = request.getParameter("company_name");
        String website = request.getParameter("website");
        String country = request.getParameter("country");
        String state = request.getParameter("state");
        String city = request.getParameter("city");
        String zipcode = request.getParameter("zipcode");

        try {
            // 2. Load Driver
            Class.forName("com.mysql.jdbc.Driver");

            // 3. DB Connection
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
            );
// 🔍 CHECK IF PHONE ALREADY EXISTS
String checkSql = "SELECT ephone FROM employer WHERE ephone = ?";
PreparedStatement checkPs = con.prepareStatement(checkSql);
checkPs.setString(1, phone);

ResultSet rs = checkPs.executeQuery();

if (rs.next()) {
    // Phone already registered
    response.sendRedirect("employer_register.jsp?error=phone_exists");
    con.close();
    return; // ⛔ STOP execution here
}

            // 4. INSERT QUERY (RETURN GENERATED ID)
            String sql = "INSERT INTO employer "
                    + "(efirstname, elastname, ephone, eemail, epwd, "
                    + "ecompanyname, ecompanywebsite, ecountry, estate, ecity, ezip) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(
                sql
                    
            );

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, phone);
            ps.setString(4, email);
            ps.setString(5, password);
            ps.setString(6, companyName);
            ps.setString(7, website);
            ps.setString(8, country);
            ps.setString(9, state);
            ps.setString(10, city);
            ps.setString(11, zipcode);

            // 5. Execute insert
            ps.executeUpdate();

            // 6. GET GENERATED EMPLOYER ID
         

            // 7. CREATE SESSION & STORE DATA
           

            con.close();

            // 8. REDIRECT TO DASHBOARD
            response.sendRedirect("emp_dash.jsp");

        } catch (SQLIntegrityConstraintViolationException e) {
    // Duplicate email or phone
    response.sendRedirect("emp_dash.jsp?error=duplicate");
}
catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("error.jsp");
}

    }
}
