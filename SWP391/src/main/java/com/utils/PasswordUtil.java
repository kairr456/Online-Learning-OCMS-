package com.utils;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

// Shared by RegisterController (hashing on sign-up) and LoginController
// (hashing on sign-in), so both sides always produce byte-for-byte the same
// hash for the same input. This is the exact algorithm RegisterController
// used to have inline as encodeMD5() -- pulled out here so it can't drift
// between the two controllers.
public class PasswordUtil {

    private PasswordUtil() {
    }

    public static String md5(String rawPassword) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(rawPassword.getBytes());
            byte[] digest = md.digest();
            BigInteger bigInt = new BigInteger(1, digest);
            String hashText = bigInt.toString(16);
            while (hashText.length() < 32) {
                hashText = "0" + hashText;
            }
            return hashText;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 algorithm not found", e);
        }
    }
}