package servlet;

import db.DBConnection;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EmployerPhotoUploadServlet")
@MultipartConfig
public class EmployerPhotoUploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("eemail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("eemail");

        Part part = request.getPart("photo");

        if (part == null || part.getSize() == 0) {
            response.sendRedirect("employer_profile.jsp");
            return;
        }

        String originalName = Paths.get(part.getSubmittedFileName())
                .getFileName().toString();

        String ext = originalName.substring(originalName.lastIndexOf("."));

        String fileName = email.replaceAll("[^a-zA-Z0-9]", "")
                + "_" + System.currentTimeMillis() + ext;

        /* CORRECT PATH */
        String uploadPath = getServletContext().getRealPath("/uploads");

        File uploadDir = new File(uploadPath);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File file = new File(uploadDir, fileName);

        /* SAVE FILE MANUALLY (GlassFish safe method) */

        try (InputStream is = part.getInputStream();
             FileOutputStream fos = new FileOutputStream(file)) {

            byte[] buffer = new byte[1024];
            int bytesRead;

            while ((bytesRead = is.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }

        }

        /* UPDATE DATABASE */

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(
                    "UPDATE employer SET ephoto=? WHERE eemail=?");

            ps.setString(1, fileName);
            ps.setString(2, email);

            ps.executeUpdate();

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        session.setAttribute("ephoto", fileName);

        response.sendRedirect("employer_profile.jsp");
    }
}