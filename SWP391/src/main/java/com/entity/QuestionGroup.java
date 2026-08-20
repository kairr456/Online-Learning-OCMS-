package com.entity;

import java.sql.Timestamp;

public class QuestionGroup {
    private Integer id;
    private Integer courseId;
    private String name;
    private Timestamp createdDate;
    private int questionCount;

    public QuestionGroup() {}

    public QuestionGroup(Integer id, Integer courseId, String name, Timestamp createdDate) {
        this.id = id;
        this.courseId = courseId;
        this.name = name;
        this.createdDate = createdDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }
    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
}

