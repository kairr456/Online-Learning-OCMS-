/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.courseCRUD;

import com.DAO.LessonDAO;
import com.entity.Lesson;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "LessonDetailsController", urlPatterns = {"/lesson-details"})
public class LessonDetails extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String lessonIdParam = request.getParameter("id");
        if (lessonIdParam == null || lessonIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdParam);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int courseId = lessonDAO.getCourseIdBySectionId(lesson.getSectionId());
            
            boolean isEnrolled = false;
            com.entity.Account account = (com.entity.Account) request.getSession().getAttribute("account");
            if (account != null) {
                com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
                com.entity.Course course = courseDAO.findById(courseId);
                if (course != null && course.getCreatedBy() == account.getId()) {
                    isEnrolled = true;
                } else {
                    com.DAO.CourseRegistrationDAO regDAO = new com.DAO.CourseRegistrationDAO();
                    java.util.List<com.entity.Course> enrolledCourses = regDAO.getCoursesByAccountId(account.getId());
                    for (com.entity.Course c : enrolledCourses) {
                        if (c.getId() == courseId) {
                            isEnrolled = true;
                            break;
                        }
                    }
                }
            }
            
            int firstLessonId = -1;
            java.util.List<com.entity.Section> sections = lessonDAO.getSectionsByCourseId(courseId);
            if (sections != null && !sections.isEmpty()) {
                java.util.List<com.entity.Lesson> firstSectionLessons = lessonDAO.getLessonsBySectionId(sections.get(0).getId());
                if (firstSectionLessons != null && !firstSectionLessons.isEmpty()) {
                    firstLessonId = firstSectionLessons.get(0).getId();
                }
            }
            
            if (!isEnrolled && lessonId != firstLessonId) {
                // Not enrolled and not the free trial lesson
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId);
                return;
            }

            // Get the rich text block-built content
            String lessonContent = lessonDAO.getLessonText(lessonId);
            
            if ("video".equals(lesson.getType())) {
                String videoUrl = lessonDAO.getLessonYoutube(lessonId);
                request.setAttribute("videoUrl", videoUrl);
            } else if ("quiz".equals(lesson.getType()) && account != null) {
                com.DAO.QuizDAO quizDAO = new com.DAO.QuizDAO();
                java.util.Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
                if (lessonQuiz == null) {
                    if (lessonContent != null && lessonContent.startsWith("Quiz ID: ")) {
                        try {
                            int qId = Integer.parseInt(lessonContent.substring(9).trim());
                            lessonQuiz = quizDAO.getLessonQuizById(qId);
                        } catch (Exception ex) {}
                    }
                }
                
                if (lessonQuiz != null) {
                    int quizId = (Integer) lessonQuiz.get("id");
                    int maxRetakes = (Integer) lessonQuiz.get("max_retakes");
                    int userAttempts = quizDAO.countUserAttemptsForQuiz(account.getId(), quizId);
                    
                    request.setAttribute("maxRetakes", maxRetakes);
                    request.setAttribute("userAttempts", userAttempts);
                }
            }

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonContent", lessonContent);
            request.setAttribute("courseId", courseId);

            request.getRequestDispatcher("/view/courseCRUD/lesson-details.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }
}
