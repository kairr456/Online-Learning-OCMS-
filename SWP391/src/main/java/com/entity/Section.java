package com.entity;

import java.sql.Date;

public class Section {
    private Integer id;
    private Integer courseId;
    private String title;
    private String description;
    private Integer orderNumber;
    private String status;
    private Date createdDate;
    private Date modifiedDate;

    public Section() {
    }

    public Section(Integer id, Integer courseId, String title, String description,
                   Integer orderNumber, String status, Date createdDate, Date modifiedDate) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.orderNumber = orderNumber;
        this.status = status;
        this.createdDate = createdDate;
        this.modifiedDate = modifiedDate;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public Date getModifiedDate() {
        return modifiedDate;
    }

    public void setModifiedDate(Date modifiedDate) {
        this.modifiedDate = modifiedDate;
    }
}