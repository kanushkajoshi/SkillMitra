package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class UpdatePaymentServlet extends HttpServlet {

protected void doGet(HttpServletRequest request, HttpServletResponse response)
throws ServletException, IOException {

int applicationId = Integer.parseInt(request.getParameter("applicationId"));
String action = request.getParameter("action");

Connection con = null;
PreparedStatement ps = null;

try {

con = DBConnection.getConnection();

if("request".equals(action)){

ps = con.prepareStatement(
"INSERT INTO payments(application_id,status) VALUES (?, 'Requested') " +
"ON DUPLICATE KEY UPDATE status='Requested'"
);

ps.setInt(1, applicationId);
ps.executeUpdate();

}

else if("confirm".equals(action)){

ps = con.prepareStatement(
"UPDATE payments SET status='Confirmed' WHERE application_id=?"
);

ps.setInt(1, applicationId);
ps.executeUpdate();

}

response.sendRedirect("jobseeker.jsp?section=payments");

}catch(Exception e){
e.printStackTrace();
}

finally{

try{ if(ps!=null) ps.close(); }catch(Exception e){}
try{ if(con!=null) con.close(); }catch(Exception e){}

}

}
}