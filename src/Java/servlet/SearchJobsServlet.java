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

        String q = req.getParameter("q");
        String district = req.getParameter("district");
        String[] areas = req.getParameterValues("area");
        String[] subskills = req.getParameterValues("subskill");
        String[] skills = req.getParameterValues("skill");
        String minSal = req.getParameter("min_salary");
        String maxSal = req.getParameter("max_salary");

        int jid = Integer.parseInt(req.getParameter("jid"));

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try(Connection con = DBConnection.getConnection()){

            StringBuilder sql = new StringBuilder();

            sql.append(
                "SELECT j.job_id, j.title, j.city, j.locality, j.salary, " +
                "COUNT(DISTINCT js.subskill_id) AS matchedSkills " +

                "FROM jobs j " +
                "JOIN job_skills jk ON jk.job_id = j.job_id " +

                // 🔥 MATCHING LOGIC (LIKE search_results.jsp)
                "LEFT JOIN jobseeker_skills js " +
                "ON js.subskill_id = jk.subskill_id AND js.jid = ? " +

                "WHERE j.status='Active' AND j.expiry_date >= CURDATE() "
            );

            // 🔍 SEARCH
            if(q != null && !q.trim().isEmpty()){
                sql.append(
                    "AND j.job_id IN (" +
                    "SELECT jk2.job_id FROM job_skills jk2 " +
                    "JOIN subskill ss ON ss.subskill_id = jk2.subskill_id " +
                    "WHERE LOWER(ss.subskill_name) LIKE LOWER(?)" +
                    ") "
                );
            }

            // 📍 DISTRICT
            if(district != null && !district.isEmpty()){
                sql.append("AND LOWER(j.city)=LOWER(?) ");
            }

            // 🏠 AREA
            if(areas != null && areas.length > 0){
                sql.append("AND j.locality IN (");
                for(int i=0;i<areas.length;i++){
                    sql.append("?");
                    if(i<areas.length-1) sql.append(",");
                }
                sql.append(") ");
            }

            // 🧠 SKILLS
            if(skills != null && skills.length > 0){
                sql.append("AND jk.skill_id IN (");
                for(int i=0;i<skills.length;i++){
                    sql.append("?");
                    if(i<skills.length-1) sql.append(",");
                }
                sql.append(") ");
            }

            // 🧠 SUBSKILLS
            if(subskills != null && subskills.length > 0){
                sql.append("AND jk.subskill_id IN (");
                for(int i=0;i<subskills.length;i++){
                    sql.append("?");
                    if(i<subskills.length-1) sql.append(",");
                }
                sql.append(") ");
            }

            // 💰 SALARY
            if(minSal != null && !minSal.isEmpty()){
                sql.append("AND j.min_salary >= ? ");
            }

            if(maxSal != null && !maxSal.isEmpty()){
                sql.append("AND j.salary <= ? ");
            }

            // 🔥 RANKING
            sql.append("GROUP BY j.job_id ORDER BY matchedSkills DESC");

            PreparedStatement ps = con.prepareStatement(sql.toString());

            int idx = 1;

            ps.setInt(idx++, jid);

            if(q != null && !q.trim().isEmpty()){
                ps.setString(idx++, "%" + q + "%");
            }

            if(district != null && !district.isEmpty()){
                ps.setString(idx++, district);
            }

            if(areas != null){
                for(String a : areas){
                    ps.setString(idx++, a);
                }
            }

            if(skills != null){
                for(String s : skills){
                    ps.setInt(idx++, Integer.parseInt(s));
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
                    .append("\"salary\":").append(rs.getInt("salary")).append(",")
                    .append("\"match\":").append(rs.getInt("matchedSkills"))
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

    private String escape(String s){
        if(s == null) return "";
        return s.replace("\\","\\\\")
                .replace("\"","\\\"")
                .replace("\n","\\n")
                .replace("\r","\\r");
    }
}