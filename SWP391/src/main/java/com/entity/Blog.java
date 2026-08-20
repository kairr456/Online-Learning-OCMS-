package com.entity;

import java.sql.Timestamp;

public class Blog {
    private int id;
    private String title;
    private String thumbnail;
    private String briefInfo;
    private String content;
    private int categoryId;
    private int author;
    private Timestamp updatedDate;
    private Timestamp createdDate;
    private String status;

    // Helper display fields (from joins)
    private String authorName;
    private String authorEmail;
    private String categoryName;

    public Blog() {}

    public Blog(int id, String title, String thumbnail, String briefInfo, 
                String content, int categoryId, int author, 
                Timestamp updatedDate, Timestamp createdDate, String status) {
        this.id = id;
        this.title = title;
        this.thumbnail = thumbnail;
        this.briefInfo = briefInfo;
        this.content = content;
        this.categoryId = categoryId;
        this.author = author;
        this.updatedDate = updatedDate;
        this.createdDate = createdDate;
        this.status = status;
    }

    // Getter và Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getThumbnail() { return thumbnail; }
    public void setThumbnail(String thumbnail) { this.thumbnail = thumbnail; }

    public String getBriefInfo() { return briefInfo; }
    public void setBriefInfo(String briefInfo) { this.briefInfo = briefInfo; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public int getAuthor() { return author; }
    public void setAuthor(int author) { this.author = author; }

    public Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(Timestamp updatedDate) { this.updatedDate = updatedDate; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getAuthorEmail() { return authorEmail; }
    public void setAuthorEmail(String authorEmail) { this.authorEmail = authorEmail; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}