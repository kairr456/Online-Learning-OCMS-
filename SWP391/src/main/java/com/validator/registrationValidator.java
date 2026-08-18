package com.validator;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Validator cho trang "Quản lý đăng ký khóa học" (admin /admin/registrations).
 * Chỉ xử lý tham số tìm kiếm/lọc/phân trang — không truy cập DB.
 * Mọi hàm static, trả về giá trị "an toàn" để controller dùng thẳng.
 */
public class registrationValidator {

    // Giới hạn độ dài từ khóa tìm kiếm (tránh query quá dài)
    public static final int KEYWORD_MAX_LENGTH = 100;

    // Danh sách status hợp lệ của bảng registration
    private static final Set<String> STATUS_ALLOWED =
            new HashSet<>(Arrays.asList("Approved", "Active", "Pending", "Success", "Failed"));

    private registrationValidator() {
    }

    /**
     * Chuẩn hóa từ khóa: trim + giới hạn độ dài.
     * Trả về null nếu rỗng (controller bỏ qua điều kiện search).
     */
    public static String keywordFor(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) return null;
        return trimmed.length() > KEYWORD_MAX_LENGTH
                ? trimmed.substring(0, KEYWORD_MAX_LENGTH)
                : trimmed;
    }

    /**
     * Kiểm tra status nằm trong danh sách cho phép; trả về null nếu không hợp lệ/rỗng.
     */
    public static String statusFor(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        String value = raw.trim();
        return STATUS_ALLOWED.contains(value) ? value : null;
    }

    /**
     * Parse tham số page thành số nguyên >= 1; trả về 1 nếu không phải số hợp lệ.
     */
    public static int pageFor(String raw) {
        if (raw == null || raw.trim().isEmpty()) return 1;
        try {
            int page = Integer.parseInt(raw.trim());
            return page < 1 ? 1 : page;
        } catch (NumberFormatException e) {
            return 1;
        }
    }
}