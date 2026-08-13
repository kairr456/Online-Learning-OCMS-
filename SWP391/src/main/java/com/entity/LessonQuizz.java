package com.entity;

public class LessonQuizz {
    private Integer id;                // INT, Primary Key
    private Integer lessonId;

    public LessonQuizz() {
    }

    public LessonQuizz(Integer id, Integer lessonId) {
        this.id = id;
        this.lessonId = lessonId;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getLessonId() {
        return lessonId;
    }

    public void setLessonId(Integer lessonId) {
        this.lessonId = lessonId;
    }
}
