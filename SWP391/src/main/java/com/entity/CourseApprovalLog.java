package com.entity;

import java.time.LocalDateTime;

public class CourseApprovalLog {
    private int id;
    private int courseId;
    private String courseName;
    private String action;
    private String oldStatus;
    private String newStatus;
    private int actorId;
    private String actorName;
    private String note;
    private String ipAddress;
    private LocalDateTime createdDate;

    public CourseApprovalLog() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }
    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }
    public int getActorId() { return actorId; }
    public void setActorId(int actorId) { this.actorId = actorId; }
    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }
}