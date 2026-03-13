package util;

import db.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class JobExpiryCleaner implements Runnable {

    @Override
    public void run() {

        while(true){

            try{

                Connection con = DBConnection.getConnection();

                String sql = "UPDATE jobs SET status='EXPIRED' WHERE expiry_date < CURRENT_DATE";

                PreparedStatement ps = con.prepareStatement(sql);
                ps.executeUpdate();

                ps.close();
                con.close();

                Thread.sleep(3600000); // 24 hours

            }catch(Exception e){
                e.printStackTrace();
            }

        }
    }
}