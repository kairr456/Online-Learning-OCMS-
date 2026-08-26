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
    public static final int FULL_NAME_MAX_LENGTH = 100;
    public static final int EMAIL_MAX_LENGTH = 100;
    public static final int PHONE_MAX_LENGTH = 11;

    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^[a-zA-Z0-9_]+$");

    // Full name allows ONLY letters (including Vietnamese accented characters) and spaces.
    // Numbers, special characters, and underscores are strictly prohibited.
    private static final Pattern FULL_NAME_PATTERN =
            Pattern.compile("^[a-zA-Z\\s\\u00C0-\\u024F\\u1EA0-\\u1EF9]+$");

    // Email check: ^[^\s@]+@[^\s@]+$
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[^\\s@]+@[^\\s@]+$");

    // Simple Vietnamese-style mobile number: starts with 0, 9-10 more digits.
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
        if (isBlank(username)) {
            return "Vui lòng nhập Tên đăng nhập.";
        }
        if (isBlank(fullName)) {
            return "Vui lòng nhập Họ và tên.";
        }
        if (isBlank(email)) {
            return "Vui lòng nhập Email.";
        }
        if (isBlank(phone)) {
            return "Vui lòng nhập Số điện thoại.";
        }
        if (isBlank(password)) {
            return "Vui lòng nhập Mật khẩu.";
        }
        if (isBlank(confirmPassword)) {
            return "Vui lòng xác nhận Mật khẩu.";
        }
        if (isBlank(role)) {
            return "Vui lòng chọn Vai trò.";
        }
        if (isBlank(gender)) {
            return "Vui lòng chọn Giới tính.";
        }

        // --- username format & length ---
        String u = username.trim();
        if (u.length() < USERNAME_MIN_LENGTH || u.length() > USERNAME_MAX_LENGTH) {
            return "Tên đăng nhập phải từ " + USERNAME_MIN_LENGTH
                    + " đến " + USERNAME_MAX_LENGTH + " ký tự.";
        }
        if (!USERNAME_PATTERN.matcher(u).matches()) {
            return "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới (_), không chứa khoảng trắng hoặc ký tự đặc biệt.";
        }

        // --- full name format & length ---
        String fn = fullName.trim();
        if (fn.length() < FULL_NAME_MIN_LENGTH || fn.length() > FULL_NAME_MAX_LENGTH) {
            return "Họ và tên phải từ " + FULL_NAME_MIN_LENGTH + " đến " + FULL_NAME_MAX_LENGTH + " ký tự.";
        }
        if (!FULL_NAME_PATTERN.matcher(fn).matches()) {
            return "Họ và tên chỉ được chứa chữ cái và khoảng trắng, không được chứa số, ký tự đặc biệt hoặc dấu gạch dưới.";
        }

        // --- password length ---
        if (password.length() < PASSWORD_MIN_LENGTH || password.length() > PASSWORD_MAX_LENGTH) {
            return "Mật khẩu phải từ " + PASSWORD_MIN_LENGTH
                    + " đến " + PASSWORD_MAX_LENGTH + " ký tự.";
        }

        // --- confirm password ---
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }

        // --- email format & length ---
        String em = email.trim();
        if (em.length() > EMAIL_MAX_LENGTH) {
            return "Email không được vượt quá " + EMAIL_MAX_LENGTH + " ký tự.";
        }
        if (!EMAIL_PATTERN.matcher(em).matches()) {
            return "Vui lòng nhập địa chỉ Email hợp lệ.";
        }

        // --- phone format & length ---
        String ph = phone.trim();
        if (ph.length() > PHONE_MAX_LENGTH) {
            return "Số điện thoại không được vượt quá " + PHONE_MAX_LENGTH + " chữ số.";
        }
        if (!PHONE_PATTERN.matcher(ph).matches()) {
            return "Vui lòng nhập số điện thoại hợp lệ (10-11 chữ số, bắt đầu bằng 0).";
        }

        // --- role ---
        if (!"teacher".equalsIgnoreCase(role) && !"student".equalsIgnoreCase(role)) {
            return "Vai trò đăng ký không hợp lệ.";
        }

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

    /** Public wrapper around EMAIL_PATTERN so other code (e.g. the email-change OTP flow) can reuse the same check. */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }
}