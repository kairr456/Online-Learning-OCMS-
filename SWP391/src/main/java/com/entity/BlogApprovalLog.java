package com.entity;

import java.time.LocalDateTime;

/**
 * Entity lưu vết lịch sử phê duyệt blog (blog_approval_log)
 */
public class BlogApprovalLog {
    private int id;
    private int blogId;
    private String blogTitle;
    private String action;      // SUBMIT, APPROVE, REJECT
    private String oldStatus;
    private String newStatus;
    private int actorId;
    private String actorName;
    private String note;
    private String ipAddress;
    private LocalDateTime createdDate;

    public BlogApprovalLog() {}

    public BlogApprovalLog(int id, int blogId, String blogTitle, String action, 
                           String oldStatus, String newStatus, int actorId, 
                           String actorName, String note, String ipAddress, 
                           LocalDateTime createdDate) {
        this.id = id;
        this.blogId = blogId;
        this.blogTitle = blogTitle;
        this.action = action;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.actorId = actorId;
        this.actorName = actorName;
        this.note = note;
        this.ipAddress = ipAddress;
        this.createdDate = createdDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBlogId() { return blogId; }
    public void setBlogId(int blogId) { this.blogId = blogId; }

    public String getBlogTitle() { return blogTitle; }
    public void setBlogTitle(String blogTitle) { this.blogTitle = blogTitle; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public int getActorId() { return actorId; }
    public void setActorId(int actorId) { this.actorId = actorId; }

    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }
}
