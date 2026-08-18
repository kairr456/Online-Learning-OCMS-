package com.entity;

import java.sql.Timestamp;

public class LessonProgress {
    private Integer id;
    private Integer accountId;
    private Integer lessonId;
    private Boolean completed;
    private Timestamp completedAt;

    public LessonProgress() {
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getAccountId() { return accountId; }
    public void setAccountId(Integer accountId) { this.accountId = accountId; }
    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }
    public Boolean getCompleted() { return completed; }
    public void setCompleted(Boolean completed) { this.completed = completed; }
    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
}