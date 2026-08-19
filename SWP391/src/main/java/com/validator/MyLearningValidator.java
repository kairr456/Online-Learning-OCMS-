package com.validator;

import java.util.regex.Pattern;

/**
 * Validator cho các trang thuộc khu vực "My Learning".
 * Tập trung các kiểm tra rải rác trong controller về một nơi duy nhất.
 * Các phương thức trả về chuỗi lỗi đầu tiên nếu không hợp lệ, hoặc null nếu hợp lệ.
 */
public class MyLearningValidator {

    private static final Pattern REMINDER_TIME_PATTERN =
            Pattern.compile("^(?:[01]\\d|2[0-3]):[0-5]\\d$");

    private MyLearningValidator() {
    }

    /**
     * Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng hay không.
     */
    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Kiểm tra id bắt buộc: không được để trống và phải là số.
     */
    public static String validateId(String fieldName, String value) {
        if (isBlank(value)) {
            return "Missing " + fieldName + ".";
        }
        if (!value.trim().matches("\\d+")) {
            return fieldName + " must be a number.";
        }
        return null;
    }

    /**
     * Kiểm tra id không bắt buộc: chỉ kiểm tra khi có giá trị.
     */
    public static String validateOptionalId(String fieldName, String value) {
        if (isBlank(value)) {
            return null;
        }
        return validateId(fieldName, value);
    }

    public static String validateCourseId(String value) {
        return validateId("courseId", value);
    }

    public static String validateListId(String value) {
        return validateId("listId", value);
    }

    public static String validateLessonId(String value) {
        return validateId("lessonId", value);
    }

    public static String validateQuizId(String value) {
        return validateId("quizId", value);
    }

    /**
     * Kiểm tra tiêu đề danh sách học tập.
     */
    public static String validateListTitle(String title) {
        if (isBlank(title)) {
            return "Missing list title.";
        }
        return null;
    }

    /**
     * Kiểm tra danh sách ngày reminder (phân tách bằng dấu phẩy, mỗi ngày từ 1-7).
     */
    public static String validateReminderDays(String days) {
        if (isBlank(days)) {
            return "Please select at least one day.";
        }
        String[] parts = days.split(",");
        for (String part : parts) {
            if (!part.trim().matches("[1-7]")) {
                return "Invalid reminder day.";
            }
        }
        return null;
    }

    /**
     * Kiểm tra giờ nhắc nhở định dạng HH:mm (rỗng sẽ được để mặc định ở controller).
     */
    public static String validateReminderTime(String time) {
        if (isBlank(time)) {
            return null;
        }
        if (!REMINDER_TIME_PATTERN.matcher(time.trim()).matches()) {
            return "Reminder time must be in HH:mm format.";
        }
        return null;
    }
}