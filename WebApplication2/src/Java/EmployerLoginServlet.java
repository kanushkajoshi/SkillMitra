

import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EmployerLoginServlet")
public class EmployerLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Servlet hit");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
System.out.println("Email: " + email);
System.out.println("Password: " + password);
        try {
            // Load JDBC driver
            Class.forName("com.mysql.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra",
                "root",
                ""
            );

            String sql = "SELECT eid,ecompanyname, efirstname,ephoto FROM employer WHERE eemail=? AND epwd=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Login success
                System.out.println("LOGIN SUCCESS");
                HttpSession session = request.getSession();
                session.setAttribute("employerId", rs.getInt("eid"));
                session.setAttribute("employerName", rs.getString("efirstname"));
                session.setAttribute("efirstname", rs.getString("efirstname"));
                session.setAttribute("elastname", "");   // placeholder for now
session.setAttribute("ecompanyname", rs.getString("ecompanyname"));

                session.setAttribute("eemail", email);
                String photo = rs.getString("ephoto");
               if (photo != null && !photo.trim().isEmpty()) {
                    session.setAttribute("ephoto", photo);
             } else {
                    session.setAttribute("ephoto", null);
                    }

                response.sendRedirect("emp_dash.jsp");
               
            } else {
                // Login failed
                System.out.println("LOGIN FAILED");
                response.sendRedirect("login.jsp?error=invalid&role=employer");
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
