package com.entity;

import java.sql.Timestamp;

public class QuizQuestion {
    private Integer id;             // INT, Primary Key
    private Integer quizId;         // INT, Not Null
    private String questionText;    // TEXT, Not Null
    private Integer points;         // INT, Default '1'
    private Integer orderNumber;    // INT, Default '1'
    private String status;          // ENUM('active', 'inactive'), Default 'active'
    private Timestamp createdDate;       // DATETIME, Default CURRENT_TIMESTAMP
    private Timestamp modifiedDate;      // DATETIME, Default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    public QuizQuestion() {
    }

    public QuizQuestion(Integer id, Integer quizId, String questionText, Integer points, Integer orderNumber, String status, Timestamp createdDate, Timestamp modifiedDate) {
        this.id = id;
        this.quizId = quizId;
        this.questionText = questionText;
        this.points = points;
        this.orderNumber = orderNumber;
        this.status = status;
        this.createdDate = createdDate;
        this.modifiedDate = modifiedDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getQuizId() {
        return quizId;
    }

    public void setQuizId(Integer quizId) {
        this.quizId = quizId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public Integer getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(Integer orderNumber) {
        this.orderNumber = orderNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Timestamp getModifiedDate() {
        return modifiedDate;
    }

    public void setModifiedDate(Timestamp modifiedDate) {
        this.modifiedDate = modifiedDate;
    }
    
}
