package servlet;

import db.DBConnection;
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

    String fname = request.getParameter("firstname");
    String lname = request.getParameter("lastname");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String phone = request.getParameter("phone");
    String company = request.getParameter("companyname");
    String website = request.getParameter("companywebsite");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String city = request.getParameter("city");
    String zip = request.getParameter("zip");
    System.out.println("DEBUG -> fname = " + fname + ", lname = " + lname);
    try {
        Connection con = DBConnection.getConnection();

        String sql = "INSERT INTO employer " +
             "(efirstname, elastname, eemail, epwd, ephone, ecompanyname, ecompanywebsite, estate, ecountry, ecity, ezip) " +
             "VALUES (?,?,?,?,?,?,?,?,?,?,?)";


        PreparedStatement ps =
    con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, email);
        ps.setString(4, password);
        ps.setString(5, phone);
        ps.setString(6, company);
        ps.setString(7, website);
        ps.setString(8, state);
        ps.setString(9, country);
        ps.setString(10, city);
        ps.setString(11, zip);

        int result = ps.executeUpdate();
        ResultSet rs = ps.getGeneratedKeys();
if (!rs.next()) {
    throw new RuntimeException("Failed to get employer ID");
}
int eid = rs.getInt(1);

        if (result > 0) {
            HttpSession session = request.getSession();
            session.setAttribute("eid", eid);
            session.setAttribute("eemail", email);
            session.setAttribute("efirstname", fname);

            response.sendRedirect(request.getContextPath() + "/emp_dash.jsp");
        } else {
            response.sendRedirect("employer_register.jsp?error=failed");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().println("ERROR: " + e.getMessage());
    }
}
}