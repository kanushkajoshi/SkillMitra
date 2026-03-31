/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlet;
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailUtility {

    public static void sendOTP(String toEmail, String otp) {

        final String fromEmail = "skillmitra.noreply@gmail.com";
        final String password  = "rhvrftkixwfgkmiz";

        Properties props = new Properties();

        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session =
            Session.getInstance(props,
                new Authenticator() {
                    protected PasswordAuthentication
                    getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                fromEmail, password);
                    }
                });

        try {
            Message msg =
                new MimeMessage(session);

            msg.setFrom(new InternetAddress(fromEmail));
            msg.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(toEmail));

            msg.setSubject("SkillMitra Email Verification");

            msg.setText(
                "Your OTP is: " + otp +
                "\nValid for 10 minutes.");

            Transport.send(msg);

        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
