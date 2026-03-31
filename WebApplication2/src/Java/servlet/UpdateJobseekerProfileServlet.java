//package servlet;
//
//import db.DBConnection;
//import java.io.IOException;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//
//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.*;
//
//@WebServlet("/UpdateJobseekerProfileServlet")
//public class UpdateJobseekerProfileServlet extends HttpServlet {
//
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        HttpSession session = request.getSession(false);
//
//        if (session == null || session.getAttribute("jobseekerId") == null) {
//            response.sendRedirect("login.jsp");
//            return;
//        }
//
//        int jid = (Integer) session.getAttribute("jobseekerId");
//
//        String[] skill = request.getParameterValues("skill");
//        String[] subskills = request.getParameterValues("subskills");
//
//        try {
//
//            Connection con = DBConnection.getConnection();
//
//            // STEP 1: delete old skills
//            PreparedStatement deleteSkills = con.prepareStatement(
//                    "DELETE FROM jobseeker_skills WHERE jid=?");
//            deleteSkills.setInt(1, jid);
//            deleteSkills.executeUpdate();
//
//            // STEP 2: insert new skills
//            PreparedStatement insertSkill = con.prepareStatement(
//                    "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");
//
//if (skill != null && subskills != null) {
//
//    for (String sub : subskills) {
//
//        insertSkill.setInt(1, jid);
//        insertSkill.setInt(2, Integer.parseInt(skill));
//        insertSkill.setInt(3, Integer.parseInt(sub));
//
//        insertSkill.executeUpdate();
//    }
//}
//
//            con.close();
//
//            // STEP 3: redirect dashboard
//            response.sendRedirect("jobseeker_dash.jsp");
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//}

package servlet;

import db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateJobseekerProfileServlet")
public class UpdateJobseekerProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response
)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("jobseekerId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int jid = (Integer) session.getAttribute("jobseekerId");

        String skill = request.getParameter("skill");
        String[] subskills = request.getParameterValues("subskills");

        try {

            Connection con = DBConnection.getConnection();
            PreparedStatement psUpdate = con.prepareStatement(
"UPDATE jobseeker SET " +
"jfirstname=?, jlastname=?, jphone=?, " +
"jcountry=?, jstate=?, jdistrict=?, jarea=?, " +
"jzip=?, jeducation=?, jdob=? " +
"WHERE jid=?"
);

psUpdate.setString(1, request.getParameter("fname"));
psUpdate.setString(2, request.getParameter("lname"));
psUpdate.setString(3, request.getParameter("phone"));
psUpdate.setString(4, request.getParameter("country"));
psUpdate.setString(5, request.getParameter("state"));
psUpdate.setString(6, request.getParameter("district"));
psUpdate.setString(7, request.getParameter("area"));
psUpdate.setString(8, request.getParameter("zip"));
psUpdate.setString(9, request.getParameter("education"));
psUpdate.setString(10, request.getParameter("dob"));
psUpdate.setInt(11, jid);

psUpdate.executeUpdate();
session.setAttribute("jfirstname", request.getParameter("fname"));
session.setAttribute("jlastname", request.getParameter("lname"));
session.setAttribute("jdistrict", request.getParameter("district"));
            // delete old skills
            PreparedStatement deleteSkills = con.prepareStatement(
                    "DELETE FROM jobseeker_skills WHERE jid=?");

            deleteSkills.setInt(1, jid);
            deleteSkills.executeUpdate();

            // insert new skills
            PreparedStatement insertSkill = con.prepareStatement(
                    "INSERT INTO jobseeker_skills (jid, skill_id, subskill_id) VALUES (?, ?, ?)");

            if (skill != null && subskills != null) {

                for (String sub : subskills) {

                    insertSkill.setInt(1, jid);
                    insertSkill.setInt(2, Integer.parseInt(skill));
                    insertSkill.setInt(3, Integer.parseInt(sub));

                    insertSkill.executeUpdate();
                }
            }

            con.close();

            response.sendRedirect("MatchedJobsServlet");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}