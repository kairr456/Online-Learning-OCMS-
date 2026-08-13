package com.entity;

import java.sql.Timestamp;

public class Review {
    private int id;
    private int courseId;
    private int accountId;
    private int rating;
    private String comment;
    private Timestamp createdDate;

    public Review() {
    }

    public Review(int id, int courseId, int accountId, int rating, String comment, Timestamp createdDate) {
        this.id = id;
        this.courseId = courseId;
        this.accountId = accountId;
        this.rating = rating;
        this.comment = comment;
        this.createdDate = createdDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
}
