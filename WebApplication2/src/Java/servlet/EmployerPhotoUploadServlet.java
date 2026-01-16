package servlet;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EmployerPhotoUploadServlet")
@MultipartConfig
public class EmployerPhotoUploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        // 1️⃣ SESSION CHECK
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("eemail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("eemail");

        // 2️⃣ GET FILE
        Part part = request.getPart("photo");

        // 3️⃣ UPLOAD FOLDER (inside web app)
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + "uploads";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String fileName = null;

        // 4️⃣ SAVE FILE
        if (part != null && part.getSize() > 0) {

            fileName = email.replaceAll("[^a-zA-Z0-9]", "")
                    + "_" + System.currentTimeMillis() + ".jpg";

            File file = new File(uploadDir, fileName);

            try (InputStream is = part.getInputStream();
                 FileOutputStream fos = new FileOutputStream(file)) {

                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, bytesRead);
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("employer_profile.jsp");
                return;
            }
        }

        // 5️⃣ UPDATE DATABASE
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/skillmitra", "root", "");
                 PreparedStatement ps = con.prepareStatement(
                    "UPDATE employer SET ephoto=? WHERE eemail=?")) {

                ps.setString(1, fileName);
                ps.setString(2, email);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 6️⃣ UPDATE SESSION (IMPORTANT)
        if (fileName != null) {
            session.setAttribute("ephoto", fileName);
        }

        // 7️⃣ REDIRECT
        response.sendRedirect("employer_profile.jsp");
    }
}
