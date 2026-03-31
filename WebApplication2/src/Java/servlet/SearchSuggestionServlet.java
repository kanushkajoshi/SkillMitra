package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import db.DBConnection;

@WebServlet("/SearchSuggestionServlet")
public class SearchSuggestionServlet extends HttpServlet {

protected void doGet(HttpServletRequest req, HttpServletResponse res)
throws IOException {

res.setContentType("application/json");

String q = req.getParameter("q");

HttpSession session = req.getSession(false);

if(session == null || session.getAttribute("jobseekerId") == null){
res.getWriter().write("[]");
return;
}

int jid = (Integer) session.getAttribute("jobseekerId");

StringBuilder json = new StringBuilder("[");

boolean first = true;

try(Connection con = DBConnection.getConnection()){

PreparedStatement ps = con.prepareStatement(

"SELECT DISTINCT ss.subskill_name " +
"FROM subskill ss " +
"JOIN job_skills jk ON jk.subskill_id = ss.subskill_id " +
"JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +
"WHERE js.jid = ? AND ss.subskill_name LIKE ? " +
"LIMIT 5"

);

ps.setInt(1, jid);
ps.setString(2, q + "%");

ResultSet rs = ps.executeQuery();

while(rs.next()){

if(!first) json.append(",");

json.append("\"").append(rs.getString("subskill_name")).append("\"");

first = false;

}

rs.close();
ps.close();

}catch(Exception e){
e.printStackTrace();
}

json.append("]");

res.getWriter().write(json.toString());

}
}