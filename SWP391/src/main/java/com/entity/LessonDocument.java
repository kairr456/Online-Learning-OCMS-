package com.entity;

public class LessonDocument {
    private int lessonId;
    private String documentUrl;
    private String documentType;
    private int pageCount;
    private boolean downloadAllowed;

    public LessonDocument() {
    }

    public LessonDocument(int lessonId, String documentUrl, String documentType, int pageCount, boolean downloadAllowed) {
        this.lessonId = lessonId;
        this.documentUrl = documentUrl;
        this.documentType = documentType;
        this.pageCount = pageCount;
        this.downloadAllowed = downloadAllowed;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getDocumentUrl() {
        return documentUrl;
    }

    public void setDocumentUrl(String documentUrl) {
        this.documentUrl = documentUrl;
    }

    public String getDocumentType() {
        return documentType;
    }

    public void setDocumentType(String documentType) {
        this.documentType = documentType;
    }

    public int getPageCount() {
        return pageCount;
    }

    public void setPageCount(int pageCount) {
        this.pageCount = pageCount;
    }

    public boolean isDownloadAllowed() {
        return downloadAllowed;
    }

    public void setDownloadAllowed(boolean downloadAllowed) {
        this.downloadAllowed = downloadAllowed;
    }
}
