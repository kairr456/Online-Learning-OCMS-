package com.validator;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Validator dùng chung cho các trang admin (Account / Course Management).
 * Chỉ xử lý parse/chuẩn hóa tham số form — không truy cập DB.
 * Các hàm dùng chung khác đã nằm sẵn ở registrationValidator / registerValidator.
 */
public class adminValidator {

    // Danh sách status hợp lệ của bảng course
    private static final Set<String> COURSE_STATUS_ALLOWED =
            new HashSet<>(Arrays.asList("active", "inactive", "pending", "cancelled", "draft"));

    private adminValidator() {
    }

    /** Parse số nguyên an toàn; trả về defaultValue nếu null/rỗng/sai định dạng. */
    public static int parseInt(String raw, int defaultValue) {
        if (raw == null || raw.trim().isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Parse số thực an toàn; trả về defaultValue nếu null/rỗng/sai định dạng. */
    public static Float parseFloat(String raw, Float defaultValue) {
        if (raw == null || raw.trim().isEmpty()) return defaultValue;
        try {
            return Float.parseFloat(raw.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Kiểm tra status course nằm trong danh sách cho phép; trả về null nếu không hợp lệ/rỗng. */
    public static String courseStatusFor(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        String value = raw.trim();
        return COURSE_STATUS_ALLOWED.contains(value) ? value : null;
    }

    /** Chuyển cờ active "1" -> true, mọi giá trị khác -> false. */
    public static boolean activeFlagFor(String raw) {
        return "1".equals(raw);
    }

    /** Trim chuỗi; trả về null nếu chuỗi gốc là null. */
    public static String trim(String s) {
        return s == null ? null : s.trim();
    }
}