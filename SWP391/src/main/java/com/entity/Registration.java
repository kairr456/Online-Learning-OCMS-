package com.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;



public class Registration {
    private int id;
    private String email;
    private int accountId;
    private Timestamp registrationTime;
    private int courseId;
    private String packages;
    private BigDecimal totalCost;
    private String status;
    private Timestamp validFrom;
    private Timestamp validTo;
    private int lastUpdateByPerson;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public Timestamp getRegistrationTime() {
        return registrationTime;
    }

    public void setRegistrationTime(Timestamp registrationTime) {
        this.registrationTime = registrationTime;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getPackages() {
        return packages;
    }

    public void setPackages(String packages) {
        this.packages = packages;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getValidFrom() {
        return validFrom;
    }

    public void setValidFrom(Timestamp validFrom) {
        this.validFrom = validFrom;
    }

    public Timestamp getValidTo() {
        return validTo;
    }

    public void setValidTo(Timestamp validTo) {
        this.validTo = validTo;
    }

    public int getLastUpdateByPerson() {
        return lastUpdateByPerson;
    }

    public void setLastUpdateByPerson(int lastUpdateByPerson) {
        this.lastUpdateByPerson = lastUpdateByPerson;
    }
    
    
}
