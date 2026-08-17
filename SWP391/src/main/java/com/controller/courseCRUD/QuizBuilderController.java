package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.LessonDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.Lesson;
import com.entity.Section;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "QuizBuilderController", urlPatterns = {"/quiz-builder"})
public class QuizBuilderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        LessonDAO lessonDAO = new LessonDAO();

        List<Course> courses = courseDAO.findByCreator(account.getId());
        Map<Integer, List<Section>> courseSectionsMap = new HashMap<>();

        for (Course c : courses) {
            courseSectionsMap.put(c.getId(), lessonDAO.getSectionsByCourseId(c.getId()));
        }

        request.setAttribute("courses", courses);
        request.setAttribute("courseSectionsJson", new Gson().toJson(courseSectionsMap));

        request.getRequestDispatcher("/view/courseCRUD/quiz-builder.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // General Settings
            String sectionIdStr = request.getParameter("sectionId");
            int sectionId = (sectionIdStr != null && !sectionIdStr.trim().isEmpty()) ? Integer.parseInt(sectionIdStr) : 0;
            
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            
            String durationStr = request.getParameter("durationMinutes");
            int duration = (durationStr != null && !durationStr.isEmpty()) ? Integer.parseInt(durationStr) : 15;
            
            String orderStr = request.getParameter("orderNumber");
            int order = (orderStr != null && !orderStr.isEmpty()) ? Integer.parseInt(orderStr) : 1;
            
            String passingStr = request.getParameter("passingScore");
            int passingScore = (passingStr != null && !passingStr.isEmpty()) ? Integer.parseInt(passingStr) : 80;
            
            String action = request.getParameter("action"); // 'draft' or 'publish'

            Lesson lesson = new Lesson();
            lesson.setSectionId(sectionId);
            lesson.setTitle(title);
            lesson.setDescription(description);
            lesson.setOrderNumber(order);
            lesson.setDurationMinutes(duration);
            lesson.setStatus("publish".equals(action) ? "active" : "inactive");

            QuizDAO quizDAO = new QuizDAO();
            
            // 1. Insert Lesson (pass accountId as created_by)
            int lessonId = quizDAO.insertQuizLesson(lesson, account.getId());
            if (lessonId > 0) {
                // 2. Insert lesson_quiz
                int quizId = quizDAO.insertLessonQuiz(lessonId, passingScore);
                
                if (quizId > 0) {
                    // 3. Process Questions
                    String[] qIds = request.getParameterValues("qIds"); // Array of question IDs in the form
                    if (qIds != null) {
                        for (int i = 0; i < qIds.length; i++) {
                            String qId = qIds[i];
                            String qText = request.getParameter("q_text_" + qId);
                            int points = Integer.parseInt(request.getParameter("q_points_" + qId));
                            
                            int dbQuestionId = quizDAO.insertQuizQuestion(quizId, qText, points, i + 1);
                            
                            if (dbQuestionId > 0) {
                                // 4. Process Answers for this Question
                                String[] aIds = request.getParameterValues("aIds_" + qId);
                                String correctAnswerId = request.getParameter("a_correct_" + qId); // The ID of the correct answer
                                
                                if (aIds != null) {
                                    for (int j = 0; j < aIds.length; j++) {
                                        String aId = aIds[j];
                                        String aText = request.getParameter("a_text_" + qId + "_" + aId);
                                        boolean isCorrect = aId.equals(correctAnswerId);
                                        
                                        quizDAO.insertQuizAnswer(dbQuestionId, aText, isCorrect, j + 1);
                                    }
                                }
                            }
                        }
                    }
                    session.setAttribute("message", "publish".equals(action) ? "Quiz Published Successfully!" : "Quiz Saved as Draft.");
                    session.setAttribute("messageType", "success");
                }
            } else {
                throw new Exception("Failed to save lesson.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error saving quiz: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
    }
}
