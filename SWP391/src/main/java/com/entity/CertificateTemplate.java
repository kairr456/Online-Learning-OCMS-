package com.entity;

import java.time.LocalDateTime;

/**
 * Template chứng chỉ gắn với 1 khóa học (1 template/khóa).
 * GV upload ảnh nền + nhập tiêu đề; khi HV đạt 100% progress hệ thống
 * dùng template này để in chứng chỉ (tên HV, khóa, ngày, mã).
 */
public class CertificateTemplate {
    private int id;
    private int courseId;
    private String courseName;   // tên khóa (JOIN, chỉ dùng hiển thị)
    private String backgroundUrl;
    private String title;
    private int createdBy;
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;

    public CertificateTemplate() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    public String getBackgroundUrl() { return backgroundUrl; }
    public void setBackgroundUrl(String backgroundUrl) { this.backgroundUrl = backgroundUrl; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }
    public LocalDateTime getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(LocalDateTime updatedDate) { this.updatedDate = updatedDate; }
}