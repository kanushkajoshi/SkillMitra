package servlet;

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

        // 🔐 PASSWORD VALIDATION
        if (!password.matches("^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$")) {
            request.setAttribute("passwordError",
                "Password must contain letters and numbers (min 6 characters)");
            request.getRequestDispatcher("employer_register.jsp")
                   .forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", ""
            );

            // ✅ CHECK EMAIL
            PreparedStatement emailPs = con.prepareStatement(
                "SELECT 1 FROM employer WHERE eemail = ?");
            emailPs.setString(1, email);
            if (emailPs.executeQuery().next()) {
                request.setAttribute("emailError", "Email already registered");
                request.getRequestDispatcher("employer_register.jsp")
                       .forward(request, response);
                con.close();
                return;
            }

            // ✅ CHECK PHONE
            PreparedStatement phonePs = con.prepareStatement(
                "SELECT 1 FROM employer WHERE ephone = ?");
            phonePs.setString(1, phone);
            if (phonePs.executeQuery().next()) {
                request.setAttribute("phoneError", "Phone number already registered");
                request.getRequestDispatcher("employer_register.jsp")
                       .forward(request, response);
                con.close();
                return;
            }

            // ✅ INSERT
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO employer " +
                "(efirstname, elastname, ephone, eemail, epwd, " +
                "ecompanyname, ecompanywebsite, ecountry, estate, ecity, ezip) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
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

            ps.executeUpdate();

            // ✅ CREATE SESSION (FROM FORM DATA)
            HttpSession session = request.getSession();
            session.setAttribute("eemail", email);
            session.setAttribute("efirstname", firstName);
            session.setAttribute("elastname", lastName);
            session.setAttribute("ecompanyname", companyName);
            session.setAttribute("ephoto", null);

            con.close();

            // ✅ REDIRECT ON SUCCESS
            response.sendRedirect("emp_dash.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
