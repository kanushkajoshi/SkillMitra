package servlet;

import db.DBConnection;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/SearchJobsServlet")
public class SearchJobsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {

        res.setContentType("application/json;charset=UTF-8");

        String q        = req.getParameter("q");
        String district = req.getParameter("district");
        String area     = req.getParameter("area");
        String minSal   = req.getParameter("min_salary");
        String maxSal   = req.getParameter("max_salary");

        int jid = Integer.parseInt(req.getParameter("jid"));

        if(q == null) q = "";

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try(Connection con = DBConnection.getConnection()){

            StringBuilder sql = new StringBuilder(

            "SELECT \n" +
"j.job_id,\n" +
"j.title,\n" +
"j.city,\n" +
"j.locality,\n" +
"j.salary,\n" +
"s.skill_name,\n" +
"GROUP_CONCAT(ss.subskill_name) AS subskill_name\n" +
"\n" +
"FROM jobs j\n" +
"\n" +
"JOIN job_skills jk ON jk.job_id = j.job_id\n" +
"JOIN skill s ON s.skill_id = jk.skill_id\n" +
"LEFT JOIN subskill ss ON ss.subskill_id = jk.subskill_id\n" +
"\n" +
"GROUP BY j.job_id"
            );

            if(!q.isEmpty()){
                sql.append("AND LOWER(j.title) LIKE ? ");
            }

            if(district != null && !district.isEmpty()){
                sql.append("AND j.city = ? ");
            }

            if(area != null && !area.isEmpty()){
                String[] areas = area.split(",");
                sql.append("AND j.locality IN (");

                for(int i=0;i<areas.length;i++){
                    sql.append("?");
                    if(i<areas.length-1) sql.append(",");
                }

                sql.append(") ");
            }

            if(minSal != null && !minSal.isEmpty()){
                sql.append("AND j.salary >= ? ");
            }

            if(maxSal != null && !maxSal.isEmpty()){
                sql.append("AND j.salary <= ? ");
            }

            sql.append("GROUP BY j.job_id LIMIT 20");

            PreparedStatement ps = con.prepareStatement(sql.toString());

            int idx = 1;

            ps.setInt(idx++, jid);

            if(!q.isEmpty()){
                ps.setString(idx++, "%"+q.toLowerCase()+"%");
            }

            if(district != null && !district.isEmpty()){
                ps.setString(idx++, district);
            }

            if(area != null && !area.isEmpty()){
                String[] areas = area.split(",");
                for(String a : areas){
                    ps.setString(idx++, a.trim());
                }
            }

            if(minSal != null && !minSal.isEmpty()){
                ps.setInt(idx++, Integer.parseInt(minSal));
            }

            if(maxSal != null && !maxSal.isEmpty()){
                ps.setInt(idx++, Integer.parseInt(maxSal));
            }

            ResultSet rs = ps.executeQuery();

            while(rs.next()){

                if(!first) json.append(",");
                first = false;

                String title    = safe(rs.getString("title"));
                String city     = safe(rs.getString("city"));
                String locality = safe(rs.getString("locality"));
                String skill    = safe(rs.getString("skill_name"));
                String subskill = safe(rs.getString("subskill_name"));

                int salary = rs.getInt("salary");

                json.append("{")
                .append("\"jobId\":").append(rs.getInt("job_id")).append(",")
                .append("\"title\":\"").append(escape(title)).append("\",")
                .append("\"city\":\"").append(escape(city)).append("\",")
                .append("\"locality\":\"").append(escape(locality)).append("\",")
                .append("\"salary\":").append(salary).append(",")
                .append("\"skill\":\"").append(escape(skill)).append("\",")
                .append("\"subskill\":\"").append(escape(subskill)).append("\"")
                .append("}");
            }

            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }

        json.append("]");
        res.getWriter().write(json.toString());
    }

    private String safe(String s){
        if(s == null) return "";
        return s;
    }

    private String escape(String s){

        if(s == null) return "";

        return s.replace("\\","\\\\")
                .replace("\"","\\\"")
                .replace("\n","\\n")
                .replace("\r","\\r");
    }
}