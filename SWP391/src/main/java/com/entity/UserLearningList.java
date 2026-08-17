package com.entity;

import java.util.ArrayList;
import java.util.List;

public class UserLearningList {
    private int id;
    private int accountId;
    private String title;
    private String description;
    private List<Course> courses = new ArrayList<>();

    public UserLearningList() {}

    public UserLearningList(int id, int accountId, String title, String description) {
        this.id = id;
        this.accountId = accountId;
        this.title = title;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<Course> getCourses() { return courses; }
    public void setCourses(List<Course> courses) { this.courses = courses; }
}