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
     * Sends the OTP to the given address. Throws MessagingException on
     * failure so the caller can show an error instead of silently pretending
     * it worked.
     */
    public static void sendOtpEmail(String toEmail, String otp) throws MessagingException {
        String subject = "Your OCMS verification code";
        String body =
                "Your verification code is: " + otp + "\n\n"
                + "This code expires in 5 minutes. If you didn't request this, you can ignore this email.";

        EmailService.sendEmail(toEmail, subject, body);
    }
}