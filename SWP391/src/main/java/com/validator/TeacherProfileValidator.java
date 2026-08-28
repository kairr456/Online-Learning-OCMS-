package com.validator;

import jakarta.servlet.http.Part;
import java.util.regex.Pattern;

public class TeacherProfileValidator {

    private static final Pattern URL_PATTERN = Pattern.compile(
            "^(https?://)?([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
    );

    private static final String[] ALLOWED_CV_TYPES = {
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    };

    private static final long MAX_CV_SIZE = 5 * 1024 * 1024; // 5MB

    private TeacherProfileValidator() {}

    public static String validate(String specialization, String bio, String experienceYearsStr,
                                   String portfolioUrl, Part cvFile) {

        // --- specialization (required) ---
        if (isBlank(specialization)) {
            return "Chuyên môn không được để trống.";
        }
        String spec = specialization.trim();
        if (spec.length() < 5) {
            return "Chuyên môn phải có ít nhất 5 ký tự.";
        }
        if (spec.length() > 255) {
            return "Chuyên môn không được vượt quá 255 ký tự.";
        }

        // --- bio (required) ---
        if (isBlank(bio)) {
            return "Giới thiệu bản thân không được để trống.";
        }
        String b = bio.trim();
        if (b.length() < 50) {
            return "Giới thiệu bản thân phải có ít nhất 50 ký tự.";
        }
        if (b.length() > 2000) {
            return "Giới thiệu bản thân không được vượt quá 2000 ký tự.";
        }

        // --- experienceYears (required) ---
        if (isBlank(experienceYearsStr)) {
            return "Số năm kinh nghiệm không được để trống.";
        }
        int expYears;
        try {
            expYears = Integer.parseInt(experienceYearsStr.trim());
        } catch (NumberFormatException e) {
            return "Số năm kinh nghiệm phải là số nguyên.";
        }
        if (expYears < 0 || expYears > 60) {
            return "Số năm kinh nghiệm phải từ 0 đến 60.";
        }

        // --- portfolioUrl (optional) ---
        if (portfolioUrl != null && !portfolioUrl.trim().isEmpty()) {
            String u = portfolioUrl.trim();
            if (!URL_PATTERN.matcher(u).matches()) {
                return "Link Portfolio không đúng định dạng URL.";
            }
        }

        // --- cvFile (optional) ---
        if (cvFile != null && cvFile.getSize() > 0) {
            String contentType = cvFile.getContentType();
            boolean validType = false;
            for (String allowed : ALLOWED_CV_TYPES) {
                if (allowed.equals(contentType)) {
                    validType = true;
                    break;
                }
            }
            if (!validType) {
                return "File CV chỉ chấp nhận định dạng PDF, DOC, DOCX.";
            }
            if (cvFile.getSize() > MAX_CV_SIZE) {
                return "File CV không được vượt quá 5MB.";
            }
        }

        return null; // valid
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static boolean isValidUrl(String url) {
        return url != null && !url.trim().isEmpty() && URL_PATTERN.matcher(url.trim()).matches();
    }
}