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

    public static String validate(String headline, String bio, String yearsExperienceStr,
                                   String education, String certifications,
                                   String linkedinUrl, String websiteUrl, String avatarUrl,
                                   Part cvFile) {

        // --- headline ---
        if (isBlank(headline)) {
            return "Tiêu đề chuyên môn không được để trống.";
        }
        String hl = headline.trim();
        if (hl.length() < 5 || hl.length() > 255) {
            return "Tiêu đề chuyên môn phải từ 5 đến 255 ký tự.";
        }

        // --- bio ---
        if (isBlank(bio)) {
            return "Giới thiệu bản thân không được để trống.";
        }
        String b = bio.trim();
        if (b.length() < 50 || b.length() > 2000) {
            return "Giới thiệu bản thân phải từ 50 đến 2000 ký tự.";
        }

        // --- yearsExperience ---
        if (isBlank(yearsExperienceStr)) {
            return "Số năm kinh nghiệm không được để trống.";
        }
        int yearsExp;
        try {
            yearsExp = Integer.parseInt(yearsExperienceStr.trim());
        } catch (NumberFormatException e) {
            return "Số năm kinh nghiệm phải là số nguyên.";
        }
        if (yearsExp < 0 || yearsExp > 50) {
            return "Số năm kinh nghiệm phải từ 0 đến 50.";
        }

        // --- education (optional) ---
        if (education != null && education.trim().length() > 255) {
            return "Trình độ học vấn không quá 255 ký tự.";
        }

        // --- certifications (optional) ---
        // no limit

        // --- linkedinUrl (optional) ---
        if (linkedinUrl != null && !linkedinUrl.trim().isEmpty()) {
            String u = linkedinUrl.trim();
            if (!URL_PATTERN.matcher(u).matches()) {
                return "Link LinkedIn không đúng định dạng URL.";
            }
            if (!u.toLowerCase().contains("linkedin.com")) {
                return "Link LinkedIn phải là địa chỉ linkedin.com.";
            }
        }

        // --- websiteUrl (optional) ---
        if (websiteUrl != null && !websiteUrl.trim().isEmpty()) {
            String u = websiteUrl.trim();
            if (!URL_PATTERN.matcher(u).matches()) {
                return "Website cá nhân không đúng định dạng URL.";
            }
        }

        // --- avatarUrl (optional) ---
        if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
            String u = avatarUrl.trim();
            if (!URL_PATTERN.matcher(u).matches()) {
                return "Link ảnh đại diện không đúng định dạng URL.";
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