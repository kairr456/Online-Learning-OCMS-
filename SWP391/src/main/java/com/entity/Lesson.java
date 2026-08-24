package com.entity;

import java.sql.Timestamp;

public class Lesson {
    private Integer id;
    private Integer sectionId;
    private String title;
    private String description;
    private String type;
    private Integer orderNumber;
    private Integer durationMinutes;
    private String status;
    private Integer createdBy;
    private Timestamp createdDate;
    private Timestamp modifiedDate;

    // Additional fields for convenience
    private String textContent;
    private String videoUrl;
    private String fileUrl;
    private LessonQuizz quizConfig;

    public Lesson() {}

    public Lesson(Integer id, Integer sectionId, String title, String description, String type, Integer orderNumber, Integer durationMinutes, String status, Integer createdBy, Timestamp createdDate, Timestamp modifiedDate) {
        this.id = id;
        this.sectionId = sectionId;
        this.title = title;
        this.description = description;
        this.type = type;
        this.orderNumber = orderNumber;
        this.durationMinutes = durationMinutes;
        this.status = status;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.modifiedDate = modifiedDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Integer getOrderNumber() { return orderNumber; }
    public void setOrderNumber(Integer orderNumber) { this.orderNumber = orderNumber; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
    public Timestamp getModifiedDate() { return modifiedDate; }
    public void setModifiedDate(Timestamp modifiedDate) { this.modifiedDate = modifiedDate; }

    public String getTextContent() { return textContent; }
    public void setTextContent(String textContent) { this.textContent = textContent; }
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
    public LessonQuizz getQuizConfig() { return quizConfig; }
    public void setQuizConfig(LessonQuizz quizConfig) { this.quizConfig = quizConfig; }
}
