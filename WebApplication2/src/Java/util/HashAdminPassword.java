package util;

import org.mindrot.jbcrypt.BCrypt;

public class HashAdminPassword {
    public static void main(String[] args) {
        String plainPassword = "Admin@123"; // your current password
        String hashed = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
        System.out.println("Hashed password: " + hashed);
    }
}