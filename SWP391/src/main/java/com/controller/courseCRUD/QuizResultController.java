package com.controller.courseCRUD;

import com.DAO.LessonDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Lesson;
import com.validator.MyLearningValidator;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "QuizResultController", urlPatterns = {"/quiz-result"})
public class QuizResultController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
        response.setDateHeader("Expires", 0); // Proxies.
        
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        String lessonIdParam = request.getParameter("lessonId");
        if (lessonIdParam == null || lessonIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            String lessonIdError = MyLearningValidator.validateLessonId(lessonIdParam);
            if (lessonIdError != null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
            int lessonId = Integer.parseInt(lessonIdParam);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null || !"quiz".equals(lesson.getType())) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            QuizDAO quizDAO = new QuizDAO();
            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
            
            // Check if virtual quiz
            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);
                    } catch (Exception ex) {}
                }
            }
            
            if (lessonQuiz == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int quizId = (Integer) lessonQuiz.get("id");
            
            // Get all attempts for this user
            List<Map<String, Object>> userAttempts = quizDAO.getUserAttemptsForQuiz(account.getId(), quizId);
            if (userAttempts.isEmpty()) {
                // Never taken
                response.sendRedirect(request.getContextPath() + "/lesson-details?id=" + lessonId);
                return;
            }

            // Determine which attempt to show
            String attemptIdParam = request.getParameter("attemptId");
            String attemptIdError = MyLearningValidator.validateOptionalId("attemptId", attemptIdParam);
            if (attemptIdError != null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
            int selectedAttemptId = -1;
            if (attemptIdParam != null && !attemptIdParam.isEmpty()) {
                selectedAttemptId = Integer.parseInt(attemptIdParam);
            } else {
                // Default to most recent attempt
                selectedAttemptId = (Integer) userAttempts.get(userAttempts.size() - 1).get("id");
            }

            // Get selected attempt details
            Map<String, Object> selectedAttempt = null;
            for (Map<String, Object> att : userAttempts) {
                if ((Integer) att.get("id") == selectedAttemptId) {
                    selectedAttempt = att;
                    break;
                }
            }

            if (selectedAttempt == null) {
                // Invalid attempt ID for this user, fallback to latest
                selectedAttempt = userAttempts.get(userAttempts.size() - 1);
                selectedAttemptId = (Integer) selectedAttempt.get("id");
            }

            // Get all questions
            List<Map<String, Object>> questions = quizDAO.getQuestionsByQuizId(quizId);
            
            // Get all answers for questions
            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                List<Map<String, Object>> answers = quizDAO.getAnswersByQuestionId(qId);
                q.put("answers", answers);
            }
            
            // Get user's selected answers for this attempt
            List<Map<String, Object>> attemptAnswers = quizDAO.getAttemptAnswers(selectedAttemptId);
            
            // Map student choices to the questions
            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                Integer selectedAnswerId = null;
                for (Map<String, Object> ans : attemptAnswers) {
                    Integer ansQId = (Integer) ans.get("question_id");
                    if (ansQId != null && ansQId.equals(qId)) {
                        selectedAnswerId = (Integer) ans.get("selected_answer_id");
                        break;
                    }
                }
                q.put("selectedAnswerId", selectedAnswerId);
            }

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonQuiz", lessonQuiz);
            request.setAttribute("userAttempts", userAttempts);
            request.setAttribute("selectedAttempt", selectedAttempt);
            request.setAttribute("questions", questions);

            request.getRequestDispatcher("/view/course_learning/quiz-result.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().write("Error occurred in QuizResultController: " + e.getMessage() + "\n");
            for (StackTraceElement ste : e.getStackTrace()) {
                response.getWriter().write(ste.toString() + "\n");
            }
        }
    }
}
