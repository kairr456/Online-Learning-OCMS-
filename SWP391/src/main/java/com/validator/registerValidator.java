package com.validator;

import java.util.regex.Pattern;

/**
 * Pure form-field validation for registration -- no database access here on
 * purpose. Uniqueness checks (username/email already taken) need a DB
 * connection, so those stay in RegisterController; everything that can be
 * decided just by looking at the submitted strings lives here instead.
 *
 * validate(...) returns the first failing rule's message (null if the whole
 * form is valid), so RegisterController's calling code barely changes -- it
 * just checks one String instead of running each if-block itself.
 *
 * All the limits below are named constants specifically so they're easy to
 * tweak in one place without hunting through validation logic.
 */
public class registerValidator {

    public static final int USERNAME_MIN_LENGTH = 5;
    public static final int USERNAME_MAX_LENGTH = 20;

    public static final int PASSWORD_MIN_LENGTH = 6;
    public static final int PASSWORD_MAX_LENGTH = 20;

    public static final int FULL_NAME_MIN_LENGTH = 2;

    // Good-enough email check for a registration form -- not RFC 5322-exact
    // (nothing simple is), but catches the typo-shaped mistakes that matter:
    // missing @, missing domain, no dot in the domain, stray spaces, etc.
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[\\w.+-]+@[\\w-]+\\.[a-zA-Z]{2,}$");

    // Simple Vietnamese-style mobile number: starts with 0, 9-10 more digits.
    // Adjust this pattern if you need to support other country formats.
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^0\\d{9,10}$");

    private registerValidator() {
    }

    /**
     * Runs every field-level check in order and returns the message for the
     * first one that fails, or null if the form passes all of them.
     */
    public static String validate(String username, String password, String confirmPassword,
                                   String email, String phone, String fullName,
                                   String role, String gender) {

        // --- required fields ---
        if (isBlank(username) || isBlank(password) || isBlank(confirmPassword)
                || isBlank(email) || isBlank(phone) || isBlank(fullName)
                || isBlank(role) || isBlank(gender)) {
            return "Please fill in all required fields.";
        }

        // --- username length ---
        int usernameLength = username.trim().length();
        if (usernameLength < USERNAME_MIN_LENGTH || usernameLength > USERNAME_MAX_LENGTH) {
            return "Username must be between " + USERNAME_MIN_LENGTH
                    + " and " + USERNAME_MAX_LENGTH + " characters.";
        }

        // --- password length ---
        if (password.length() < PASSWORD_MIN_LENGTH || password.length() > PASSWORD_MAX_LENGTH) {
            return "Password must be between " + PASSWORD_MIN_LENGTH
                    + " and " + PASSWORD_MAX_LENGTH + " characters.";
        }

        // --- confirm password ---
        if (!password.equals(confirmPassword)) {
            return "Passwords do not match.";
        }

        // --- email format ---
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return "Please enter a valid email address.";
        }

        // --- phone format ---
        if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            return "Please enter a valid phone number.";
        }

        // --- full name ---
        if (fullName.trim().length() < FULL_NAME_MIN_LENGTH) {
            return "Please enter your full name.";
        }

        // --- role ---
        if (!"teacher".equalsIgnoreCase(role) && !"student".equalsIgnoreCase(role)) {
            return "Invalid role.";
        }

        // Gender is intentionally left permissive here (not restricted to an
        // exact "male"/"female" match) to match the original controller's
        // behavior -- genderValueFor() below treats anything other than
        // "male" as false, so it never errors on unexpected values.

        return null; // all checks passed
    }

    /** Converts the submitted role string into the roleId your accounts use. */
    public static int roleIdFor(String role) {
        return "teacher".equalsIgnoreCase(role) ? 2 : 3;
    }

    /** true = male, false = everything else (matches the original inline logic). */
    public static boolean genderValueFor(String gender) {
        return "male".equalsIgnoreCase(gender);
    }

    /**
     * Validates a "change password" submission: length limits (same
     * PASSWORD_MIN_LENGTH/MAX_LENGTH used at registration) and that the two
     * fields match. Returns the first failing rule's message, or null if
     * both fields pass. Deliberately does NOT check the account's current
     * password -- that requires a DB lookup, so it stays in ProfileController
     * alongside the other DAO calls, same separation as the uniqueness
     * checks in RegisterController.
     */
    public static String validatePasswordChange(String newPassword, String confirmPassword) {
        if (isBlank(newPassword) || isBlank(confirmPassword)) {
            return "Please fill in both password fields.";
        }

        if (newPassword.length() < PASSWORD_MIN_LENGTH || newPassword.length() > PASSWORD_MAX_LENGTH) {
            return "Password must be between " + PASSWORD_MIN_LENGTH
                    + " and " + PASSWORD_MAX_LENGTH + " characters.";
        }

        if (!newPassword.equals(confirmPassword)) {
            return "Passwords do not match.";
        }

        return null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}