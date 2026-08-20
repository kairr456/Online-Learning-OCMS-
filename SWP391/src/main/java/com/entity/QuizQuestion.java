package com.entity;

import java.sql.Timestamp;

public class QuizQuestion {
    private Integer id;
    private Integer courseId;
    private Integer lessonId;
    private Integer groupId;
    private String questionText;
    private Integer points;
    private String status;
    private Timestamp createdDate;

    public QuizQuestion() {}

    public QuizQuestion(Integer id, Integer courseId, Integer lessonId, Integer groupId, String questionText, Integer points, String status, Timestamp createdDate) {
        this.id = id;
        this.courseId = courseId;
        this.lessonId = lessonId;
        this.groupId = groupId;
        this.questionText = questionText;
        this.points = points;
        this.status = status;
        this.createdDate = createdDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }
    public Integer getGroupId() { return groupId; }
    public void setGroupId(Integer groupId) { this.groupId = groupId; }
    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }
    public Integer getPoints() { return points; }
    public void setPoints(Integer points) { this.points = points; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
}
