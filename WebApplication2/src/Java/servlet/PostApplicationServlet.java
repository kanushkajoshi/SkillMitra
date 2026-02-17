package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/PostApplicationServlet")
public class PostApplicationServlet extends HttpServlet {

protected void doPost(HttpServletRequest request, HttpServletResponse response)
throws ServletException, IOException {

HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("jobseekerId") == null) {
response.sendRedirect("login.jsp");
return;
}

int jid = (Integer) session.getAttribute("jobseekerId");
int jobId = Integer.parseInt(request.getParameter("job_id"));

try(Connection con = DBConnection.getConnection()){

PreparedStatement ps = con.prepareStatement(
"INSERT INTO applications(job_id,jobseeker_id,status) VALUES(?,?,?)");

ps.setInt(1, jobId);
ps.setInt(2, jid);
ps.setString(3, "Pending");

ps.executeUpdate();

response.sendRedirect("jobseeker_dash.jsp?applied=success");

}catch(Exception e){
e.printStackTrace();
}
}
}
