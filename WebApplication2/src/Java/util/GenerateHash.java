package util;

import org.mindrot.jbcrypt.BCrypt;

public class GenerateHash {
    public static void main(String[] args) {
        String password = "Admin@123";

        String hashed = BCrypt.hashpw(password, BCrypt.gensalt());

        System.out.println("Hashed Password: " + hashed);
    }
}