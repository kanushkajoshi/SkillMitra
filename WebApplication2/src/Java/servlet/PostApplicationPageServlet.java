package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/post-application")
public class PostApplicationPageServlet extends HttpServlet {

protected void doGet(HttpServletRequest request, HttpServletResponse response)
throws ServletException, IOException {

HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("jobseekerId") == null) {
response.sendRedirect(request.getContextPath()+"/login.jsp");
return;
}

List<Map<String,Object>> jobs = new ArrayList<>();

try(Connection con = DBConnection.getConnection();
PreparedStatement ps = con.prepareStatement(
"SELECT job_id,title,city,salary FROM jobs");
ResultSet rs = ps.executeQuery()){

while(rs.next()){
Map<String,Object> m = new HashMap<>();
m.put("id", rs.getInt("job_id"));
m.put("title", rs.getString("title"));
m.put("city", rs.getString("city"));
m.put("salary", rs.getString("salary"));
jobs.add(m);
}

}catch(Exception e){ e.printStackTrace(); }

request.setAttribute("jobs", jobs);
request.getRequestDispatcher("/post_application.jsp")
.forward(request,response);
}
}
