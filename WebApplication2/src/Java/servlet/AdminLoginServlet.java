package servlets;

import db.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // Fetch by username only — then verify hash separately
            PreparedStatement ps = con.prepareStatement(
                "SELECT admin_id, username, apwd FROM admin WHERE username = ?"
            );
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("apwd");

                // BCrypt check — compares plain input against stored hash
                if (BCrypt.checkpw(password, storedHash)) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("adminId",       rs.getInt("admin_id"));
                    session.setAttribute("adminUsername", rs.getString("username"));
                    session.setMaxInactiveInterval(60 * 60);
                    response.sendRedirect("admin_dash.jsp");
                } else {
                    // Password wrong
                    request.setAttribute("adminLoginError", "Invalid username or password.");
                    request.getRequestDispatcher("admin_login.jsp").forward(request, response);
                }
            } else {
                // Username not found
                request.setAttribute("adminLoginError", "Invalid username or password.");
                request.getRequestDispatcher("admin_login.jsp").forward(request, response);
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("adminLoginError", "Server error. Please try again.");
            request.getRequestDispatcher("admin_login.jsp").forward(request, response);
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("admin_login.jsp");
    }
}