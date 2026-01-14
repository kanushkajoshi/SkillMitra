package servlet;


import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.http.Part;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/EmployerPhotoUploadServlet")
@MultipartConfig
public class EmployerPhotoUploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employerId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Integer eidObj = (Integer) session.getAttribute("employerId");
        if (eidObj == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int eid = eidObj;

        Part part = request.getPart("photo");
        if (part == null || part.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/emp_dash.jsp");
            return;
        }

        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        String fileName = "employer_" + eid + ".jpg";
        part.write(uploadPath + File.separator + fileName);

        String photoPath = "uploads/" + fileName;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/skillmitra", "root", "");

            PreparedStatement ps = con.prepareStatement(
                "UPDATE employer SET ephoto=? WHERE eid=?"
            );
            ps.setString(1, photoPath);
            ps.setInt(2, eid);
            ps.executeUpdate();

            session.setAttribute("ephoto", photoPath);
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/emp_dash.jsp");
    }
}
