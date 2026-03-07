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

@WebServlet("/JobseekerPhotoUploadServlet")
@MultipartConfig
public class JobseekerPhotoUploadServlet extends HttpServlet {

protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
throws ServletException, IOException {

HttpSession session = request.getSession(false);

if(session == null || session.getAttribute("jobseekerId") == null){
response.sendRedirect("login.jsp");
return;
}

int jid = (Integer) session.getAttribute("jobseekerId");

Part part = request.getPart("photo");

if(part == null || part.getSize() == 0){
response.sendRedirect("jobseeker_profile.jsp");
return;
}

/* ORIGINAL FILE NAME */

String original =
Paths.get(part.getSubmittedFileName())
.getFileName()
.toString();

/* FILE EXTENSION */

String ext = original.substring(original.lastIndexOf("."));

/* NEW FILE NAME */

String fileName = jid + "_" + System.currentTimeMillis() + ext;

/* GET DEPLOYED UPLOAD FOLDER */

String uploadPath = request.getServletContext().getRealPath("/uploads");

File uploadDir = new File(uploadPath);

if(!uploadDir.exists()){
uploadDir.mkdirs();
}

/* FULL FILE PATH */

File file = new File(uploadDir, fileName);

/* SAVE FILE MANUALLY */

try(InputStream is = part.getInputStream();
    FileOutputStream fos = new FileOutputStream(file)){

byte[] buffer = new byte[1024];
int bytesRead;

while((bytesRead = is.read(buffer)) != -1){
fos.write(buffer,0,bytesRead);
}

}

/* UPDATE DATABASE */

try{

Connection con = DBConnection.getConnection();

PreparedStatement ps =
con.prepareStatement(
"UPDATE jobseeker SET jphoto=? WHERE jid=?"
);

ps.setString(1,fileName);
ps.setInt(2,jid);

ps.executeUpdate();

ps.close();
con.close();

}catch(Exception e){
e.printStackTrace();
}

/* UPDATE SESSION */

session.setAttribute("jphoto",fileName);

/* REDIRECT BACK TO PROFILE */

response.sendRedirect("jobseeker_profile.jsp");

}
}