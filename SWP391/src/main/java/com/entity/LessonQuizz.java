package com.entity;

public class LessonQuizz {
    private Integer id;
    private Integer lessonId;
    private Integer numberOfQuestions;
    private Integer timeLimitMinutes;
    private Integer maxRetakes;
    private Integer passingScore;
    private Integer questionGroupId;

    public LessonQuizz() {}

    public LessonQuizz(Integer id, Integer lessonId, Integer numberOfQuestions, Integer timeLimitMinutes, Integer maxRetakes, Integer passingScore, Integer questionGroupId) {
        this.id = id;
        this.lessonId = lessonId;
        this.numberOfQuestions = numberOfQuestions;
        this.timeLimitMinutes = timeLimitMinutes;
        this.maxRetakes = maxRetakes;
        this.passingScore = passingScore;
        this.questionGroupId = questionGroupId;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }
    public Integer getNumberOfQuestions() { return numberOfQuestions; }
    public void setNumberOfQuestions(Integer numberOfQuestions) { this.numberOfQuestions = numberOfQuestions; }
    public Integer getTimeLimitMinutes() { return timeLimitMinutes; }
    public void setTimeLimitMinutes(Integer timeLimitMinutes) { this.timeLimitMinutes = timeLimitMinutes; }
    public Integer getMaxRetakes() { return maxRetakes; }
    public void setMaxRetakes(Integer maxRetakes) { this.maxRetakes = maxRetakes; }
    public Integer getPassingScore() { return passingScore; }
    public void setPassingScore(Integer passingScore) { this.passingScore = passingScore; }
    public Integer getQuestionGroupId() { return questionGroupId; }
    public void setQuestionGroupId(Integer questionGroupId) { this.questionGroupId = questionGroupId; }
}
