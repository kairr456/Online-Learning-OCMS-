package com.entity;

public class QuizAnswer {
    private Integer id;
    private Integer questionId;
    private String answerText;
    private Boolean isCorrect;
    private Integer orderNumber;

    public QuizAnswer() {
    }

    public QuizAnswer(Integer id, Integer questionId, String answerText, Boolean isCorrect, Integer orderNumber) {
        this.id = id;
        this.questionId = questionId;
        this.answerText = answerText;
        this.isCorrect = isCorrect;
        this.orderNumber = orderNumber;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getQuestionId() {
        return questionId;
    }

    public void setQuestionId(Integer questionId) {
        this.questionId = questionId;
    }

    public String getAnswerText() {
        return answerText;
    }

    public void setAnswerText(String answerText) {
        this.answerText = answerText;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public Integer getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(Integer orderNumber) {
        this.orderNumber = orderNumber;
    }
    
}
