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
        String[] areas  = req.getParameterValues("area");
        String[] subskills = req.getParameterValues("subskill");
        String minSal   = req.getParameter("min_salary");
        String maxSal   = req.getParameter("max_salary");

        int jid = Integer.parseInt(req.getParameter("jid"));

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try(Connection con = DBConnection.getConnection()){

            StringBuilder sql = new StringBuilder(

                "SELECT DISTINCT j.job_id, j.title, j.city, j.locality, j.salary " +
                "FROM jobs j " +

                "JOIN job_skills jk ON jk.job_id = j.job_id " +
                "JOIN jobseeker_skills js ON js.skill_id = jk.skill_id " +

                "WHERE js.jid = ? AND j.status='ACTIVE' "
            );

            // 🔍 SEARCH
            if(q != null && !q.isEmpty()){
                sql.append("AND LOWER(j.title) LIKE ? ");
            }

            // 📍 DISTRICT
            if(district != null && !district.isEmpty()){
                sql.append("AND LOWER(j.city) = LOWER(?) ");
            }

            // 🏠 AREA
            if(areas != null && areas.length > 0){
                sql.append("AND j.locality IN (");
                for(int i=0;i<areas.length;i++){
                    sql.append("?");
                    if(i < areas.length-1) sql.append(",");
                }
                sql.append(") ");
            }

            // 🧠 SUBSKILL FILTER (IMPORTANT)
            if(subskills != null && subskills.length > 0){
                sql.append("AND jk.subskill_id IN (");
                for(int i=0;i<subskills.length;i++){
                    sql.append("?");
                    if(i < subskills.length-1) sql.append(",");
                }
                sql.append(") ");
            }

            // 💰 SALARY
            if(minSal != null && !minSal.isEmpty()){
                sql.append("AND j.salary >= ? ");
            }

            if(maxSal != null && !maxSal.isEmpty()){
                sql.append("AND j.salary <= ? ");
            }

            sql.append("ORDER BY j.created_at DESC LIMIT 20");

            PreparedStatement ps = con.prepareStatement(sql.toString());

            int idx = 1;

            ps.setInt(idx++, jid);

            if(q != null && !q.isEmpty()){
                ps.setString(idx++, "%" + q.toLowerCase() + "%");
            }

            if(district != null && !district.isEmpty()){
                ps.setString(idx++, district);
            }

            if(areas != null){
                for(String a : areas){
                    ps.setString(idx++, a);
                }
            }

            if(subskills != null){
                for(String s : subskills){
                    ps.setInt(idx++, Integer.parseInt(s));
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

                json.append("{")
                    .append("\"jobId\":").append(rs.getInt("job_id")).append(",")
                    .append("\"title\":\"").append(escape(rs.getString("title"))).append("\",")
                    .append("\"city\":\"").append(escape(rs.getString("city"))).append("\",")
                    .append("\"locality\":\"").append(escape(rs.getString("locality"))).append("\",")
                    .append("\"salary\":").append(rs.getInt("salary"))
                    .append("}");
            }

            rs.close();
            ps.close();

        } catch(Exception e){
            e.printStackTrace();
        }

        json.append("]");
        res.getWriter().write(json.toString());
    }

    private String escape(String s){
        if(s == null) return "";
        return s.replace("\\","\\\\")
                .replace("\"","\\\"")
                .replace("\n","\\n")
                .replace("\r","\\r");
    }
}