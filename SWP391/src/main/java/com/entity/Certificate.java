package com.entity;

import java.time.LocalDateTime;

/**
 * Chứng chỉ đã cấp cho 1 học viên của 1 khóa học.
 * Gắn cứng course_id (FK bắt buộc) + snapshot course_name/student_name nên
 * luôn hiển thị được ngay cả khi template/khóa bị xóa. backgroundUrl/title
 * lấy JOIN từ template (chỉ để render, không phải FK).
 */
public class Certificate {
    private int id;
    private Integer templateId;    // null nếu template đã bị xóa
    private int accountId;
    private int courseId;
    private String courseName;
    private String studentName;
    private String certificateCode;
    private LocalDateTime issuedDate;
    private String backgroundUrl;  // JOIN certificate_template (render)
    private String title;          // JOIN certificate_template (render)

    public Certificate() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getTemplateId() { return templateId; }
    public void setTemplateId(Integer templateId) { this.templateId = templateId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getCertificateCode() { return certificateCode; }
    public void setCertificateCode(String certificateCode) { this.certificateCode = certificateCode; }
    public LocalDateTime getIssuedDate() { return issuedDate; }
    public void setIssuedDate(LocalDateTime issuedDate) { this.issuedDate = issuedDate; }
    public String getBackgroundUrl() { return backgroundUrl; }
    public void setBackgroundUrl(String backgroundUrl) { this.backgroundUrl = backgroundUrl; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    /** fmt:formatDate cần java.util.Date (JSP không format được LocalDateTime). */
    public java.util.Date getIssuedDateAsDate() {
        return issuedDate == null ? null : java.sql.Timestamp.valueOf(issuedDate);
    }
}