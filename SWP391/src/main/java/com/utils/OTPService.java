package com.utils;

import jakarta.mail.MessagingException;
import java.security.SecureRandom;

/**
 * OTP domain logic only -- generating codes and composing the OTP email's
 * content. Actual SMTP transport lives in EmailService now; this class
 * just calls EmailService.sendEmail() with the OTP text.
 */
public class OTPService {

    public static final int OTP_LENGTH = 6;
    public static final long OTP_VALID_MILLIS = 5 * 60 * 1000; // 5 minutes

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String REFERENCE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I

    private OTPService() {
    }

    /** Random numeric OTP, e.g. "482913". */
    public static String generateOtp() {
        StringBuilder sb = new StringBuilder(OTP_LENGTH);
        for (int i = 0; i < OTP_LENGTH; i++) {
            sb.append(RANDOM.nextInt(10));
        }
        return sb.toString();
    }

    /**
     * Short code shown to the user alongside the OTP (e.g. "Reference: A8K2QX9P").
     * Lets the confirm step double-check the submitted request matches the one
     * the server actually sent, on top of the session lookup -- not a
     * replacement for it, an extra check.
     */
    public static String generateReferenceCode() {
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(REFERENCE_CHARS.charAt(RANDOM.nextInt(REFERENCE_CHARS.length())));
        }
        return sb.toString();
    }

    /**
     * Sends the OTP to the given address. Throws MessagingException on
     * failure so the caller can show an error instead of silently pretending
     * it worked.
     */
    public static void sendOtpEmail(String toEmail, String otp, String referenceCode) throws MessagingException {
        String subject = "Your OCMS verification code";
        String body =
                "Your verification code is: " + otp + "\n"
                + "Reference: " + referenceCode + "\n\n"
                + "This code expires in 5 minutes. If you didn't request this, you can ignore this email.";

        EmailService.sendEmail(toEmail, subject, body);
    }
}