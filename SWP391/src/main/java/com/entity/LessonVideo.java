package com.entity;

public class LessonVideo {
    private Integer lessonId;        // INT, Primary Key
    private String videoUrl;         // TEXT
    private String videoProvider;    // ENUM('youtube', 'vimeo', etc.)
    private Integer videoDuration;   // INT

    public LessonVideo() {
    }

    public LessonVideo(Integer lessonId, String videoUrl, String videoProvider, Integer videoDuration) {
        this.lessonId = lessonId;
        this.videoUrl = videoUrl;
        this.videoProvider = videoProvider;
        this.videoDuration = videoDuration;
    }

    public Integer getLessonId() {
        return lessonId;
    }

    public void setLessonId(Integer lessonId) {
        this.lessonId = lessonId;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public String getVideoProvider() {
        return videoProvider;
    }

    public void setVideoProvider(String videoProvider) {
        this.videoProvider = videoProvider;
    }

    public Integer getVideoDuration() {
        return videoDuration;
    }

    public void setVideoDuration(Integer videoDuration) {
        this.videoDuration = videoDuration;
    }
}
