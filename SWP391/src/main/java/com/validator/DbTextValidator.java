package com.validator;

public class DbTextValidator {

    /**
     * Validates that the given string value does not exceed the specified maximum length.
     * Throws IllegalArgumentException with a clear message if it does.
     * Null values are ignored (assumed valid or handled by other checks).
     *
     * @param value the string to check
     * @param maxLength the maximum allowed length
     * @param fieldName the user-friendly field name for the exception message
     */
    public static void validateLength(String value, int maxLength, String fieldName) {
        if (value != null && value.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " không được vượt quá " + maxLength + " ký tự (độ dài hiện tại: " + value.length() + ")!");
        }
    }
}
