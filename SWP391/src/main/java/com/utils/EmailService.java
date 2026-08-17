package com.utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Generic SMTP sending -- no knowledge of OTPs, subjects, or message
 * content. OTPService (and anything else that needs to email someone)
 * calls sendEmail() with whatever subject/body it wants.
 */
public class EmailService {

    // TODO: fill in a real sending account before this goes live. Gmail
    // requires an "App Password" (Google Account -> Security -> App
    // Passwords) if 2-Step Verification is on -- a normal login password
    // will be rejected by smtp.gmail.com.
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String SMTP_USERNAME = "huy69332@gmail.com";
    private static final String SMTP_PASSWORD = "huy1442005";

    private EmailService() {
    }

    /**
     * Sends a plain-text email. Throws MessagingException on failure so the
     * caller can show an error instead of silently pretending it worked.
     */
    public static void sendEmail(String toEmail, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(SMTP_PORT));

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });

        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(SMTP_USERNAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setText(body);

        Transport.send(message);
    }
}