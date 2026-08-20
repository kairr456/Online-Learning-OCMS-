package com.controller.courseCRUD;

import com.DAO.LessonDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Lesson;
import com.validator.MyLearningValidator;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "TakeQuizController", urlPatterns = {"/take-quiz"})
public class TakeQuizController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String lessonIdStr = request.getParameter("lessonId");
        if (lessonIdStr == null || lessonIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }
        
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdStr);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null || !"quiz".equals(lesson.getType())) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            QuizDAO quizDAO = new QuizDAO();
            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);
                        
                        // Fetch the ORIGINAL lesson to get its duration and description
                        if (lessonQuiz != null) {
                            int originalLessonId = (Integer) lessonQuiz.get("lesson_id");
                            Lesson originalLesson = lessonDAO.getLessonById(originalLessonId);
                            if (originalLesson != null) {
                                // Override duration and description
                                lesson.setDurationMinutes(originalLesson.getDurationMinutes());
                                lesson.setDescription(originalLesson.getDescription());
                            }
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
            if (lessonQuiz == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int quizId = (Integer) lessonQuiz.get("id");
            int maxRetakes = (Integer) lessonQuiz.get("max_retakes");
            
            // Check retake limits
            int userAttempts = quizDAO.countUserAttemptsForQuiz(account.getId(), quizId);
            if (maxRetakes != -1) {
                if (userAttempts >= maxRetakes) {
                    session.setAttribute("errorMsg", "You have reached the maximum number of attempts (" + maxRetakes + ") for this quiz. Viewing your past results.");
                    response.sendRedirect(request.getContextPath() + "/quiz-result?lessonId=" + lessonId);
                    return;
                }
            }
            
            request.setAttribute("userAttempts", userAttempts);
            request.setAttribute("maxRetakes", maxRetakes);
            List<Map<String, Object>> allQuestions = quizDAO.getQuestionsByQuizId(quizId);
            java.util.Collections.shuffle(allQuestions);
            
            int numToTake = (Integer) lessonQuiz.get("number_of_questions");
            List<Map<String, Object>> questions = allQuestions;
            if (numToTake > 0 && numToTake < allQuestions.size()) {
                questions = allQuestions.subList(0, numToTake);
            }
            
            // Extract IDs for hidden input
            StringBuilder servedIds = new StringBuilder();
            for (Map<String, Object> q : questions) {
                if (servedIds.length() > 0) servedIds.append(",");
                servedIds.append(q.get("id"));
            }
            request.setAttribute("servedQuestionIds", servedIds.toString());

            // Map questionId -> answers
            Map<Integer, List<Map<String, Object>>> questionAnswersMap = new HashMap<>();
            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                questionAnswersMap.put(qId, quizDAO.getAnswersByQuestionId(qId));
            }

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonQuiz", lessonQuiz);
            request.setAttribute("questions", questions);
            request.setAttribute("questionAnswersMap", questionAnswersMap);
            request.setAttribute("courseId", lessonDAO.getCourseIdBySectionId(lesson.getSectionId()));

            request.getRequestDispatcher("/view/course_learning/take-quiz.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        try {
            String quizIdParam = request.getParameter("quizId");
            String lessonIdParam = request.getParameter("lessonId");
            String idError = MyLearningValidator.validateQuizId(quizIdParam);
            if (idError == null) {
                idError = MyLearningValidator.validateLessonId(lessonIdParam);
            }
            if (idError != null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + idError + "\"}");
                return;
            }
            int quizId = Integer.parseInt(quizIdParam);
            int lessonId = Integer.parseInt(lessonIdParam);
            
            QuizDAO quizDAO = new QuizDAO();
            LessonDAO lessonDAO = new LessonDAO();
            List<Map<String, Object>> allQuestions = quizDAO.getQuestionsByQuizId(quizId);
            String servedIdsParam = request.getParameter("servedQuestionIds");
            List<Map<String, Object>> questions = new java.util.ArrayList<>();
            if (servedIdsParam != null && !servedIdsParam.isEmpty()) {
                String[] servedIdsArray = servedIdsParam.split(",");
                java.util.Set<Integer> servedIdsSet = new java.util.HashSet<>();
                for (String s : servedIdsArray) {
                    servedIdsSet.add(Integer.parseInt(s.trim()));
                }
                for (Map<String, Object> q : allQuestions) {
                    if (servedIdsSet.contains(q.get("id"))) {
                        questions.add(q);
                    }
                }
            } else {
                questions = allQuestions; // fallback
            }
            
            int totalPoints = 0;
            int earnedPoints = 0;
            int totalCorrectQuestions = 0;
            
            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                int points = (Integer) q.get("points");
                totalPoints += points;
                
                String selectedAnswerIdStr = request.getParameter("q_" + qId);
                if (selectedAnswerIdStr != null && !selectedAnswerIdStr.isEmpty()) {
                    int selectedAnswerId = Integer.parseInt(selectedAnswerIdStr);
                    
                    List<Map<String, Object>> answers = quizDAO.getAnswersByQuestionId(qId);
                    for (Map<String, Object> a : answers) {
                        int aId = (Integer) a.get("id");
                        boolean isCorrect = (Boolean) a.get("is_correct");
                        
                        if (aId == selectedAnswerId && isCorrect) {
                            earnedPoints += points;
                            totalCorrectQuestions++;
                            break;
                        }
                    }
                }
            }
            
            float scorePercent = 0;
            if (totalPoints > 0) {
                scorePercent = ((float) earnedPoints / totalPoints) * 100;
            } else if (questions.size() > 0) {
                scorePercent = ((float) totalCorrectQuestions / questions.size()) * 100;
            }
            
            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
            int passingScore = 0;
            if (lessonQuiz != null) {
                passingScore = (Integer) lessonQuiz.get("passing_score");
            }
            boolean passed = scorePercent >= passingScore;
            
            // Save attempt
            int attemptId = quizDAO.insertQuizAttempt(account.getId(), quizId, scorePercent, passed);
            
            if (attemptId > 0) {
                // Save individual answers
                for (Map<String, Object> q : questions) {
                    int qId = (Integer) q.get("id");
                    String selectedAnswerIdStr = request.getParameter("q_" + qId);
                    if (selectedAnswerIdStr != null && !selectedAnswerIdStr.isEmpty()) {
                        int selectedAnswerId = Integer.parseInt(selectedAnswerIdStr);
                        quizDAO.insertQuizAttemptAnswer(attemptId, qId, selectedAnswerId);
                    }
                }
            }
            
            // Send back JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            String jsonResponse = String.format(
                "{\"success\": true, \"scorePercent\": %.2f, \"totalCorrect\": %d, \"totalQuestions\": %d, \"passed\": %b, \"passingScore\": %d}",
                scorePercent, totalCorrectQuestions, questions.size(), passed, passingScore
            );
            response.getWriter().write(jsonResponse);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
