

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.http.HttpServlet;

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
            // 2. Get DB connection
             Class.forName("com.mysql.jdbc.Driver");

            // Database connection
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""   // change password
            );

            

            // 3. SQL Insert Query
            String sql = "INSERT INTO employer "
                    + "(efirstname, elastname, ephone, eemail, epwd,  ecompanyname, ecompanywebsite, ecountry, estate, ecity, ezip) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);

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

            // 4. Execute
            ps.executeUpdate();

            con.close();

            // 5. Redirect after success
            response.sendRedirect("emp_dash.jsp");

        } catch (Exception e) {
            
            e.printStackTrace();
            response.sendRedirect("error.jsp");
                
        }
    }
}
