
<%@ page import="com.DAO.*, com.entity.*, java.util.*" %>
<%
    LessonDAO lessonDAO = new LessonDAO();
    LessonQuizz q = lessonDAO.getLessonQuizConfig(305);
    out.println("Lesson 305 quizConfig: " + (q != null ? q.getQuestionGroupId() : "null"));
    
    // Check if LessonController has the method (reflection)
    try {
        Class<?> cls = Class.forName("com.controller.courseCRUD.LessonController");
        out.println("<br>LessonController loaded!");
    } catch(Exception e) {
        out.println("<br>Error: " + e.getMessage());
    }
%>
